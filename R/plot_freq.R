#' Histogram and frequency polygon
#'
#' Creates an histogram and frequency polygon or a cummulative frequency polygon.
#'
#' @param x a numerical vector.
#' @param nclass a character string. Method for calculation of the number of classes from a numerical random variable.
#' @param density logical; if TRUE, the histogram graphic is a representation of frequencies, the counts component of the result; if FALSE, probability densities, component density, are plotted (so that the histogram has a total area of one).
#' @param cfp logical, indicating if the plot is an histogram and frequency polygon or a cummulative frequency polygon.
#'
#' @return A ggplot2 object.
#'
#' @seealso \code{\link{hist}}, \code{\link{geom_histogram}}, \code{\link{geom_freqpoly}}.
#'
#' @examples
#' data <- rnorm(100)
#' plot_freq(data)
#' plot_freq(data, nclass = "FD", cfp = TRUE)
#'
#' # Change graphical parameters
#' plot_freq(data) +
#'    theme_void()
#'
#'@export

plot_freq <- function(x, nclass = "Sturges", density = FALSE, cfp = FALSE) {

  # Calculation of the number of classes ----
  nclasses <- switch (tolower(nclass),
                      "sturges" = ceiling(nclass.Sturges(x)),
                      "fd" = ceiling(nclass.FD(x)),
                      "scott" = ceiling(nclass.scott(x))
  )

  # Breaks ----
  breaks <- pretty(range(x), n = nclasses, min.n = 1)

  # Histogram and frequency polygons ----
  # fd to Friedman-Diaconis change
  nclass[which(nclass == "FD")] <- "Freedman-Diaconis"

  # Y axis variable calculation and label
  yaxis <- list(scale = ifelse(density == FALSE, "..count..", "..density.."),
                scale.acum = ifelse(density == FALSE, "cumsum(..count..)", "cumsum(..density..)/sum(..density..)"),
                label = ifelse(density == FALSE, "frequency", "density"))

  # Plot
  if (cfp) {
    # Cummulative frequency polygon (cfp)
    plot <- x %>%
      data.frame() %>%
      ggplot(aes(x = x)) +
      stat_bin(aes_string(y = yaxis$scale.acum),
               breaks = breaks,
               closed = "left",
               geom = "line") +
      labs(x = substitute(x), y = yaxis$label) +
      ggtitle(nclass) +
      theme_bw()

  } else {
    # Histogram and frequency polygon
    plot <- x %>%
      data.frame() %>%
      ggplot(aes(x = x)) +
      geom_histogram(aes_string(y = yaxis$scale),
                     breaks = breaks,
                     closed = "left",
                     colour = "black",
                     fill = "white") +
      geom_freqpoly(aes_string(y = yaxis$scale),
                    breaks = breaks,
                    closed = "left") +
      labs(x = substitute(x), y = yaxis$label) +
      ggtitle(nclass) +
      theme_bw()

  }

  # Output ----
  return(plot)

}
