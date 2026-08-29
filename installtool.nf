// Install the setisignals tool. Run once; no need to run again afterwards.
process installTool {
    output:
    val true, emit: done // emit completion signal

    script:
    """
    # Only clone if the directory doesn't exist yet, to avoid re-fetching
    if [ ! -d "setisignals" ]; then
        git clone git@github.com:liuweiseu/setisignals.git
    fi

    cd setisignals
    uv tool install -e .
    """
}

// Reusable subworkflow, included by main.nf
workflow INSTALL_TOOL {
    main:
    installTool()

    emit:
    done = installTool.out.done
}

// Standalone entry point: nextflow run installtool.nf
workflow {
    INSTALL_TOOL()
}
