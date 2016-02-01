# R_exercise-subsetting.R
#
# Practising filtering of data via R's subsetting methods
#
# Boris Steipe (boris.steipe@utoronto.ca)
# Jan 2016
# (C) copyrighted material. Do not share without permission.
# ====================================================================

"A significant portion of your efforts in any project will be spent on preparing data for analysis. This includes reading data from various sources, preprocessing it, and extracting subsets of interest. R has powerful mechanisms that support these tasks."


# ====================================================================
#        PART ONE: REVIEW
# ====================================================================


# ===== Sample data ==================================================

"Let's start with a small datframe of synthetic data to go through the main principles of subsetting. The same principles apply to matrices and vetors - however, data frames are more flexible because their columns can contain data of different types (character, numeric, logical ...). Values in vectors and matrices must always have the same type.

Imagine you are a naturalist that has collected some living things and keeps observations in a table ..."

set.seed(112358)
N <- 10

dat <- data.frame(name = sample(LETTERS, N, replace = TRUE),
                  legs = sample(c(2 * (0:5), 100), N, replace = TRUE),
                  type = character(N),
                  matrix(rnorm(5 * N), ncol = 5),
                  stringsAsFactors=FALSE)

"Some auxiliary data ..."
dict <- c("fish", "bird", "beast", "bug", "spider", "crab", "centipede")
names(dict) <- c(2 * (0:5), 100)
"... to populate the >>type<< column:"
dat$type <- dict[as.character(dat$legs)]

"If you already understand the expression above, you're doing pretty well with the topic of this tutorial. If you don't, don't worry - by the end of the tutorial you will.

Now let's see what we have:"

head(dat)
str(dat)

'Note that we have given names to some columns, but R made names for the five columns of random values that were created as a matrix.

Let us look at the  basic ways to subset such objects. Basically, all these methods work with the subsetting operator "[". '

?"["


# ===== Subsetting by index ==========================================

"Elements can be uniquely identified by indices in the range of their length (for vectors), or their rows and columns (in dataframes and matrices). The order is row, column."

dat[2,3]   # one element
dat[2, ]   # empty columns: use all of them
dat[ , 3]  # empty rows, use all of them

"If you want a particular set of row and columns, pass a vector of positive integers."
dat[c(2, 3), c(1, 2, 3)]

'Any function that returns a vector of integers can be used. Most frequently we use the range operator ":" . Retrieving ranges of rows and/or columns from a matrix or data frame is also called "slicing".'

dat[1:4, 1:3]
dat[4:1, 1:3]   # same in reverse order
dat[seq(2, N, by=2), ]   # even rows

"But we can do more interesting things, since the indices don't have to be unique, or in any order:"

dat[c(1, 1, 1, 2, 2, 3), 1:3]

"In particular we can select random subsets..."
dat[sample(1:N, 3), 1:3]
dat[sample(1:N, 3), 1:3]
dat[sample(1:N, 3), 1:3]

"... or sort the dataframe. Sorting requires the order() function, not sort()."

sort(dat[ , 2])    # ... gives us the sorted values

    order(dat[ , 2])   # ... tells us in which row the sotrted values are
dat[order(dat[ , 2]), 1:3]  # ordered by number of legs
dat[order(dat[ , 1]), 1:3]  # ordered by lexical order of names

"Note: I am indenting expressions so you can first evaluate the expressions individually, then see how they fit into the brackets to subset the data."


# ==== Negative indices

"If you specify a negative index, that element is excluded."

dat[-1, 1:3]   # not the first row
dat[-N, 1:3]   # not the last row

dat[-1:-3, 1:3]
dat[-(1:3), 1:3]  # same effect



# ===== Subsetting by boolean ========================================

"Instead of indices, we can specify sets of rows or columns by boolean values (type: logical): TRUE or FALSE. If we place a vector of logicals into the square brackets, only the rows resp. columns for which the expression is TRUE are returned."

dat[1:3, c(TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE)]

'You need to take care that the number of elements exactly matches the number of rows or columns, otherwise "vector recycling" will apply and this is probably unintended. Thus explicitly specifying a boolean selection like above is not all that useful. However, many R functions are "vectorized" and applying a logical expression or function to an entire column gives a vector of TRUE and FALSE values of the same length. If we place this vector into the square brackets, only the rows resp. columns for which the expression is TRUE are returned.'

    dat[ , 2]
    dat[ , 2] > 4          # See how this creates a vector
dat[dat[ , 2] > 4, 1:3]

'Expressions can be combined with the "&" (and) and the "|" (or) operators.'

    dat[ , 4] > 0
                    dat[ , 5] < 0
    dat[ , 4] > 0 & dat[ , 5] < 0
dat[dat[ , 4] > 0 & dat[ , 5] < 0, ]

