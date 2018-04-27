#' Comparison of methods to calculate the number of classes
#'
#' Compare the methods for calculation of the number of classes from a numerical random variable.
#'
#' @param x a numerical vector.
#' @param density logical; if \code{TRUE}, the histogram graphic is a representation of frequencies, the counts component of the result; if \code{FALSE}, probability densities, component density, are plotted (so that the histogram has a total area of one).
#' @param xlab a character string, X axis label. By default it gets from object vector name with \code{deparse(substitute(x))}.
#'
#' @return A \emph{nc_comp} object.
#'
#' @seealso \code{\link{hist}}, \code{\link{geom_histogram}}, \code{\link{geom_freqpoly}}.
#'
#' @rdname nc_comp
#' @export nc_comp
#' @exportClass  nc_comp
nc_comp <- function(x, density = FALSE, xlab = NULL, ...) UseMethod("nc_comp")

#' @describeIn nc_comp Default output from \code{nc_comp} function.
#' @exportMethod  nc_comp default
#' @export nc_comp.default
nc_comp.default <- function(x, density = FALSE, xlab = NULL, ...) {

  # X variable name ----
  xlab <- deparse(substitute(x))

  # Classes number calculation ----
  out <- compare_nclass(x, density = density, xlab = xlab)

  # Return ----
  class(out) <- "nc_comp"

  return(out)
}

#' @describeIn nc_comp Print output from \code{nc_comp} function.
#' @exportMethod nc_comp print
#' @export print.nc_comp
print.nc_comp <- function(x, ...) {
  cat("Class number methods comparison.\n\n")
  print(x$nclasses)
}

#' @describeIn nc_comp ggplot2 plot output from \code{nc_comp} function.
#' @exportMethod nc_comp ggplot
#' @export ggplot.nc_comp
ggplot.nc_comp <- function(x, ...) {
  print(x$plots)
}

#' @describeIn nc_comp Summary output from \code{nc_comp} function.
#' @exportMethod nc_comp summary
#' @export summary.nc_comp
summary.nc_comp <- function(x, ...) {
  cat("Class number methods comparison.\n\n")
  print(x$nclasses)

  cat("\n")

  cat("Summary of input vector:\n\n")
  print(summary(x$data))
}

#' @inheritParams nc_comp
#' @export compare_nclass
compare_nclass <- function(x, density = FALSE, xlab = NULL, ...) {

  # X variable name ----
  if (is.null(xlab)) {
    xlab <- deparse(substitute(x))
  }

  # Class number compute methods ----
  nclass_methods <- c("Sturges", "FD", "scott")

  # Lists ----
  plots <- list()
  plots.acum <- list()
  nclasses <- data.frame(method = NA,
                         nclasses = NA)

  # Plots ----
  for (i in 1:length(nclass_methods)) {

    nclasses[i,1] <- nclass_methods[i]
    nclasses[i,2] <- switch (nclass_methods[i],
                             "Sturges" = nclass.Sturges(x),
                             "FD" = nclass.FD(x),
                             "scott" = nclass.scott(x)
    )

    # Density plots ----
    plots[[i]] <- plot_freq(x, nclass = nclass_methods[i],
                            density = density) +
      labs(x = xlab)
    names(plots)[i] <- nclass_methods[i] # List object name

    # Cummulative frequency polygon
    plots.acum[[i]] <- plot_freq(x, nclass = nclass_methods[i],
                                 density = density, cfp = T) +
      labs(x = xlab)
    names(plots.acum)[i] <- nclass_methods[i] # List object name
  }

  # Comparison plots ----
  cplots <- plot_grid(plots$Sturges,
                      plots.acum$Sturges,
                      plots$FD,
                      plots.acum$FD,
                      plots$scott,
                      plots.acum$scott,
                      ncol = 2)

  # Return ----
  out <- list(data = x,
              nclasses = nclasses,
              plots = cplots)

  return(out)

}
