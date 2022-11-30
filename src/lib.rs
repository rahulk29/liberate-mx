use std::os::unix::prelude::PermissionsExt;
use std::path::{Path, PathBuf};
use std::process::Command;

use derive_builder::Builder;
use lazy_static::lazy_static;
use netlist::aggregate_sources;
use serde::{Deserialize, Serialize};
use tera::{Context, Tera};

use crate::error::{Error, Result};

pub mod error;
pub(crate) mod netlist;

#[cfg(test)]
mod tests;

pub(crate) const TEMPLATES_PATH: &str = concat!(env!("CARGO_MANIFEST_DIR"), "/templates");

lazy_static! {
    pub(crate) static ref TEMPLATES: Tera = {
        match Tera::new(&format!("{}/*", TEMPLATES_PATH)) {
            Ok(t) => t,
            Err(e) => {
                panic!("Encountered errors while parsing Tera templates: {}", e);
            }
        }
    };
}

#[derive(Builder, Clone, Debug, Eq, PartialEq, Serialize)]
pub struct LibParams {
    /// The directory in which to run Liberate and save temporary files.
    #[builder(setter(into))]
    pub work_dir: PathBuf,

    /// The directory in which to save the final Liberate file.
    #[builder(setter(into))]
    pub save_dir: PathBuf,

    /// The process corner to use for characterization.
    ///
    /// Currently, only `tt` is supported.
    #[builder(setter(into), default = "std::string::String::from(\"tt\")")]
    pub corner: String,

    /// The name of the cell to generate a LIB for.
    #[builder(setter(into))]
    pub cell_name: String,

    /// The number of words in the SRAM.
    pub num_words: usize,

    /// The number of data input and output bits.
    pub data_width: usize,

    /// The number of address bits.
    pub address_width: usize,

    /// The number of write mask bits.
    pub wmask_width: usize,

    /// The column mux ratio.
    pub mux_ratio: usize,

    /// The path to the source files for the cell.
    #[builder(setter(into))]
    pub source_paths: Vec<PathBuf>,
}

impl LibParams {
    /// Obtain a builder.
    #[inline]
    pub fn builder() -> LibParamsBuilder {
        LibParamsBuilder::default()
    }
}

/// Data generated from running Liberate.
pub struct LibData {
    /// The path to the generated Liberty file.
    pub lib_file: PathBuf,
}

#[derive(Debug, Serialize)]
struct TemplateCtx<'a> {
    cell_name: &'a str,
    num_words: usize,
    data_width: usize,
    address_width: usize,
    wmask_width: usize,
    mux_ratio: usize,

    corner: &'a str,

    template_path: &'a Path,
    netlist_path: &'a Path,
    models_path: &'a Path,
    models_leakage_path: &'a Path,
    mx_path: &'a Path,
    run_script_path: &'a Path,
    ldb_path: &'a PathBuf,
    lib_path: &'a PathBuf,
    verilog_path: &'a PathBuf,
}

#[derive(Debug, Serialize, Deserialize)]
struct GeneratedPaths {
    template_path: PathBuf,
    netlist_path: PathBuf,
    models_path: PathBuf,
    models_leakage_path: PathBuf,
    mx_path: PathBuf,
    run_script_path: PathBuf,
    stdout_path: PathBuf,
    stderr_path: PathBuf,
    ldb_path: PathBuf,
    lib_path: PathBuf,
    verilog_path: PathBuf,
}

/// Generate a Liberty file.
pub fn generate_lib(params: &LibParams) -> Result<LibData> {
    let paths = generate_paths(params);
    render_templates(params, &paths)?;
    execute_run_script(params, &paths)?;

    // move lib file to correct location
    let lib_file = params.save_dir.join(lib_file_name(params));
    std::fs::copy(paths.lib_path, &lib_file)?;
    Ok(LibData { lib_file })
}

fn ldb_file_name(params: &LibParams) -> String {
    format!("{}_{}_025C_1v80.ldb", params.cell_name, params.corner)
}

