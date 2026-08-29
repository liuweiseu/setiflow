// params.install_tool / params.extract_data defaults are set in nextflow.config.
// Run installation explicitly with: nextflow run main.nf --install_tool true
// Run extraction explicitly with:   nextflow run main.nf --extract_data true

include { INSTALL_TOOL } from './installtool.nf'
include { EXTRACT_DATA } from './extractdata.nf'
include { SETI_PROCESS } from './setiprocess.nf'

// Main workflow
workflow {
    data_dir = 'data'

    // Skip the install step by default (already installed locally), run only when --install_tool true
    if (params.install_tool) {
        install_ready = INSTALL_TOOL()
        ready_signal = install_ready.done
    } else {
        ready_signal = Channel.value(true)
    }

    // Skip extraction by default (data already extracted into ./data), run only when --extract_data true
    if (params.extract_data) {
        data_archive_ch = Channel.fromPath('HIP63121_data.tar.gz')
        extracted = EXTRACT_DATA(data_archive_ch)
        off_spike_ch  = extracted.off_spike
        main_spike_ch = extracted.main_spike
        target_txt_ch = extracted.target_txt
    } else {
        off_spike_ch  = Channel.fromPath("${data_dir}/HIP63121_OFF.spike")
        main_spike_ch = Channel.fromPath("${data_dir}/HIP63121.spike")
        target_txt_ch = Channel.fromPath("${data_dir}/target_time.txt")
    }

    // Merge and plot
    SETI_PROCESS(ready_signal, off_spike_ch, main_spike_ch, target_txt_ch)
}