"In this context, the any() and all() functions may be useful. But take care - you can't simply apply them to a range of columns: that would apply the condition to all elements of a selection at once. You need to use the apply() function to first return a vector. apply()'s second argument switches between row-wise and column-wise evaluation. Here, 1 means operate on rows."

    apply(dat[ , 4:8], 1, max)           # row-wise, fetch the maximum
    apply(dat[ , 4:8], 1, max) > 1       # max() > 1 ?
dat[apply(dat[ , 4:8], 1, max) > 1, ]

"To use any() and all(), we define our own function."

myF <- function(x){any(x > 1.5)}
myF(dat[3, 4:8])

    apply(dat[ , 4:8], 1, myF)
dat[apply(dat[ , 4:8], 1, myF), ]

'But we can also write the definition "in place"... '
    apply(dat[ , 4:8], 1, function(x){all(x < 0.5)})
                         #-------------------------
dat[apply(dat[ , 4:8], 1, function(x){all(x < 0.5)}), ]

# ====== String matching expressions

"The function grep(), and the %in% operator can be used to subset via string matching:"

    grep("r", dat[ , 3])          # types that contain "r"
dat[grep("r", dat[ , 3]), 1:3]

    grep("^c", dat[ , 3])         # types that begin with "c"
dat[grep("^c", dat[ , 3]), 1:3]


scary <- c("spider", "centipede")
    dat[ , 3] %in% scary
dat[dat[ , 3] %in% scary, 1:3]



# ===== Subsetting by name ===========================================

"If rownames and/or columnnames have been defined, we can use these for selection. If not defined, they default to the row/column numbers as character strings(!)."

rownames(dat)  # the row numbers, but note that they are strings!
colnames(dat)  # the ones we have defined

"If we place a string or a vector of strings into the brackets, R matches the corresponding row/ column names:"

dat[1:5, "name"]
dat[1:5, c("name", "legs")]
dat[1:5, "eyes"]   # error, that name does not exist

"We can combine the techniques e.g. to flexibly select columns. Here we select the X1 to X5 columns:"

                                  colnames(dat)
                       grep("^X", colnames(dat))
         colnames(dat)[grep("^X", colnames(dat))]
dat[1:3, colnames(dat)[grep("^X", colnames(dat))]]

'This is very useful when the exact position of columns may have changed during the analysis. Actually, rows and columns should really never be selected by number even though we have done so above. Such numbers are "magic numbers" and code that relies on such magic numbers is heard to read and very hard to maintain. It is always better to expose the logic with which your columns are selected and to make the selection explicit and robust. An exception may be when you need a slice of the data for testing purposes, but even then it may be preferrable to use the head() or tail() functions.'

# ===== The "$" operator

'The "$" operator returns a single column as a vector. It is not strictly necessary - the column can just as well be named in quotation marks within the brackets - but I think it makes for more readable code. '
dat[1:3, "legs"]
dat$legs[1:3]    # same result. This is the preferred version.
dat$"legs"[1:3]  # works, but isn't necessary
dat[1:3, legs]   # this returns an error - hopefully; but if for any
                 # reason the object DOES exist, you'll get an un-
                 # expected result. Know when to quote!


"Three more functions that I use all the time for data manipulation:"
?which
?unique
?duplicated



# ====================================================================
#        PART TWO: APPLICATION
# ====================================================================

# ===== reading and preprocessing a dataset ==========================

"After this introduction/review, it is your turn to put things into practice. I have included a dataset with this project, a .csv file taken from supplementary data of a paper on tissue definition by single cell RNA seq, by Jaitin et al. (2014).

   http://www.ncbi.nlm.nih.gov/pubmed/24531970

This data set contains log values of expression changes in different cell types, responding to lipopolysaccharide stimulation. It was posted as an Excel file.  I have simply opened that file, and saved it as .csv, unchanged.

First we open the file and have a look what it contains. Then we will properly read it into an R object."

rawDat <- read.csv("Jaitin_2014-table_S3.csv",
                   header = FALSE,
                   stringsAsFactors = FALSE)

'The object "rawDat" should appear in the Data section of the Environment tab in the top-right pane. It has a spreadsheet symbol next to it. Click that - or type View(rawDat), and study the object. You should find:
   - all columns are named Vsomething
   - rows 1 to 6 do not contain data
   - there is not a single row that could be used for column names
   - type str(rawDat): all columns are characters.

This all needs to be fixed.
'

LPSdat <- rawDat[-(1:6), ]  # drop first six rows
colnames(LPSdat) <- c("genes",      # gene names
                      "B.ctrl",     # Cell types are taken from
                      "B.LPS",      # Figure 4 of Jaitin et al.
                      "MF.ctrl",    # .ctrl and .LPS refer to control
                      "MF.LPS",     #   and LPS challenge
                      "NK.ctrl",    # The cell types are:
                      "NK.LPS",     #   B:    B-cell
                      "Mo.ctrl",    #   MF:   Macrophage
                      "Mo.LPS",     #   NK:   Natural killer cell
                      "pDC.ctrl",   #   Mo:   Monocyte
                      "pDC.LPS",    #   pDC:  plasmacytoid dendritic cell
                      "DC1.ctrl",   #   DC1:  dendritic cell subtype 1
                      "DC1.LPS",    #   DC2:  dendritic cell subtype 2
                      "DC2.ctrl",   #
                      "DC2.LPS",    #
                      "cluster")    # Gene assigned to cluster by authors
