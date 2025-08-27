extends Node
class_name KDBService


# Source of truth for the enum is in Rust /rust_project_3/src/knowledge_database.rs
enum GameAction {
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

@onready var kdb_rust: KnowledgeDatabase = $KDBRust
