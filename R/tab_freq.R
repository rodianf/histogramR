#' Frequency table
#'
#' Creates a classical frequency distribution table.
#'
#' @param x a numerical vector.
#' @param nclass a character string. Method for calculation of the number of classes from a numerical random variable.
#' @param include.lowest logical, indicating if an ‘x[i]’ equal to the lowest (or highest, for right = FALSE) ‘breaks’ value should be included.
#' @param right logical, indicating if the intervals should be closed on the right (and open on the left) or vice versa.
#'
#' @return A tibble (data frame) with five columns. First column contains class intervals, second is frequency '\emph{f}', then relative frequency '\emph{rf}', cummulative frequency '\emph{cf}' and cummulative relative frecuency '\emph{crf}', respectively.
#'
#' @note Classes with zero frequency are dropped from table. This is caused by function \code{group_by} from \code{dplyr} package, however a correction for this behavior will be implemented soon. See \url{https://github.com/tidyverse/dplyr/pull/3492}.
#'
#' @seealso \code{\link{hist}}, \code{\link{cut}}.
#'
#' @examples
#' data <- rnorm(100)
#' tab_freq(data)
#' tab_freq(data, nclass = "FD")
#'
#' # Rename columns
#' tab_freq(data) %>%
#'    rename("Relative frequency" = rl,
#'           "Frequency" = f)
#'
#'@export

tab_freq <- function(x, nclass = "Sturges", include.lowest = TRUE, right = FALSE) {

  # X variable name ----
  xlab <- deparse(substitute(x))

  # Calculation of the number of classes ----
  nclass <- switch (tolower(nclass),
                    "sturges" = ceiling(nclass.Sturges(x)),
                    "fd" = ceiling(nclass.FD(x)),
                    "scott" = ceiling(nclass.scott(x))
  )

  # Breaks ----
  breaks <- pretty(range(x), n = nclass, min.n = 1)

  # Frequency table ----

  # Clases con frecuencia cero 0 son eliminadas de la tabla.
  # Este comportamiento es debido a la función group_by().
  # Se está trabajando en implementar drop = FALSE en group_by().
  # https://github.com/tidyverse/dplyr/pull/3492

  tabla_frecuencias <- x %>%
    data.frame() %>%
    group_by(x = cut(x, breaks = breaks,
                     include.lowest = include.lowest,
                     right = right)) %>%
    summarise(f = n()) %>%
    mutate(rf = f/sum(f),
           cf = cumsum(f),
           crf = cumsum(rf),
           x = gsub(",", ", ", x)) %>%
    rename_(.dots = setNames("x", xlab))

  # Output ----
  return(tabla_frecuencias)
}