rownames(LPSdat) <- 1:nrow(LPSdat)

for (i in 2:ncol(LPSdat)) { # convert number columns to numeric
   LPSdat[,i] <- as.numeric(LPSdat[ ,i])
}

# confirm
head(LPSdat)
str(LPSdat)

# ===== Your turn ... ================================================
"Here are questions for you to code. My suggested answers are included ... you need to scroll down to see them. Obviously this is pointless unless you really try to solve this yourself."

# get rows 1:10 of the first two columns of LPSdat


#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
LPSdat[c(1,2,3,4,5,6,7,8,9,10), c(1,2)]  # Awkward solution
1:10    # use range operators instead
1:2

LPSdat[1:10, 1:2]


# output rows 1:10 of the first two columns in reverse order


#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
       10:1
LPSdat[10:1, 1:2]

# rows 1:10 of the first two columns in reverse order,
# but not the third row of the result



#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
 LPSdat[10:1, 1:2]             # as before
(LPSdat[10:1, 1:2])[-3, ]      # then exclude the third row


# rows 1:10 of the first two columns in random order
#     hint: use sample()


 #
 #
 #
 #
 #
 #
 #
 #
 #
 #
 #
 #
 #
 #
 #
 #
 #
 #
 #
       sample(1:10)
LPSdat[sample(1:10), 1:2]

# rows 1:10 of the first two columns, ordered by
# the value in the second column, ascending
#     hint: use order()


#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
             LPSdat[1:10,2]
       order(LPSdat[1:10,2])
LPSdat[order(LPSdat[1:10,2]), 1:2]

# rows 1:10 of the column named Mo.LPS


#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
LPSdat[1:10, "Mo.LPS"]   # two possibilities
LPSdat$Mo.LPS[1:10]      # I prefer this one


# rows 1:10 of the columns named Mo.LPS and Mo.ctrl


#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
LPSdat[1:10, c("Mo.LPS", "Mo.ctrl")]              # this will do

# all genes with gene-names that are three characters long
# hint: use the function nchar()


#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
                   LPSdat$genes
             nchar(LPSdat$genes)
             nchar(LPSdat$genes) == 3
LPSdat$genes[nchar(LPSdat$genes) == 3]

# column 1:2 of all rows with gene-names that contain
# the string "Il" (i.e. an interleukin)


#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# Try this first:
grep("Il", "IlInThisString")
grep("Il", "NoneInThisString")   # not


       grep("Il", LPSdat$genes)
LPSdat[grep("Il", LPSdat$genes), 1:2]

# all genes for which B-cells are stimulated by LPS by
# more than 2 log units.


#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
        LPSdat$B.LPS - LPSdat$B.ctrl
       (LPSdat$B.LPS - LPSdat$B.ctrl) > 2
LPSdat[(LPSdat$B.LPS - LPSdat$B.ctrl) > 2, 1:3]


"That's it. If you have any intersting ideas about further subsetting and filtering, or simply questions about any of this material, drop me a line so we can work this out and improve the tutorial."


# ===== Just for fun =================================================

"Finally, let's plot a heatmap of the data, first subtracting the .ctrl values from .LPS values, then picking every gene for which at least value has a more than two-foild expression change."

diffMat <- matrix(numeric(nrow(LPSdat) * 7), ncol = 7)
for (i in 1:7) {
   diffMat[ , i] <- LPSdat[ , (2*i)+1] - LPSdat[ , (2*i)]
}
colnames(diffMat) <- c("B",
                       "MF",
                       "NK",
                       "Mo",
                       "pDC",
                       "DC1",
                       "DC2")
selection <- apply(diffMat, 1, function(x) {any(abs(x) > 2)})
boxplot(diffMat[seq(1, nrow(LPSdat), by = 3), ])
rgcol <- colorRampPalette(c("#FF0000", "#000000", "#00FF00"))
heatmap(diffMat[seq(1, nrow(LPSdat), by = 3), ], col = rgcol(256))

"Fine. But what does this mean?"


# ====================================================================
#        APPENDIX: OUTLOOK
# ====================================================================
"There are many more function for data preparation that this tutorial did not cover. You should know about the following functions:"

?subset   # ... better not used in programs however
?match
?aggregate
?transform
?sweep
?with     # ... and within()

"And you should know about the following packages:

   https://cran.r-project.org/web/packages/plyr/
   https://cran.r-project.org/web/packages/dplyr/
   https://cran.r-project.org/web/packages/magrittr/
"



# [END]
