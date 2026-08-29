# seti-nextflow-demo

A small Nextflow (DSL2) pipeline that merges ON/OFF `setisignals` spike data
for the target `HIP63121` and generates plots.

## Prerequisites

- [Nextflow](https://www.nextflow.io/)
- [`setisignals`](https://github.com/liuweiseu/setisignals) available on `PATH`
  (installed via `uv tool install -e .`)

## Layout

| File               | Purpose                                                                 |
|--------------------|--------------------------------------------------------------------------|
| `main.nf`          | Entry point; orchestrates the steps below                               |
| `installtool.nf`   | One-time step: clone and install `setisignals`                          |
| `extractdata.nf`   | One-time step: extract the raw data archive into `./data`               |
| `setiprocess.nf`   | Repeatable step: merge ON/OFF spike data and generate plots             |
| `nextflow.config`  | Pipeline parameter defaults                                             |

Each module file can also be run standalone (e.g. `nextflow run installtool.nf`).

## Data layout

The pipeline expects extracted data under `./data`:

```
data/
├── HIP63121_OFF.spike
├── HIP63121.spike
└── target_time.txt
```

## Usage

Normal run (tool already installed, data already extracted into `./data`):

```bash
nextflow run main.nf
```

First-time setup on a new machine (install the tool and extract the raw
archive `HIP63121_data.tar.gz` before processing):

```bash
nextflow run main.nf --install_tool true --extract_data true
```

The install/extract steps only need to run once; subsequent runs can omit
both flags.

## Output

Generated plots are copied to `./results`.
