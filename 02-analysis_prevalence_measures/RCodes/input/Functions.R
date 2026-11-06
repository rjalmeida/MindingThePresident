# Function that selects the right variables out of the dataset for each pair to be tested.
# The macroeconomic controls are always included.
wrap_HDGC_VAR <- function(GC, controls, GCpair, p = 1, bound = 0.5 * nrow(GCto)) {
  # allows to test for Granger causality for variables in the set of controls that are always included
  if (any(colnames(controls) %in% union(GCpair$GCfrom, GCpair$GCto))) {
    controls_clean <- controls[, - which(colnames(controls) %in% union(GCpair$GCfrom, GCpair$GCto)), 
                               drop = FALSE]
    data <- cbind(GC[, which(colnames(GC) %in% GCpair$GCfrom), drop = FALSE],
                  controls[, which(colnames(controls) %in% GCpair$GCfrom), drop = FALSE],
                  GC[, which(colnames(GC) %in% GCpair$GCto), drop = FALSE],
                  controls[, which(colnames(controls) %in% GCpair$GCto), drop = FALSE],
                  controls_clean)
  } else {
    data <- cbind(GC[, which(colnames(GC) %in% GCpair$GCfrom), drop = FALSE],
                  GC[, which(colnames(GC) %in% GCpair$GCto), drop = FALSE],
                  controls)
  }
  out <- HDGC_VAR_I0(GCpair, data, p = p, bound = bound, parallel = FALSE)
  return(out)
}

# Block bootstrap confidence intervals for correlations
boot_cor <- function(y, x, l = 12, B = 9999, a = 0.05) {
  names_y <- names(y)
  names_x <- names(x)
  y <- as.matrix(y)
  x <- as.matrix(x)
  ny <- NCOL(y)
  nx <- NCOL(x)
  n <- nrow(y)
  bcor <- array(dim = c(ny, nx, B))
  scor <- cor(y, x)
  nb <- ceiling(n/l)
  for (b in 1:B) {
    i <- sample.int(n - l + 1, size = nb, replace = TRUE)
    j <- c(sapply(i, function(x){seq(x, x + l - 1)}))[1:n]
    yb <- y[j, ]
    xb <- x[j, ]
    bcor[, , b] <- cor(yb, xb) - scor
  }
  q <- apply(bcor, 1:2, quantile, probs = c(1 - a/2, a/2))
  ci <- array(scor, c(dim(scor), 2)) - aperm(q, c(2, 3, 1))
  pval <- matrix(nrow = ny, ncol = nx)
  for (i in 1:ny) {
    for (j in 1:nx) {
      pval[i, j] <- 2*min(mean(bcor[i, j, ] > scor[i, j]), mean(bcor[i, j, ] < scor[i, j]))
    }
  }
  dimnames(ci) <- list(names_y, names_x)
  dimnames(pval) <- list(names_y, names_x)
  return(list(cor = scor, ci = ci, p_value = pval))
}