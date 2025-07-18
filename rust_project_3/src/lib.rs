use godot::prelude::*;

mod constants;
mod file_storage;
mod history;
mod logging;

struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}
