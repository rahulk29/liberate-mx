use std::path::PathBuf;

use crate::test_utils::{EXAMPLES_PATH, TEST_BUILD_PATH};
use crate::{generate_lib, LibParams};

/// Tests LIB generation for a generic SRAM instance.
#[test]
fn test_generate_lib_sram() {
    let src_files = vec![PathBuf::from(EXAMPLES_PATH).join("sram22_256x32m4w8.spice")];
    let work_dir = PathBuf::from(TEST_BUILD_PATH).join("sram22_256x32m4w8/lib");
    let save_dir = PathBuf::from(TEST_BUILD_PATH).join("sram22_256x32m4w8");

    let params = LibParams::builder()
        .work_dir(work_dir)
        .output_file(save_dir.join("sram22_256x32m4w8.lib"))
        .corner("tt")
        .cell_name("sram22_256x32m4w8")
        .num_words(256)
        .data_width(32)
        .addr_width(8)
        .has_wmask(true)
        .wmask_width(4)
        .mux_ratio(4)
        .source_paths(src_files)
        .build()
        .unwrap();

    let data = generate_lib(&params).expect("Failed to generate Liberty file");

    std::fs::metadata(&data.lib_file).unwrap_or_else(|e| {
        panic!(
            "Failed to read LIB file at path `{:?}` due to error: {}. Does the file exist?",
            &data.lib_file, e
        )
    });
}

/// Tests LIB generation for an SRAM with a single bit write mask.
#[test]
fn test_generate_lib_sram_1bit_mask() {
    let src_files = vec![PathBuf::from(EXAMPLES_PATH).join("sram22_512x32m4w32.spice")];
    let work_dir = PathBuf::from(TEST_BUILD_PATH).join("sram22_512x32m4w32/lib");
    let save_dir = PathBuf::from(TEST_BUILD_PATH).join("sram22_512x32m4w32");

    let params = LibParams::builder()
        .work_dir(work_dir)
        .output_file(save_dir.join("sram22_512x32m4w32.lib"))
        .corner("tt")
        .cell_name("sram22_512x32m4w32")
        .num_words(512)
        .data_width(32)
        .addr_width(9)
        .has_wmask(true)
        .wmask_width(1)
        .mux_ratio(4)
        .source_paths(src_files)
        .build()
        .unwrap();

    let data = generate_lib(&params).expect("Failed to generate Liberty file");

    std::fs::metadata(&data.lib_file).unwrap_or_else(|e| {
        panic!(
            "Failed to read LIB file at path `{:?}` due to error: {}. Does the file exist?",
            &data.lib_file, e
        )
    });
}
