use std::fmt::Display;

use godot::{classes::Engine, prelude::*};
use rusqlite::{Connection, Result};

#[derive(Debug)]
struct Person {
    id: i32,
    name: String,
    data: Option<Vec<u8>>,
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
                target_entity_id    INTEGER NOT NULL,
                time                REAL NOT NULL,
                FOREIGN KEY (action_id)
                REFERENCES actions (action_id)
                    ON UPDATE CASCADE
                    ON DELETE RESTRICT,
                FOREIGN KEY (source_entity_id)
                REFERENCES entities (entity_id)
                    ON UPDATE CASCADE
                    ON DELETE RESTRICT,
                FOREIGN KEY (target_entity_id)
                REFERENCES entities (entity_id)
                    ON UPDATE CASCADE
                    ON DELETE RESTRICT
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
        todo!()
    }

    #[func]
    fn get_quest_triplets(&self) -> String {
        todo!()
    }

    #[func]
    fn update_possession_quantity(
        &mut self,
        item_id: String,
        entity_id: String,
        new_value: i32,
    ) -> bool {
        // If exists, update, if it does not, insert

        todo!()
    }

    #[func]
    fn get_possession_quantity(&self, item_id: String, entity_id: String) -> i32 {
        // if it does not exist, return 0
        todo!()
    }

    #[func]
    fn get_possessions_triplets(&self) -> String {
        todo!()
    }

    #[func]
    fn add_action(&mut self, action: String, source: String, target: String) -> bool {
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
}
