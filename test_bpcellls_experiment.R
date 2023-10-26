
library(BPCells.Experiment)

## Load the example RNA + ATAC dataset in BPCells.Experiment
scme <- load_example_scme()
scme

## Write the RNA experiment into H5. This should work.
bpce <- writeH5BPCE(scme[[1]], "bpce.h5", overwrite = TRUE)
bpce

## Write the ATAC experiment into H5. This also works.
cbpce <- writeH5BPCE(scme[[2]], "cbpce.h5", overwrite = TRUE)
cbpce

## Write the Multi-omics data into H5. This failed while writing the 10xMatrixH5 into a H5 group.
# scme2 <- writeH5SCME(scme, "scme.h5", overwrite = TRUE)

## Runing the experiment-writing parts outside 'writeH5SCME' works.
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
  if (verbose) {
    message("Done\n")
  }
}

