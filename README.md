# A weird issue with IO of BPCells

## Overview
I try to wrap `IterableMatrix` from [BPCells](https://github.com/bnprks/BPCells) into a `SingleCellExperiment` object, named `BPCExperiment`, to hold project-related metadata and dimension reduction data. And I extended `MultiAssayExperiment` so that it can hold single-cell multi-omics experiments. A function named `writeH5BPCE()` was designed to write a single `BPCExperiment` into a HDF5 group. When I call `writeH5BPCE()` directly in an R session, it just works. However, when I wrap `writeH5BPCE()` in a high-level function `writeH5SCME` to iterably write multiple `BPCExperiment`s in a `MultiAssayExperiment`, the R session just stucks at writing `IterableMatrix`, without any message or error raised.

* `mydocker.sh` is used to run a docker container where `BPCells.Experiment` is pre-installed.
* `test_bpcellls_experiment.R` tests those `writeH5*` functions.

## Walk through
```
library(BPCells.Experiment)

## Load the example RNA + ATAC dataset in BPCells.Experiment
scme <- load_example_scme()
scme
```

Write the RNA experiment into H5. This should work.
```
bpce <- writeH5BPCE(scme[[1]], "bpce.h5", overwrite = TRUE)
bpce
```
```
Writing assay 'counts'
Writing a IterableMatrix:
 Class: 10xMatrixH5
 File: /develop/ycli1995/BPCells.testwrapper/bpce.h5
 Group: /assays/counts
Writing rowRanges
Writing rowData
Writing colData
Writing metadata
Writing altExps
Writing reducedDims
Writing colPairs
Writing rowPairs
Add H5 attribute indicating S4 class: BPCExperiment
Updating altExps
Updating assays
Reading assay 'counts'
```

Write the ATAC experiment into H5. This also works.
```
cbpce <- writeH5BPCE(scme[[2]], "cbpce.h5", overwrite = TRUE)
cbpce
```
```
Writing assay 'counts'
Writing a IterableMatrix:
 Class: RenameDims
 File: /develop/ycli1995/BPCells.testwrapper/cbpce.h5
 Group: /assays/counts
Writing rowRanges
Writing rowData
Writing colData
Writing metadata
Writing altExps
Writing reducedDims
Writing colPairs
Writing rowPairs
Writing fragments
Writing a IterableFragments:
 Class: CellSelectName
 File: /develop/ycli1995/BPCells.testwrapper/cbpce.h5
 Group: /fragments
Writing geneAnnot
Writing seqinfo
Add H5 attribute indicating S4 class: ChromBPCExperiment
Updating altExps
Updating assays
Reading assay 'counts'
Updating fragments
Reading fragments
```

Write the Multi-omics data into H5. This stucks while writing the 10xMatrixH5 into a H5 group.
```
scme2 <- writeH5SCME(scme, "scme.h5", overwrite = TRUE)
```
```
# Writing experiment: RNA
Writing assay 'counts'
Writing a IterableMatrix:
 Class: 10xMatrixH5
 File: /develop/ycli1995/BPCells.testwrapper/scme.h5
 Group: /experiments/RNA/assays/counts

## No output followed anymore. The R session just somehow crashes.
```

Runing the experiment-writing parts outside 'writeH5SCME' works.
```
file <- "scme2.h5"
name <- "/"
gzip_level <- 0L
verbose <- TRUE
object <- h5Prep(scme)
exp.names <- names(x = object$experiments)
for (i in exp.names) {
  if (verbose) {
    message("# Writing experiment: ", i)
  }
  writeH5BPCE(
    object = object$experiments[[i]],
    file = file,
    name = file.path(name, "experiments", i),
    gzip_level = gzip_level,
    verbose = verbose
  )
  BPCells.Experiment:::.set_h5attr_bpce(
    object = exp,
    file = file,
    name = file.path(name, "experiments", i),
    verbose = verbose
  )
  if (verbose) {
    message("Done\n")
  }
}
```

```
# Writing experiment: RNA
Writing assay 'counts'
Writing a IterableMatrix:
 Class: 10xMatrixH5
 File: /develop/ycli1995/BPCells.testwrapper/scme2.h5
 Group: /experiments/RNA/assays/counts
Writing rowRanges
Writing rowData
Writing colData
Writing metadata
Writing altExps
Writing reducedDims
Writing colPairs
Writing rowPairs
Add H5 attribute indicating S4 class: BPCExperiment
Updating altExps
Updating assays
Reading assay 'counts'
Done

# Writing experiment: ATAC
Writing assay 'counts'
Writing a IterableMatrix:
 Class: RenameDims
 File: /develop/ycli1995/BPCells.testwrapper/scme2.h5
 Group: /experiments/ATAC/assays/counts
Writing rowRanges
Writing rowData
Writing colData
Writing metadata
Writing altExps
Writing reducedDims
Writing colPairs
Writing rowPairs
Writing fragments
Writing a IterableFragments:
 Class: CellSelectName
 File: /develop/ycli1995/BPCells.testwrapper/scme2.h5
 Group: /experiments/ATAC/fragments
Writing geneAnnot
Writing seqinfo
Add H5 attribute indicating S4 class: ChromBPCExperiment
Updating altExps
Updating assays
Reading assay 'counts'
Updating fragments
Reading fragments
Done
```