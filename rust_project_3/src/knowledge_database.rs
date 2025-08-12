use std::fmt::Display;

use godot::prelude::*;
use rusqlite::{Connection, Result, params};

#[derive(GodotConvert, Debug)]
#[godot(via = i64)]
pub enum GameObject {
    Entity,
    Item,
}

impl Display for GameObject {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let enum_display = match self {
            GameObject::Entity => "entity",
            GameObject::Item => "item",
        };

        f.pad(enum_display)
    }
}

impl From<GameObject> for i64 {
    fn from(value: GameObject) -> Self {
        match value {
            GameObject::Entity => 0,
            GameObject::Item => 1,
        }
    }
}

#[derive(GodotConvert, Debug)]
#[godot(via = i64)]
pub enum GameAction {
    Owns,
    HasTrait,
    LocatedIn,
    InteractsWith,
    Gives,
    IsA,
    Wears,
    Completes,
    Kills,
    Damages,
}

impl Display for GameAction {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let enum_display = match self {
            GameAction::Owns => "owns",
            GameAction::HasTrait => "has_trait",
            GameAction::LocatedIn => "located_in",
            GameAction::InteractsWith => "interacts_with",
            GameAction::Gives => "gives",
            GameAction::IsA => "is_a",
            GameAction::Wears => "wears",
            GameAction::Completes => "completes",
            GameAction::Kills => "kills",
            GameAction::Damages => "damages",
        };

        f.pad(enum_display)
    }
}

#[derive(GodotClass)]
#[class(base=Node)]
pub struct KnowledgeDatabase {
    connection: Connection,
    base: Base<Node>,
}

#[godot_api]
impl INode for KnowledgeDatabase {
    fn init(base: Base<Node>) -> Self {
        let connection = Connection::open_in_memory();
        if let Err(value) = connection {
            godot_error!(
                "KnowledgeDatabase: connection could not be opened due to {}",
                value.to_string()
            );
            panic!("KnowledgeDatabase could not be started!");
        } else {
            Self {
                connection: connection.expect("Connection was not successfully created"),
                base: base,
            }
        }
    }

    fn ready(&mut self) -> () {
        godot_print!("KnowledgeDatabase: Ready ~ Creating Tables");

        self.connection
            .execute(
                "CREATE TABLE entities (
                entity_id       INTEGER PRIMARY KEY,
                game_entity_id  TEXT NOT NULL UNIQUE
                )",
                (),
            )
            .expect("Failed at creating entities table");

        self.connection
            .execute(
                "CREATE TABLE items (
                item_id         INTEGER PRIMARY KEY,
                game_item_id    TEXT NOT NULL UNIQUE
                )",
                (),
            )
            .expect("Failed at creating items table");

        self.connection
            .execute(
                "CREATE TABLE ownership (
                id          INTEGER PRIMARY KEY,
                item_id     INTEGER NOT NULL,
                entity_id   INTEGER NOT NULL,
                amount      INTEGER NOT NULL,
                UNIQUE (item_id, entity_id),
                FOREIGN KEY (item_id)
                REFERENCES items (item_id)
                    ON UPDATE CASCADE
                    ON DELETE RESTRICT,
                FOREIGN KEY (entity_id)
                REFERENCES entities (entity_id)
                    ON UPDATE CASCADE
                    ON DELETE RESTRICT
                )",
                (),
            )
            .expect("Failed at creating ownership table");

        self.connection
            .execute(
                "CREATE TABLE quests (
                quest_id        INTEGER PRIMARY KEY,
                game_quest_id   TEXT NOT NULL UNIQUE,
                done            INTEGER NOT NULL DEFAULT 0,
		        CHECK (done == 0 OR done == 1)
                )",
                (),
            )
            .expect("Failed at creating quests table");

        self.connection
            .execute(
                "CREATE TABLE actions (
                action_id   INTEGER PRIMARY KEY,
                name        TEXT NOT NULL UNIQUE
                )",
                (),
            )
            .expect("Failed at creating actions table");

        self.connection
            .execute(
                "CREATE TABLE action_log (
                id                  INTEGER PRIMARY KEY,
                action_id           INTEGER NOT NULL,
                source_entity_id    INTEGER NOT NULL,
                target_object_id    INTEGER NOT NULL,
                target_object_type  INTEGER NOT NULL,
                time                REAL NOT NULL,
                FOREIGN KEY (action_id)
                REFERENCES actions (action_id)
                    ON UPDATE CASCADE
                    ON DELETE RESTRICT,
                FOREIGN KEY (source_entity_id)
                REFERENCES entities (entity_id)
                    ON UPDATE CASCADE
                    ON DELETE RESTRICT,
                CHECK (target_object_type == 0 OR target_object_type == 1)
            )",
                (),
            )
            .expect("Failed at creating action_log table");

        self.fill_entities_table();
        self.fill_items_table();
        self.fill_quests_table();
        self.fill_actions_table();
    }
}