/// The name of the generated Liberty file.
pub fn lib_file_name(params: &LibParams) -> String {
    format!("{}_{}_025C_1v80.lib", params.cell_name, params.corner)
}

fn verilog_file_name(params: &LibParams) -> String {
    format!("{}.v", params.cell_name)
}

fn execute_run_script(params: &LibParams, paths: &GeneratedPaths) -> Result<()> {
    // Create standard out and standard error files
    let stdout = std::fs::File::create(&paths.stdout_path)?;
    let stderr = std::fs::File::create(&paths.stderr_path)?;

    // Make the run script executable
    let mut perms = std::fs::metadata(&paths.run_script_path)?.permissions();
    perms.set_mode(0o755);
    std::fs::set_permissions(&paths.run_script_path, perms)?;

    let status = Command::new("/usr/bin/bash")
        .arg(&paths.run_script_path)
        .current_dir(&params.work_dir)
        .stdout(stdout)
        .stderr(stderr)
        .status()?;

    if !status.success() {
        return Err(Error::LiberateFail(status));
    }

    Ok(())
}

fn generate_paths(params: &LibParams) -> GeneratedPaths {
    let work_dir = &params.work_dir;
    GeneratedPaths {
        template_path: work_dir.join("template.tcl"),
        netlist_path: work_dir.join("src/netlist.spice"),
        models_path: work_dir.join("src/models.spice"),
        models_leakage_path: work_dir.join("src/models_leakage.spice"),
        mx_path: work_dir.join("mx.tcl"),
        run_script_path: work_dir.join("run_mx.sh"),
        stdout_path: work_dir.join("logs/liberate.out"),
        stderr_path: work_dir.join("logs/liberate.err"),
        ldb_path: work_dir.join(ldb_file_name(params)),
        lib_path: work_dir.join(lib_file_name(params)),
        verilog_path: work_dir.join(verilog_file_name(params)),
    }
}

fn render_templates(params: &LibParams, paths: &GeneratedPaths) -> Result<()> {
    let ctx = TemplateCtx {
        cell_name: &params.cell_name,
        num_words: params.num_words,
        data_width: params.data_width,
        address_width: params.address_width,
        wmask_width: params.wmask_width,
        mux_ratio: params.mux_ratio,
        corner: &params.corner,
        template_path: &paths.template_path,
        netlist_path: &paths.netlist_path,
        models_path: &paths.models_path,
        models_leakage_path: &paths.models_leakage_path,
        mx_path: &paths.mx_path,
        run_script_path: &paths.run_script_path,
        ldb_path: &paths.ldb_path,
        lib_path: &paths.lib_path,
        verilog_path: &paths.verilog_path,
    };

    let ctx = Context::from_serialize(ctx)?;

    let mut mx = std::fs::File::create(&paths.mx_path)?;
    TEMPLATES.render_to("mx.tcl", &ctx, &mut mx)?;

    let mut template = std::fs::File::create(&paths.template_path)?;
    TEMPLATES.render_to("template_sram.tcl", &ctx, &mut template)?;

    let mut models = std::fs::File::create(&paths.models_path)?;
    TEMPLATES.render_to("include_tt.spice", &ctx, &mut models)?;

    let mut models_leakage = std::fs::File::create(&paths.models_leakage_path)?;
    TEMPLATES.render_to("include_tt_leakage.spice", &ctx, &mut models_leakage)?;

    let mut run_script = std::fs::File::create(&paths.run_script_path)?;
    TEMPLATES.render_to("run_mx.sh", &ctx, &mut run_script)?;

    aggregate_sources(&paths.netlist_path, &params.cell_name, &params.source_paths)?;

    Ok(())
}

#[cfg(test)]
pub(crate) mod test_utils {
    pub(crate) const TEST_BUILD_PATH: &str = concat!(env!("CARGO_MANIFEST_DIR"), "/build");
    pub(crate) const EXAMPLES_PATH: &str = concat!(env!("CARGO_MANIFEST_DIR"), "/examples");
}
