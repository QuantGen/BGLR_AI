# Fixed Effects Model with BGLR

## Key concepts
- Linear regression with factors and covariates
- Model specification using a formula interface versus pre-built incidence matrices
- Using flat priors in a regression model
- Posterior means, posterior SDs
- Convergence assessment

## Fitting a linear regression in BGLR using a flat prior

### Formula interface
<!--ch_start
<!--kb
id: fixedeffects-fit-formula
agent: coding
package: BGLR
prompt: Fit a linear regression with flat priors (aka fixed effects) using BGLR with a formula interface.
-->

This example illustrates how to fit a linear regression of an outcome (wages) on factors (e.g., sex) and quantitative predictors (aka covariates, e.g., education) whose effects are assigned flat priors. In the example the linear predictor of the model (`ETA`) is specified using a formula.

```r
# Reading the data
folder <- 'https://raw.githubusercontent.com/QuantGen/BGLR_AI/refs/heads/main/data'
fname  <- 'wages.txt'
DATA   <- read.table(paste0(folder, '/', fname), header = TRUE, sep = '')

library(BGLR)

# BGLR: ETA is a 2-level list; formula interface calls model.matrix() internally
LP <- list(predictors = list(~education + region + sex + ethnicity + experience + union,
                              model = "FIXED",
                              data = DATA))

fm <- BGLR(y = DATA$wage, ETA = LP, nIter = 12000, burnIn = 2000, verbose = FALSE)
```



### Incidence matrix interface

<!--kb
id: fixedeffects-fit-incidence-matrix
agent: coding
package: BGLR
prompt: Fit a fixed-effects regression in BGLR using a pre-built incidence matrix.
-->

When a formula is used, BGLR builds the incidence matrix for you via
`model.matrix()`. In many cases — e.g. regression on SNPs — it's better to
build and pass that matrix directly. This example fits the same model as
above, constructing the design matrix outside BGLR.

```r
# Note: drop the intercept column; BGLR always includes its own intercept.
XF <- model.matrix(~education + region + sex + ethnicity + experience + union,
                    data = DATA)[, -1]

LP <- list(predictors = list(X = XF, model = "FIXED", data = DATA))

fm2 <- BGLR(y = DATA$wage, ETA = LP, nIter = 12000, burnIn = 2000, verbose = FALSE)
```


## Output retrieval and formatting

As BGLR runs, it saves posterior samples (see files with `.dat` extension) once the sampling process has finished it computes posterior means and posterior

### Coefficients — manual extraction

<!--kb
id: posthoc-coef-manual-extraction
agent: posthoc
package: BGLR
prompt: Extract posterior means and posterior SDs of the regression coefficients from a fitted BGLR model, including the intercept.
-->

This script shows how to extract the estimated coefficients from the fitted model by accessing the elements of the object that holds esitmates and posterior SD.

```r
# Posterior means and posterior SDs of the regression coefficients
RES.BAYES <- cbind(fmB$ETA$predictors$b, fmB$ETA$predictors$SD)
colnames(RES.BAYES) <- c('Post-mean', 'Post-SD')

# Add the intercept (stored separately on the fitted object)
RES.BAYES <- rbind('Intercept' = c(fmB$mu, fmB$SD.mu), RES.BAYES)
```

### Coefficients via `coef.BGLR()` helper

<!--kb
id: coef.BGLR-use
agent: posthoc
package: BGLR
prompt: Extract posterior means and SDs of regression coefficients from a fitted BGLR model using the coef.BGLR() helper function, instead of extracting them manually.
-->

The function `coef.BGLR()` can be used to extract the estimated coefficients and their posterior SD.

```r
source('https://raw.githubusercontent.com/QuantGen/BGLR_AI/refs/heads/main/utils/utils.r')
coef.BGLR(fmB)
```

### Posterior mean and SD (error variance)

<!--kb
id: posthoc-errorvar-summary
agent: posthoc
package: BGLR
prompt: Get the posterior mean and posterior SD of the residual (error) variance from a fitted BGLR model.
-->

```r
c('Post-mean' = fmB$varE, 'Post-SD' = fmB$SD.varE)
```

### Trace plot of the error variance

<!--kb
id: posthoc-errorvar-trace-plot
agent: posthoc
package: BGLR
prompt: Plot the MCMC trace of the error variance, with the posterior mean overlaid, to assess convergence.
-->

```r
 vE <- scan('varE.dat')
 plot(vE, type = 'o', col = 4)
 abline(h = fmB$varE, col = 2, lty = 2, v = fmB$burnIn / fmB$thin, lwd = 2)
```

### Posterior credibility interval

<!--kb
id: posthoc-errorvar-interval
agent: posthoc
package: BGLR
prompt: Compute a 95% posterior credibility interval for the error variance, removing burn-in samples.
-->

The following script uses posterior samples to compute 95% posterior credibility intervals. Here we use the `quantile()` function. An alternative would be to use `HPD.intervals()` from the `coda` R-package. Note that the burn-in period is removed before the intervals are calculated. 

```r
# Remove burn-in
vE <- vE[-c(1:(fmB$burnIn / fmB$thin))]
CR <- quantile(vE, prob = c(0.025, 0.975))
```


### Posterior density plot

<!--kb
id: posthoc-errorvar-density
agent: posthoc
package: BGLR
prompt: Plot the posterior density of the error variance with the 95% credibility interval marked.
-->

The script shows how to construct a posterior density plot from posterior samples, in this case for the error variance. 

```r
plot(density(vE), col = 4)
abline(v = CR, col = 2)
```

