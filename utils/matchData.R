## A function to match inputs of BGLR (y and ETA) based on names/rownames.
# It returns a list $y, $ETA with terms matched based on IDs
# If data is incomplete (no names/rownames) or inconsistent the function stop its execution and print messages
##

matchData <- function(y, ETA, verbose =TRUE) {

    # Convert y to matrix internally
    yMatrix <- is.matrix(y)
    if (!yMatrix) {
        y <- as.matrix(y)
    }

    # Check y IDs
    if (is.null(rownames(y))) {
        stop("y must have names (or rownames)")
    }


    # Create list of IDs
    IDS <- list()
    IDS$y <- rownames(y)

    # Extract IDs for each predictor term
    nTerms <- length(ETA)

    if (nTerms == 0) {
        stop("ETA must contain at least one term")
    }

    if (is.null(names(ETA))) {
    	if(verbose){ message('  Adding names to the terms in ETA.')}
        names(ETA) <- paste0("ETA_", 1:nTerms)
    }

    for (i in seq_len(nTerms)) {

        hasX <- "X" %in% names(ETA[[i]])
        hasK <- "K" %in% names(ETA[[i]])

        if (!hasX && !hasK) {
            stop(paste0(
                "Term ", i,
                " in ETA does not have \"X\" or \"K\""
            ))
        }

        tmpID <- NULL

        # X
        if (hasX) {

            X <- ETA[[i]]$X

            if (is.null(rownames(X))) {
                stop(paste0(
                    "X in term ", i,
                    " of ETA does not have rownames"
                ))
            }

            tmpID <- rownames(X)
        }

        # K
        if (hasK) {

            K <- ETA[[i]]$K

            if (is.null(rownames(K)) ||
                is.null(colnames(K))) {
                stop(paste0(
                    "K in term ", i,
                    " must have both rownames and colnames"
                ))
            }


            if (nrow(K) != ncol(K) ||
                !identical(rownames(K), colnames(K))) {
                stop(paste0(
                    "K in term ", i,
                    " is either not square or has mismatched ",
                    "rownames and colnames"
                ))
            }

            # If X is also present, make sure IDs agree
            if (!is.null(tmpID) &&
                !identical(tmpID, rownames(K))) {
                stop(paste0(
                    "X and K in term ", i,
                    " have different rownames"
                ))
            }

            tmpID <- rownames(K)
        }

        IDS[[names(ETA)[i]]] <- tmpID
    }

    # Find IDs present in all data sources
    commonIDS <- Reduce(intersect, IDS)

    if (length(commonIDS) == 0) {
        stop("No common IDs were found among y and ETA")
    }

    # Report matching
    if (verbose) {
         message('------------- Summary ----------------')
        message(" Number of entries by term")
        message("  => : ", length(IDS$y))

        for (i in seq_len(nTerms)) {
            message(
                "  => ETA ", i, ": ",
                length(IDS[[names(ETA)[i]]])
            )
        }

        message("  => Number of IDs in common: ",
                length(commonIDS))
    }

    # Match y
    y <- y[commonIDS, , drop = FALSE]

    # Match predictors
    for (i in seq_len(nTerms)) {

        if ("X" %in% names(ETA[[i]])) {
            ETA[[i]]$X <-
                ETA[[i]]$X[commonIDS, , drop = FALSE]
        }

        if ("K" %in% names(ETA[[i]])) {
            ETA[[i]]$K <-
                ETA[[i]]$K[
                    commonIDS,
                    commonIDS,
                    drop = FALSE
                ]
        }
    }
    message('---------- end of match --------------')

    # Return y as vector if originally supplied as vector
    if (!yMatrix) {
        y <- as.vector(y)
    }

    return(list(y = y, ETA = ETA))
}

if(FALSE){
 library(BGLR)
 data(wheat)

 # Test case 1: no IDs in X
  DATA=matchData(wheat.Y,ETA=list(list(X=wheat.X)))

 # Test case 2: all good
  rownames(wheat.X)=rownames(wheat.Y)
  DATA=matchData(wheat.Y,ETA=list(list(X=wheat.X)))

  # Test case 3: X and K, K has only a few entries of those in X
   K=wheat.A[1:300,1:300]

   DATA=matchData(wheat.Y,ETA=list(list(X=wheat.X),list(K=K)))
}
