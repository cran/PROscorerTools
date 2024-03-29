#' @title Flexible function to score a single PRO or other psychometric scale
#'
#' @description \code{scoreScale} is a flexible function that can be used to
#'   calculate a single scale score from a set of items.
#'
#' @details The \code{scoreScale} function is the workhorse of the
#'   \pkg{\link{PROscorerTools}} package, and it is intended to be the building
#'   block of other, more complex scoring functions tailored to specific PRO
#'   measures.  It can handle items that need to be reverse coded before
#'   scoring, and it has options for handling missing item responses.  It can
#'   use three different methods to score the items: (1) sum scoring (the sum of
#'   the item scores), mean scoring (the mean of the item scores), and 0-100
#'   scoring (like sum or mean scoring, except that the scores are rescaled to
#'   range from 0 to 100).  This latter method is also called "POMP" scoring
#'   (Percent Of the Maximum Possible), and is the default scoring method of
#'   \code{scoreScale} since it has numerous advantages over other scoring
#'   methods (see References).
#'
#'   This function assumes that all items have the same numeric response range.
#'   It can still be used to score scales comprised of items with different
#'   response ranges with two caveats:
#'   \itemize{
#'     \item First, if your items have different ranges of possible response
#'       values AND some need to be reverse coded before scoring, you should not
#'       use this function's \code{revitems} plus \code{minmax} arguments to
#'       reverse your items.  Instead, you should manually reverse code your
#'       items (see \code{\link{revcode}}) before using \code{scoreScale}, and omit the
#'       \code{revitems} and \code{minmax} arguments.
#'     \item Second, depending on how the different item response options are
#'       numerically coded, some items might contribute more/less to the scale
#'       score than others.  For example, consider a questionnaire where the
#'       first item has responses coded as "0 = No, 1 = Yes" and the rest of the
#'       items are coded as "0 = Never, 1 = Sometimes, 2 = Always".  The first
#'       item will contribute relatively less weight to the scale score than the
#'       other items because its maximum value is only 1, compared to 2 for the
#'       other items.  This state of affairs is not ideal, and you might want to
#'       reconsider including items with different response ranges in one scale
#'       score (if you have that option).
#'   }
#'
#' @section Further Explanation of Arguments:
#'   The \code{scoreScale} function technically has only 1 required argument,
#'   \code{df}.  If none of your items need to be reverse coded before scoring,
#'   your items are in a data frame named \code{myData}, and \code{myData}
#'   contains ONLY the items to be scored and no non-scored variables, then
#'   \code{scoreScale(myData)} is sufficient to score your items.
#'
#'   In most real-world situations, however, you will likely have a data frame
#'   containing a mix of items and other variables.  In this case, you should
#'   additionally use the \code{items} argument to indicate which variables in
#'   your data frame are the items to be scored.  For example, assume that
#'   \code{myData} contains an ID variable named "ID", followed by three items
#'   named "Q1", "Q2", and "Q3", none of which need to be reverse coded.  You
#'   can score the scale by providing the \code{items} argument with either
#'   \strong{(1)} a numeric vector with the column indexes of the items, like
#'   \code{scoreScale(myData, items = 2:4)} or \code{scoreScale(myData, items =
#'   c(2, 3, 4)}, or \strong{(2)} a character vector with the item names, like
#'   \code{scoreScale(myData, items = c("Q1", "Q2", "Q3")}.
#'
#'
#' @param df A data frame containing the items you wish to score.  It can
#'   contain only the items, or the items plus other non-scored variables.  If
#'   it contains non-scored variables, then you must use the \code{items}
#'   argument to let the function know how to find your items in \code{df}.
#' @param items (optional) A character vector with the item names, or a numeric
#'   vector indicating the column numbers of the items in \code{df}.  If
#'   \code{items} is omitted, then \code{scoreScale} will assume that \code{df}
#'   contains only the items to be scored and no non-scored variables.
#' @param revitems (optional) either \code{TRUE}, \code{FALSE}, or
#'   a vector indicating which items in \code{df} should be reverse coded before
#'   scoring.  If omitted or \code{FALSE} (the default), no items are reverse
#'   coded.  If \code{TRUE}, all items are reverse coded before scoring.  If
#'   only some of the items should be reverse coded, provide either a character
#'   vector with names of the items or a numeric vector with column numbers of
#'   the items in \code{df} that should be reverse coded before scoring.  If
#'   this argument is anything but \code{FALSE}, then the \code{minmax} argument
#'   is required.
#' @param minmax (optional) A vector of 2 integers of the format
#'   \code{c(itemMin, itemMax)}, indicating the minimum and maximum possible
#'   item responses, e.g., \code{c(0, 4)}.  This argument is required if
#'   \code{type} equals \code{"pomp"} (the default \code{type}) or \code{"100"}.
#'   This is also required only \code{revitems} is used and not set to
#'   \code{FALSE}.  This function assumes that all items have the same response
#'   range.  If this is not the case, then manually reverse code your items in
#'   \code{df} before using this function, and omit the \code{revitems} and
#'   \code{minmax} arguments.
#' @param okmiss The maximum proportion of items that a respondent is allowed to
#'   have missing and still have their non-missing items scored (and prorated).
#'   If the proportion of missing items for a respondent is greater than
#'   \code{okmiss}, then the respondent will be assigned a value of \code{NA}
#'   for their scale score.  The default value is \code{0.50}.
#' @param type The type of score that \code{scoreScale} should produce.  Must be
#'   one of either \code{"sum"} (for the sum of the item scores), \code{"mean"}
#'   (for the mean of the item scores), \code{"100"} (for the score transformed
#'   to range from 0 to 100), or \code{"pomp"} (for a score representing the
#'   "Percent Of the Maximum Possible", which is exactly the same as
#'   \code{"100"} but with a better name).  The default is \code{"pomp"}.
#' @param scalename The quoted variable name you want the function to give your
#'   scored scale.  If this argument is omitted, the scale will be named
#'   \code{"scoredScale"} by default.
#' @param keepNvalid Logical value indicating whether a variable containing the
#'   number of valid, non-missing items for each respondent should be returned
#'   in a data frame with the scale score.  The default is \code{FALSE}.  Set to
#'   \code{TRUE} to return this variable, which will be named \code{"scalename_N"}
#'   (with whatever name you gave to the \code{scalename} argument).  Most users
#'   should probably omit this argument entirely.  This argument might be
#'   removed from future versions of the package, so please let me know if you
#'   think this argument useful and would rather it remain a part of the
#'   function.
#'
#' @return A data frame with a variable containing the scale score.  Optionally,
#'   the data frame can additionally have a variable containing the number of
#'   valid item responses for each respondent.
#'
#' @references
#' Cohen, P, Cohen, J, Aiken, LS, & West, SG (1999). The problem of units and
#' the circumstance for POMP. \emph{Multivariate Behavioral Research}, 34(3),
#' 315-346.

