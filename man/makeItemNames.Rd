% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/scorehelpers.R
\name{makeItemNames}
\alias{makeItemNames}
\title{Quickly create a vector of sequentially numbered item names}
\usage{
makeItemNames(prefix, nitems)
}
\arguments{
\item{prefix}{A quoted prefix that will precede the number in the item name
(e.g., the "Q" in "Q1").}

\item{nitems}{The number of items}
}
\value{
A character vector of sequentially numbered item names.
}
\description{
Takes a prefix (e.g., "Q") and the number of items you want
(e.g., 3), and returns a vector of item names (e.g., c("Q1", "Q2", "Q3")).
}
\examples{
makeItemNames("q", 3)
itemNames <- makeItemNames("item", 7)
itemNames
}
