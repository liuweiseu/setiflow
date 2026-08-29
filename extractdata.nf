// Extract the data archive. Run once; results are copied into ./data for reuse afterwards.
process extractData {
    publishDir 'data', mode: 'copy' // save extracted files into ./data for later runs

    input:
    path archiveFile // the archive file

    output:
    path "HIP63121_OFF.spike", emit: off_spike
    path "HIP63121.spike",     emit: main_spike
    path "target_time.txt",    emit: target_txt

    script:
    """
    tar -xzvf ${archiveFile} --strip-components=1
    """
}

// Reusable subworkflow, included by main.nf
workflow EXTRACT_DATA {
    take:
    archiveFile

    main:
    extractData(archiveFile)

    emit:
    off_spike  = extractData.out.off_spike
    main_spike = extractData.out.main_spike
    target_txt = extractData.out.target_txt
}

// Standalone entry point: nextflow run extractdata.nf
workflow {
    data_archive_ch = Channel.fromPath('HIP63121_data.tar.gz')
    EXTRACT_DATA(data_archive_ch)
}