#[godot_api]
impl KnowledgeDatabase {
    #[func]
    fn set_quest_done(&mut self, quest_id: String) -> bool {
        let update_result = self.connection.execute(
            "UPDATE quests SET done = 1 WHERE game_quest_id = ?1",
            [quest_id],
        );

        match update_result {
            Ok(num_rows) => {
                if num_rows == 0 {
                    godot_error!("Quest was not updated, perhaps incorrect game_quest_id");
                    false
                } else {
                    godot_print!("Updated quest, rows affected: {}", num_rows);
                    true
                }
            }
            Err(_) => {
                godot_error!("Could not update quest");
                false
            }
        }
    }

    #[func]
    fn get_quest_triplets(&self) -> String {
        let mut stmt = self
            .connection
            .prepare("SELECT game_quest_id, done FROM quests")
            .expect("Failed at creating prepared statement for quest triplets");

        let triplets_iter = stmt
            .query_map([], |row| {
                let game_quest_id: String = row
                    .get(0)
                    .expect("Could not get 'game_quest_id' from quests table");
                let done: i64 = row.get(1).expect("Could not get 'done' from quests table");

                if done == 1 {
                    Ok(format!("player completes {}", game_quest_id))
                } else {
                    Ok(format!("player not_completes {}", game_quest_id))
                }
            })
            .expect("Iterator could not be constructed");

        triplets_iter
            .filter(|triplet| triplet.is_ok())
            .fold("".to_string(), |mut acc, triplet| {
                acc.push_str(&triplet.unwrap());
                acc.push('\n');
                acc
            })
    }

    #[func]
    fn update_ownership_quantity(
        &mut self,
        game_item_id: String,
        game_entity_id: String,
        amount: i32,
    ) -> bool {
        let (item, entity) = (
            self.get_item_id(game_item_id),
            self.get_entity_id(game_entity_id),
        );

        if let Err(_) = item {
            godot_error!("Item not found");
            return false;
        }

        if let Err(_) = entity {
            godot_error!("Entity not found");
            return false;
        }

        let (item, entity) = (item.unwrap(), entity.unwrap());

        let update_result = self.connection.execute(
            "UPDATE ownership SET amount = ?1 WHERE item_id = ?2 AND entity_id = ?3",
            params![amount, item, entity],
        );

        if let Err(_) = update_result {
            godot_error!("Could not update ownership");
            return false;
        }

        let num_rows = update_result.unwrap();

        if num_rows == 0 {
            godot_print!("No update, inserting new ownership data");
            let insert_result = self.connection.execute(
                "INSERT INTO ownership (item_id, entity_id, amount) VALUES (?1, ?2, ?3)",
                params![item, entity, amount],
            );
            if let Err(_) = insert_result {
                godot_error!("Insertion failed");
                return false;
            }
        } else {
            godot_print!("Updated ownership, rows affected: {}", num_rows);
        }

        true
    }

    #[func]
    fn get_ownership_quantity(&self, game_item_id: String, game_entity_id: String) -> i64 {
        let (item, entity) = (
            self.get_item_id(game_item_id),
            self.get_entity_id(game_entity_id),
        );

        if let Err(_) = item {
            godot_error!("Item not found");
            return -1;
        }

        if let Err(_) = entity {
            godot_error!("Entity not found");
            return -1;
        }

        let (item, entity) = (item.unwrap(), entity.unwrap());

        let entity: Result<i64> = self.connection.query_one(
            "SELECT amount FROM ownership WHERE item_id = ?1 AND entity_id = ?2",
            [item, entity],
            |row| row.get(0),
        );

        match entity {
            Ok(val) => val,
            Err(_) => {
                godot_error!("Error obtaining amount");
                -1
            }
        }
    }

