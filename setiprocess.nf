// Merge data
process mergeData {
    input:
    val readySignal         // wait for the tool install signal
    path off_spike          // HIP63121_OFF.spike
    path main_spike         // HIP63121.spike
    path target_txt         // target_time.txt

    output:
    path "HIP63121_on_off.hdf5", emit: merged_hdf5

    script:
    """
    setisignals merge --format hdf5 ${off_spike} ${main_spike} --targets ${target_txt} --output HIP63121_on_off.hdf5
    """
}

// Process data and generate plots
process plotData {
    publishDir 'results', mode: 'copy' // copy the generated plots into the results folder

    input:
    path merged_hdf5

    output:
    path "*" // collect all generated plot files

    script:
    """
    setisignals plot all ${merged_hdf5} --save
    """
}

// Reusable subworkflow, included by main.nf. This is the repeatable part of the pipeline.
workflow SETI_PROCESS {
    take:
    readySignal
    off_spike
    main_spike
    target_txt

    main:
    mergeData(readySignal, off_spike, main_spike, target_txt)
    plotData(mergeData.out.merged_hdf5)

    emit:
    merged_hdf5 = mergeData.out.merged_hdf5
}

// Standalone entry point: nextflow run setiprocess.nf (reads already-extracted data from ./data)
workflow {
    data_dir = 'data'
    off_spike_ch  = Channel.fromPath("${data_dir}/HIP63121_OFF.spike")
    main_spike_ch = Channel.fromPath("${data_dir}/HIP63121.spike")
    target_txt_ch = Channel.fromPath("${data_dir}/target_time.txt")
    ready_signal  = Channel.value(true)

    SETI_PROCESS(ready_signal, off_spike_ch, main_spike_ch, target_txt_ch)
}
