library(ggplot2)
library(dplyr)

#Import necessary libraries

library(MASS)

#Generate samples based on MCMC algorithm

metro <- function(target, N, x, burnin = 0, sd) {
  samples <- x
  for (i in 2:(burnin + N)) {
    proposal <- mvrnorm(n = 1, x, sd)
    if (runif(1) < min(1, target(proposal)/target(x))) {
        x <- proposal
    }
    samples <- rbind(samples, x)
  }
  samples[(burnin + 1):(N + burnin),]
}

#Not run

#Test 1

#Probability density function p1

f <- function(X) {
  0.4*dnorm(x, -1, 0.5) +
  0.6*dnorm(x, 2, 2)
}

#Plot of p1

curve(f(x), col = "red", -4, 8, n = 301, las = 1)

#Generate samples of p1

metro_sample <- metro(f, 10000, 0, 1000, sd = 1)

#Histogram and density plot of above samples

hist(metro_sample, 50, freq = FALSE, main = "", las = 1)
lines(density(metro_sample), col = "red")

#Trace plot of above samples

plot(as.vector(metro_sample), type = "l", xlab = "Iteration", ylab = "x")

#Test 2

#Probability density function p2

make.mvn <- function(mean, vcv) {
  logdet <- as.numeric(determinant(vcv, TRUE)$modulus)
  tmp <- length(mean) * log(2 * pi) + logdet
  vcv.i <- solve(vcv)
  
  function(x) {
    dx <- x - mean
    exp(-(tmp + rowSums((dx %*% vcv.i) * dx))/2)
  }
}

mu1 <- c(-1, 1)
mu2 <- c(2, -2)
vcv1 <- matrix(c(1, .25, .25, 1.5), 2, 2)
vcv2 <- matrix(c(2, -.5, -.5, 2), 2, 2)
f1 <- make.mvn(mu1, vcv1)
f2 <- make.mvn(mu2, vcv2)

f <- function(x) {
  f1(x) + f2(x)
}

#Plot of p2

x <- seq(-5, 6, length=71)
y <- seq(-7, 6, length=61)
xy <- expand.grid(x=x, y=y)
z <- matrix(apply(as.matrix(xy), 1, f), length(x), length(y))
image(x, y, z, las=1)
contour(x, y, z, add=TRUE)

#Generate samples of p2

sample_2 <- metro(f, 1000, c(-4, -4), 100, sd = diag(1))

#Trace plot of above samples

image(x, y, z, las=1)
contour(x, y, z, add=TRUE)
lines(sample_2[,1], sample_2[,2], col="#00000088")

#Histogram and density plot of above samples

par(mfcol=c(1,2))
hist(sample_2[,1], 50, freq = FALSE, main = "", las = 1, xlab = "x")
lines(density(sample_2[,1]), col = "red")
hist(sample_2[,2], 50, freq = FALSE, main = "", las = 1, xlab = "y")
lines(density(sample_2[,2]), col = "red")