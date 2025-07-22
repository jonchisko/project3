use godot::builtin::GString;
use godot::classes::file_access::ModeFlags;
use godot::meta::AsArg;
use godot::tools::GFile;

use crate::logging::Repository;
use crate::logging::RepositoryError;

pub struct FileStorage;

impl Repository for FileStorage {
    fn save<T>(path: &str, data: T) -> Result<(), RepositoryError>
    where
        T: AsArg<GString>,
    {
        let mut log_file = GFile::open(path, ModeFlags::WRITE)
            .map_err(|err| RepositoryError::StorageFileOpen(err.to_string()))?;

        log_file
            .write_gstring(data)
            .map_err(|err| RepositoryError::WriteString(err.to_string()))?;

        Ok(())
    }
}
