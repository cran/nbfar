% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nbfar.R
\name{nbfar}
\alias{nbfar}
\title{Negative binomial co-sparse factor regression  (NBFAR)}
\usage{
nbfar(
  Yt,
  X,
  maxrank = 3,
  nlambda = 40,
  cIndex = NULL,
  ofset = NULL,
  control = list(),
  nfold = 5,
  PATH = FALSE,
  nthread = 1,
  trace = FALSE,
  verbose = TRUE
)
}
\arguments{
\item{Yt}{response matrix}

\item{X}{design matrix; when X = NULL, we set X as identity matrix and perform generalized sparse PCA.}

\item{maxrank}{an integer specifying the maximum possible rank of the coefficient matrix or the number of factors}

\item{nlambda}{number of lambda values to be used along each path}

\item{cIndex}{specify index of control variables in the design matrix X}

\item{ofset}{offset matrix or microbiome data analysis specific scaling: common sum scaling = CSS (default), total sum scaling = TSS, median-ratio scaling = MRS, centered-log-ratio scaling  = CLR}

\item{control}{a list of internal parameters controlling the model fitting}

\item{nfold}{number of folds in k-fold crossvalidation}

\item{PATH}{TRUE/FALSE for generating solution path of sequential estimate after cross-validation step}

\item{nthread}{number of thread to be used for parallelizing the crossvalidation procedure}

\item{trace}{TRUE/FALSE checking progress of cross validation error}

\item{verbose}{TRUE/FALSE checking progress of estimation procedure}
}
\value{
\item{C}{estimated coefficient matrix; based on GIC}
\item{Z}{estimated control variable coefficient matrix}
\item{Phi}{estimted dispersion parameters}
\item{U}{estimated U matrix (generalize latent factor weights)}
\item{D}{estimated singular values}
\item{V}{estimated V matrix (factor loadings)}
}
\description{
To estimate a low-rank and sparse coefficient matrix in large/high dimensional setting, the approach extracts unit-rank components of required matrix in sequential order. The algorithm automatically stops after extracting sufficient unit rank components.
}
\examples{
\donttest{
## Model specification:
SD <- 123
set.seed(SD)
p <- 100; n <- 200
pz <- 0
nrank <- 3                # true rank
rank.est <- 5             # estimated rank
nlam <- 20                # number of tuning parameter
s  = 0.5
q <- 30
control <- nbfar_control()  # control parameters
#
#
## Generate data
D <- rep(0, nrank)
V <- matrix(0, ncol = nrank, nrow = q)
U <- matrix(0, ncol = nrank, nrow = p)
#
U[, 1] <- c(sample(c(1, -1), 8, replace = TRUE), rep(0, p - 8))
U[, 2] <- c(rep(0, 5), sample(c(1, -1), 9, replace = TRUE), rep(0, p - 14))
U[, 3] <- c(rep(0, 11), sample(c(1, -1), 9, replace = TRUE), rep(0, p - 20))
#
  # for similar type response type setting
  V[, 1] <- c(rep(0, 8), sample(c(1, -1), 8,
    replace =
      TRUE
  ) * runif(8, 0.3, 1), rep(0, q - 16))
  V[, 2] <- c(rep(0, 20), sample(c(1, -1), 8,
    replace =
      TRUE
  ) * runif(8, 0.3, 1), rep(0, q - 28))
  V[, 3] <- c(
    sample(c(1, -1), 5, replace = TRUE) * runif(5, 0.3, 1), rep(0, 23),
    sample(c(1, -1), 2, replace = TRUE) * runif(2, 0.3, 1), rep(0, q - 30)
  )
U[, 1:3] <- apply(U[, 1:3], 2, function(x) x / sqrt(sum(x^2)))
V[, 1:3] <- apply(V[, 1:3], 2, function(x) x / sqrt(sum(x^2)))
#
D <- s * c(4, 6, 5) # signal strength varries as per the value of s
or <- order(D, decreasing = TRUE)
U <- U[, or]
V <- V[, or]
D <- D[or]
C <- U \%*\% (D * t(V)) # simulated coefficient matrix
intercept <- rep(0.5, q) # specifying intercept to the model:
C0 <- rbind(intercept, C)
#
Xsigma <- 0.5^abs(outer(1:p, 1:p, FUN = "-"))
# Simulated data
sim.sample <- nbfar_sim(U, D, V, n, Xsigma, C0,disp = 3, depth = 10)  # Simulated sample
# Dispersion parameter
X <- sim.sample$X[1:n, ]
Y <- sim.sample$Y[1:n, ]
X0 <- cbind(1, X)                     # 1st column accounting for intercept

# Model with known offset
set.seed(1234)
offset <- log(10)*matrix(1,n,q)
control_nbfar <- nbfar_control(initmaxit = 5000, gamma0 = 2, spU = 0.5,
spV = 0.6, lamMinFac = 1e-10, epsilon = 1e-5)
# nbfar_test <- nbfar(Y, X, maxrank = 5, nlambda = 20, cIndex = NULL,
# ofset = offset, control = control_nbfar, nfold = 5, PATH = F)
}
}
\references{
Mishra, A., Müller, C. (2022) \emph{Negative binomial factor regression models with application to microbiome data analysis.  https://doi.org/10.1101/2021.11.29.470304}
}