    #[func]
    fn get_ownership_triplets(&self) -> String {
        todo!()
    }

    #[func]
    fn add_action(
        &mut self,
        action: String,
        source: String,
        target: String,
        target_type: GameObject,
    ) -> bool {
        todo!()
    }

    #[func]
    fn get_action_triplets(&self) -> String {
        todo!()
    }

    fn fill_entities_table(&mut self) -> () {
        let resource_dictionary = self.base().get_node_as::<Node>("/root/ResourceDictionary");
        let npc_ids = resource_dictionary
            .get("npc_ids")
            .try_to::<Array<GString>>()
            .unwrap();

        let mut stmt = self
            .connection
            .prepare("INSERT INTO entities (game_entity_id) VALUES (?1)")
            .expect("Failed at creating prepared statement for fill entities");

        for npc_id in npc_ids.iter_shared() {
            stmt.execute([npc_id.to_string()])
                .expect("Error when inserting npc ids into entities");
        }

        stmt.execute(["player"])
            .expect("Error when inserting player id into entities");
        stmt.execute(["enemy_knight"])
            .expect("Error when inserting knight id into entities");
    }

    fn fill_items_table(&mut self) -> () {
        let resource_dictionary = self.base().get_node_as::<Node>("/root/ResourceDictionary");
        let item_ids = resource_dictionary
            .get("item_ids")
            .try_to::<Array<GString>>()
            .unwrap();

        let mut stmt = self
            .connection
            .prepare("INSERT INTO items (game_item_id) VALUES (?1)")
            .expect("Failed at creating prepared statement for fill items");

        for item_id in item_ids.iter_shared() {
            stmt.execute([item_id.to_string()])
                .expect("Error when inserting item ids into items");
        }
    }

    fn fill_quests_table(&mut self) -> () {
        let resource_dictionary = self.base().get_node_as::<Node>("/root/QuestManager");
        let quests = resource_dictionary
            .get("quests")
            .try_to::<Array<Gd<Resource>>>()
            .unwrap();

        let mut stmt = self
            .connection
            .prepare("INSERT INTO quests (game_quest_id) VALUES (?1)")
            .expect("Failed at creating prepared statement for fill quests");

        for quest in quests.iter_shared() {
            let quest_id = quest.get("id").try_to::<GString>().unwrap();
            stmt.execute([quest_id.to_string()])
                .expect("Error when inserting quest ids into quests");
        }
    }

    fn fill_actions_table(&mut self) -> () {
        let mut stmt = self
            .connection
            .prepare("INSERT INTO actions (name) VALUES (?1)")
            .expect("Failed at creating prepared statement for fill actions");

        stmt.execute([GameAction::Completes.to_string()])
            .expect("Error when inserting game action name into actions");
        stmt.execute([GameAction::Damages.to_string()])
            .expect("Error when inserting game action name into actions");
        stmt.execute([GameAction::Gives.to_string()])
            .expect("Error when inserting game action name into actions");
        stmt.execute([GameAction::HasTrait.to_string()])
            .expect("Error when inserting game action name into actions");
        stmt.execute([GameAction::InteractsWith.to_string()])
            .expect("Error when inserting game action name into actions");
        stmt.execute([GameAction::IsA.to_string()])
            .expect("Error when inserting game action name into actions");
        stmt.execute([GameAction::Kills.to_string()])
            .expect("Error when inserting game action name into actions");
        stmt.execute([GameAction::LocatedIn.to_string()])
            .expect("Error when inserting game action name into actions");
        stmt.execute([GameAction::Owns.to_string()])
            .expect("Error when inserting game action name into actions");
        stmt.execute([GameAction::Wears.to_string()])
            .expect("Error when inserting game action name into actions");
    }

    fn get_item_id(&self, game_item_id: String) -> Result<i64, String> {
        self.connection
            .query_one(
                "SELECT item_id FROM items WHERE game_item_id = ?1",
                [game_item_id],
                |row| row.get(0),
            )
            .map_err(|err| format!("Item id could not be obtained, {}", err.to_string()))
    }

    fn get_entity_id(&self, game_entity_id: String) -> Result<i64, String> {
        self.connection
            .query_one(
                "SELECT entity_id FROM items WHERE game_entity_id = ?1",
                [game_entity_id],
                |row| row.get(0),
            )
            .map_err(|err| format!("Entity id could not be obtained, {}", err.to_string()))
    }
}
