use std::path::PathBuf;

use crate::test_utils::{EXAMPLES_PATH, TEST_BUILD_PATH};
use crate::{generate_lib, LibParams};

#[test]
fn test_generate_lib_sram() {
    let src_files = vec![
        PathBuf::from(EXAMPLES_PATH).join("sramgen_sram_32x32m2w8_replica_v1.spice"),
        PathBuf::from(EXAMPLES_PATH).join("include/openram_dff.spice"),
        PathBuf::from(EXAMPLES_PATH)
            .join("include/sky130_fd_bd_sram__openram_sp_cell_opt1_replica.spice"),
        PathBuf::from(EXAMPLES_PATH).join("include/sky130_fd_bd_sram__sram_sp_cell.spice"),
        PathBuf::from(EXAMPLES_PATH).join("include/sramgen_control_replica_v1.spice"),
        PathBuf::from(EXAMPLES_PATH).join("include/sramgen_sp_sense_amp.lvs.spice"),
    ];
    let work_dir = PathBuf::from(TEST_BUILD_PATH).join("sramgen_sram_32x32m2w8_replica_v1/lib");
    let save_dir = PathBuf::from(TEST_BUILD_PATH).join("sramgen_sram_32x32m2w8_replica_v1");

    let params = LibParams::builder()
        .work_dir(work_dir)
        .output_file(save_dir.join("abstract.lef"))
        .corner("tt")
        .cell_name("sramgen_sram_32x32m2w8_replica_v1")
        .num_words(32)
        .data_width(32)
        .addr_width(5)
        .wmask_width(4)
        .mux_ratio(2)
        .source_paths(src_files)
        .build()
        .unwrap();

    let data = generate_lib(&params).expect("Failed to generate Liberty file");

    std::fs::metadata(&data.lib_file).unwrap_or_else(|e| {
        panic!(
            "Failed to read LEF file at path `{:?}` due to error: {}. Does the file exist?",
            &data.lib_file, e
        )
    });
}
