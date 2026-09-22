//! Ownership balances shared by the Godot interface and database regression tests.
use rusqlite::{Connection, OptionalExtension, params};

pub const MAX_QUANTITY: i64 = i32::MAX as i64;
pub const CREATE_TABLE: &str = "CREATE TABLE ownership (
    id INTEGER PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES items(item_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    entity_id INTEGER NOT NULL REFERENCES entities(entity_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    amount INTEGER NOT NULL CHECK (amount >= 0 AND amount <= 2147483647),
    UNIQUE (item_id, entity_id)
)";

pub fn quantity(connection: &Connection, item: i64, owner: i64) -> Result<i64, String> {
    connection
        .query_row(
            "SELECT amount FROM ownership WHERE item_id = ?1 AND entity_id = ?2",
            params![item, owner],
            |row| row.get(0),
        )
        .optional()
        .map(|amount| amount.unwrap_or(0))
        .map_err(|err| err.to_string())
}

pub fn set_quantity(
    connection: &Connection,
    item: i64,
    owner: i64,
    amount: i64,
) -> Result<(), String> {
    if !(0..=MAX_QUANTITY).contains(&amount) {
        return Err("Ownership quantity is outside the supported range".into());
    }
    connection
        .execute(
            "INSERT INTO ownership (item_id, entity_id, amount) VALUES (?1, ?2, ?3)
         ON CONFLICT(item_id, entity_id) DO UPDATE SET amount = excluded.amount",
            params![item, owner, amount],
        )
        .map_err(|err| err.to_string())?;
    Ok(())
}

pub fn replace(
    connection: &mut Connection,
    owner: i64,
    items: &[(i64, i64)],
) -> Result<(), String> {
    let transaction = connection.transaction().map_err(|err| err.to_string())?;
    // Keep explicit zero balances for previously owned items.
    transaction
        .execute(
            "UPDATE ownership SET amount = 0 WHERE entity_id = ?1",
            [owner],
        )
        .map_err(|err| err.to_string())?;
    for &(item, amount) in items {
        set_quantity(&transaction, item, owner, amount)?;
    }
    transaction.commit().map_err(|err| err.to_string())
}

pub fn transfer(
    connection: &mut Connection,
    source: i64,
    recipient: i64,
    items: &[(i64, i64)],
) -> Result<(), String> {
    if source == recipient {
        return Err("An ownership transfer needs two different owners".into());
    }
    let transaction = connection.transaction().map_err(|err| err.to_string())?;
    for &(item, amount) in items {
        if !(1..=MAX_QUANTITY).contains(&amount) {
            return Err("Transfer quantity must be a positive supported integer".into());
        }
        let source_amount = quantity(&transaction, item, source)?;
        let recipient_amount = quantity(&transaction, item, recipient)?;
        if source_amount < amount {
            return Err("The giver does not own enough of the requested item".into());
        }
        set_quantity(&transaction, item, source, source_amount - amount)?;
        set_quantity(&transaction, item, recipient, recipient_amount + amount)?;
        // The event and both balances commit together, including batch rewards.
        let time = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map_err(|err| err.to_string())?
            .as_secs();
        transaction
            .execute(
                "INSERT INTO action_log (action_id, source_entity_id, target_object, time,
                recipient_entity_id, item_id, quantity)
             VALUES ((SELECT action_id FROM actions WHERE name = 'gives'), ?1,
                (SELECT game_entity_id FROM entities WHERE entity_id = ?2), ?3, ?2, ?4, ?5)",
                params![source, recipient, time, item, amount],
            )
            .map_err(|err| err.to_string())?;
    }
    transaction.commit().map_err(|err| err.to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn database() -> Connection {
        let db = Connection::open_in_memory().unwrap();
        db.execute_batch(
            "PRAGMA foreign_keys = ON;
            CREATE TABLE items (item_id INTEGER PRIMARY KEY);
            CREATE TABLE entities (entity_id INTEGER PRIMARY KEY, game_entity_id TEXT);
            CREATE TABLE actions (action_id INTEGER PRIMARY KEY, name TEXT UNIQUE);
            INSERT INTO actions VALUES (1, 'gives');
            INSERT INTO items VALUES (1), (2);
            INSERT INTO entities VALUES (1, 'player'), (2, 'npc');",
        )
        .unwrap();
        db.execute_batch(CREATE_TABLE).unwrap();
        db.execute_batch(crate::knowledge_database::CREATE_ACTION_LOG)
            .unwrap();
        db
    }

    #[test]
    fn transfers_update_both_owners_in_both_directions() {
        let mut db = database();
        set_quantity(&db, 1, 1, 2).unwrap();
        transfer(&mut db, 1, 2, &[(1, 1)]).unwrap();
        assert_eq!(quantity(&db, 1, 1).unwrap(), 1);
        assert_eq!(quantity(&db, 1, 2).unwrap(), 1);
        transfer(&mut db, 2, 1, &[(1, 1)]).unwrap();
        assert_eq!(quantity(&db, 1, 1).unwrap(), 2);
        assert_eq!(quantity(&db, 1, 2).unwrap(), 0);
        let events: Vec<(i64, i64, i64, i64)> = db.prepare(
            "SELECT source_entity_id, recipient_entity_id, item_id, quantity FROM action_log ORDER BY id"
        ).unwrap().query_map([], |r| Ok((r.get(0)?, r.get(1)?, r.get(2)?, r.get(3)?)))
            .unwrap().map(Result::unwrap).collect();
        assert_eq!(events, vec![(1, 2, 1, 1), (2, 1, 1, 1)]);
    }

    #[test]
    fn batch_shortage_rolls_back_earlier_items() {
        let mut db = database();
        set_quantity(&db, 1, 1, 2).unwrap();
        assert!(transfer(&mut db, 1, 2, &[(1, 1), (2, 1)]).is_err());
        assert_eq!(quantity(&db, 1, 1).unwrap(), 2);
        assert_eq!(quantity(&db, 1, 2).unwrap(), 0);
        assert_eq!(
            db.query_row("SELECT COUNT(*) FROM action_log", [], |r| r
                .get::<_, i64>(0))
                .unwrap(),
            0
        );
    }

    #[test]
    fn replacing_is_exact_and_repeatable() {
        let mut db = database();
        set_quantity(&db, 1, 1, 7).unwrap();
        replace(&mut db, 1, &[(2, 3)]).unwrap();
        replace(&mut db, 1, &[(2, 3)]).unwrap();
        assert_eq!(quantity(&db, 1, 1).unwrap(), 0);
        assert_eq!(quantity(&db, 2, 1).unwrap(), 3);
        assert_eq!(
            db.query_row("SELECT COUNT(*) FROM action_log", [], |r| r
                .get::<_, i64>(0))
                .unwrap(),
            0
        );
        assert!(replace(&mut db, 1, &[(1, 1), (2, -1)]).is_err());
        assert_eq!(quantity(&db, 1, 1).unwrap(), 0);
        assert_eq!(quantity(&db, 2, 1).unwrap(), 3);
    }

    #[test]
    fn invalid_transfers_and_overflow_do_not_change_balances() {
        let mut db = database();
        set_quantity(&db, 1, 1, 2).unwrap();
        for amount in [-1, 0, 3, MAX_QUANTITY + 1] {
            assert!(transfer(&mut db, 1, 2, &[(1, amount)]).is_err());
        }
        assert!(transfer(&mut db, 1, 1, &[(1, 1)]).is_err());
        set_quantity(&db, 1, 2, MAX_QUANTITY).unwrap();
        assert!(transfer(&mut db, 1, 2, &[(1, 1)]).is_err());
        assert_eq!(quantity(&db, 1, 1).unwrap(), 2);
        assert_eq!(quantity(&db, 1, 2).unwrap(), MAX_QUANTITY);
        assert!(set_quantity(&db, 1, 1, -1).is_err());
        assert!(db.execute("UPDATE ownership SET amount = -1", []).is_err());
    }

    #[test]
    fn sql_failure_rolls_back_the_source_debit() {
        let mut db = database();
        set_quantity(&db, 1, 1, 2).unwrap();
        assert!(transfer(&mut db, 1, 999, &[(1, 1)]).is_err());
        assert_eq!(quantity(&db, 1, 1).unwrap(), 2);
    }

    #[test]
    fn event_failure_rolls_back_balances() {
        let mut db = database();
        set_quantity(&db, 1, 1, 2).unwrap();
        db.execute_batch(
            "CREATE TRIGGER reject_event BEFORE INSERT ON action_log
            BEGIN SELECT RAISE(ABORT, 'test event failure'); END;",
        )
        .unwrap();
        assert!(transfer(&mut db, 1, 2, &[(1, 1)]).is_err());
        assert_eq!(quantity(&db, 1, 1).unwrap(), 2);
        assert_eq!(quantity(&db, 1, 2).unwrap(), 0);
        assert_eq!(
            db.query_row("SELECT COUNT(*) FROM action_log", [], |r| r
                .get::<_, i64>(0))
                .unwrap(),
            0
        );
    }

    #[test]
    fn batch_records_each_item_once_and_schema_rejects_partial_details() {
        let mut db = database();
        replace(&mut db, 1, &[(1, 2), (2, 3)]).unwrap();
        transfer(&mut db, 1, 2, &[(1, 2), (2, 3)]).unwrap();
        assert_eq!(
            db.query_row("SELECT COUNT(*) FROM action_log", [], |r| r
                .get::<_, i64>(0))
                .unwrap(),
            2
        );
        assert!(
            db.execute("UPDATE action_log SET quantity = NULL", [])
                .is_err()
        );
        assert!(
            db.execute("UPDATE action_log SET quantity = 0", [])
                .is_err()
        );
        assert!(
            db.execute("UPDATE action_log SET item_id = 999", [])
                .is_err()
        );
    }
}