#'

#' @export
#'
#' @examples
#' # Make a data frame using default settings of makeFakeData() function
#' # (20 respondents, 9 items with values 0 to 4, and about 20% missing)
#' dat <- makeFakeData()
#'
#' # First "sum" score the items, then "mean" score them
#' scoreScale(dat, type = "sum")
#' scoreScale(dat, type = "mean")
#'
#' # Must use "minmax" argument if the "type" argument is "100"
#' scoreScale(dat, type = "100", minmax = c(0, 4))
#' # If you omit "type", the default is "pomp" (which is identical to "100")
#' scoreScale(dat, minmax = c(0, 4))
#'
#' # "minmax" is also required if any items need to be reverse coded for scoring
#' #  Below, the first two items are reverse coded before scoring
#' scoreScale(dat, type = "sum", revitems = c("q1", "q2"), minmax = c(0, 4))
scoreScale <- function( df,
                        items = NULL,
                        revitems = FALSE,
                        minmax = NULL,
                        okmiss = .50,
                        type = c("pomp", "100", "sum", "mean"),
                        scalename ="scoredScale",
                        keepNvalid = FALSE) {

## Check that df is a data.frame -----------------------------------
  # chkstop_df(df)    # Or is below better?
  chkstop_df(df = df)

## Check okmiss.  Must be between 0-1.
  chkstop_okmiss(okmiss = okmiss)

## CHECK if type is a valid value ----
  type <- match.arg(type)

## REQUIRE minmax if (type == "pomp" || type == "100")  ----
  chkstop_type(type = type, minmax = minmax)


## Get dfItems, df of only items -----------------------------------
  # dfItems <- get_dfItems(df, items )  # Or is below better?
  dfItems <- get_dfItems(df = df, items = items )



## CHECK revitems    --------------------------------------
  if (isTRUE(revitems) || (!is.logical(revitems) && !is.null(revitems))) {
  # if (!is.logical(revitems) && !is.null(revitems)) {
  # if (revitems != FALSE && !is.null(revitems)) {
  # Checking if revitems values are in dfItems, and if minmax is given.
    chkstop_revitems(df=df, dfItems=dfItems, revitems=revitems,
                     items=items, minmax=minmax)
  }

## CHECK minmax, if given.  Items ranges should be within minmax  ---------
  if (!is.null(minmax)) {
    chkstop_minmax(dfItems = dfItems, minmax = minmax)
  }

## PROCESS revitems    -------------------------------------------
  ## 4. If revitems given (and passes checks), reverse dfItems[revitems].
  ##    a. If revitems = TRUE, just reverse all items in dfItems.
  ##    b. If revitems = character, Reverse items in dfItems by names in revitems
  ##    c. If revitems = numeric,
  ##       (1) Get variable names in df using the indices given to revitems
  ##       (2) Reverse items in dfItems by names extracted from df.

## GET a version of dfItems that has reversed items
## ? Need to return(dfItems) in get_dfItemsrev?
  if(isTRUE(revitems) || (!is.logical(revitems) && !is.null(revitems))) {
    dfItems <- get_dfItemsrev(df=df, dfItems=dfItems,
                              revitems=revitems, minmax=minmax)
  }
##### NOW, dfItems should be a df with the items,
##### with the appropriate items reversed as indicated by revitems.
## 5. Now should have dfItems with the proper items reversed, ready to score.


## 6. Generate score according to type.
  meanScore <- rowMeans(dfItems, na.rm = TRUE)
  sumScore  <- meanScore*ncol(dfItems)

##  Assign scoreOut to be appropriate type using switch()
  switch(type,
         "pomp" = ,
         "100" = {
           scoreOut <-  suppressWarnings(
             rerange100(meanScore, minmax[1], minmax[2])
             ) },
         "sum" = {scoreOut <- sumScore},
         "mean" = {scoreOut <- meanScore}
  )

## 7. Get score_N
  score_N <- missTally(dfItems, what = "nvalid")
  pctmiss <- missTally(dfItems, what = "pmiss")*100
#  pctmiss <- missTally(dfItems, what = "pmiss")*100

## 8. Assing NA to scores where misspct > okmiss.
  scoreOut[pctmiss > okmiss*100] <- NA
  # meanScore[pctmiss > okmiss*100] <- NA
  # score100[pctmiss > okmiss*100] <- NA
  # sumScore[pctmiss > okmiss*100] <- NA

## 9. Output score and score_N (if keepNvalid = TRUE)
  if (keepNvalid) {
    out <- data.frame(scoreOut, score_N)
    names(out) <- c(scalename, paste0(scalename, "_N"))
  }
  if (!keepNvalid) {
    out <- data.frame(scoreOut)
    names(out) <- c(scalename)
  }

  return(out)

}
