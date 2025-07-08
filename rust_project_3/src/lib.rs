use godot::prelude::*;

mod constants;
mod logging;

struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}
