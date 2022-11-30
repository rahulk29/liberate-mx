use crate::{Result, TEMPLATES};
use std::path::{Path, PathBuf};

use serde::Serialize;

#[derive(Debug, Serialize)]
struct SourceTemplateContext<'a> {
    cell_name: &'a str,
    source_paths: &'a [PathBuf],
}

pub fn aggregate_sources(
    aggregate_path: impl AsRef<Path>,
    cell_name: &str,
    source_paths: &[PathBuf],
) -> Result<()> {
    let source_context = SourceTemplateContext {
        cell_name,
        source_paths,
    };

    let mut f = std::fs::File::create(aggregate_path)?;
    TEMPLATES.render_to(
        "source.spice",
        &tera::Context::from_serialize(&source_context)?,
        &mut f,
    )?;

    Ok(())
}
