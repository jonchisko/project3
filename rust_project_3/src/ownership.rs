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
            CREATE TABLE entities (entity_id INTEGER PRIMARY KEY);
            INSERT INTO items VALUES (1), (2);
            INSERT INTO entities VALUES (1), (2);",
        )
        .unwrap();
        db.execute_batch(CREATE_TABLE).unwrap();
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
    }

    #[test]
    fn batch_shortage_rolls_back_earlier_items() {
        let mut db = database();
        set_quantity(&db, 1, 1, 2).unwrap();
        assert!(transfer(&mut db, 1, 2, &[(1, 1), (2, 1)]).is_err());
        assert_eq!(quantity(&db, 1, 1).unwrap(), 2);
        assert_eq!(quantity(&db, 1, 2).unwrap(), 0);
    }

    #[test]
    fn replacing_is_exact_and_repeatable() {
        let mut db = database();
        set_quantity(&db, 1, 1, 7).unwrap();
        replace(&mut db, 1, &[(2, 3)]).unwrap();
        replace(&mut db, 1, &[(2, 3)]).unwrap();
        assert_eq!(quantity(&db, 1, 1).unwrap(), 0);
        assert_eq!(quantity(&db, 2, 1).unwrap(), 3);
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
}
