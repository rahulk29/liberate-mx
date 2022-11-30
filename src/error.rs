use std::process::ExitStatus;

use thiserror::Error;

#[derive(Error, Debug)]
pub enum Error {
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),
    #[error("Error generating templates: {0}")]
    Template(#[from] tera::Error),
    #[error("Liberate failed with status: {0}")]
    LiberateFail(ExitStatus),
}

pub type Result<T> = std::result::Result<T, Error>;
