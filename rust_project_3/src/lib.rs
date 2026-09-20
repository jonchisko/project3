use godot::prelude::*;

mod constants;
mod file_storage;
mod history;
mod knowledge_database;
mod logging;
mod ownership;

struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}
