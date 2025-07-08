use godot::prelude::*;

mod logging;

struct MyExtension;

#[gdextension]
unsafe impl ExtensionLibrary for MyExtension {}
