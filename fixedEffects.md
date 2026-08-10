# Fixed Effects Model with BGLR

## Key concepts

- Linear regression with factors and covariates
- Model specification using a formula interface versus pre-built incidence matrices
- Using flat priors in a regression model
- Posterior means, posterior SDs
- Convergence assessment

---

## Fitting a linear regression in BGLR using a flat prior

### Formula interface

<!--kb
id: fixedeffects-fit-formula
agent: coding
prompt: Fit a linear regression of wage on education, region, sex, ethnicity, experience, and union status using BGLR with a formula interface.
requires: [DATA]
produces: [fmB]
tags: {function: BGLR, model_family: fixed_effects, interface: formula}
alt_of: [fixedeffects-fit-incidence]
see_also: [fixedeffects-fit-incidence, posthoc-coef-manual, posthoc-errorvar-summary]
-->

BGLR mirrors the syntax of base-R `lm()`, but the model is specified through a
linear predictor list (`ETA`) rather than a single formula. Internally, BGLR
calls `model.matrix()` on the formula to build the incidence matrix.

```r
# Reading the data
folder <- 'https://raw.githubusercontent.com/QuantGen/BGLR_AI/refs/heads/main/DATA/'
fname  <- 'wages.txt'
DATA   <- read.table(paste0(folder, '/', fname), header = TRUE, sep = '')

library(BGLR)

# lm equivalent, for reference
fmLM <- lm(wage ~ education + region + sex + ethnicity + experience + union, data = DATA)

# BGLR: ETA is a 2-level list; formula interface calls model.matrix() internally
LP <- list(predictors = list(~education + region + sex + ethnicity + experience + union,
                              model = "FIXED",
                              data = DATA))

fmB <- BGLR(y = DATA$wage, ETA = LP, nIter = 12000, burnIn = 2000, verbose = FALSE)
```

**See also:** [Incidence-matrix version](#incidence-matrix-interface) · [Extract coefficients](#coefficients-manual-extraction) · [Error variance summary](#posterior-mean-and-sd)

---

### Incidence matrix interface

<!--kb
id: fixedeffects-fit-incidence
agent: coding
prompt: Fit the same fixed-effects regression in BGLR, but by passing a pre-built incidence matrix instead of a formula.
requires: [DATA]
produces: [fmB2]
tags: {function: BGLR, model_family: fixed_effects, interface: incidence_matrix}
alt_of: [fixedeffects-fit-formula]
see_also: [fixedeffects-fit-formula, posthoc-coef-comparison]
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

fmB2 <- BGLR(y = DATA$wage, ETA = LP, nIter = 12000, burnIn = 2000, verbose = FALSE)
```

**See also:** [Formula version](#formula-interface) · [Compare coefficients across both fits](#compare-coefficients-across-interfaces)

---

## Output retrieval and formatting

### Coefficients — manual extraction

<!--kb
id: posthoc-coef-manual
agent: posthoc
prompt: Extract posterior means and posterior SDs of the regression coefficients from a fitted BGLR model, including the intercept.
requires: [fmB]
produces: [RES.BAYES]
tags: {output_type: coefficients, object_class: BGLR_fit, model_family: fixed_effects}
alt_of: [posthoc-coef-helper]
see_also: [fixedeffects-fit-formula, posthoc-coef-helper]
-->

```r
# lm, for reference
RES <- summary(fmLM)$coef[, 1:2]

# Posterior means and posterior SDs of the regression coefficients
RES.BAYES <- cbind(fmB$ETA$predictors$b, fmB$ETA$predictors$SD)
colnames(RES.BAYES) <- c('Post-mean', 'Post-SD')

# Add the intercept (stored separately on the fitted object)
RES.BAYES <- rbind('Intercept' = c(fmB$mu, fmB$SD.mu), RES.BAYES)
```

**See also:** [Simpler: `coef.BGLR()` helper](#coefficients-via-coefbglr-helper)

---

### Coefficients via `coef.BGLR()` helper

<!--kb
id: posthoc-coef-helper
agent: posthoc
prompt: Extract posterior means and SDs of regression coefficients from a fitted BGLR model using the coef.BGLR() helper function, instead of extracting them manually.
requires: [fmB, utils.r sourced]
produces: [coefficient table]
tags: {output_type: coefficients, method: helper_function}
alt_of: [posthoc-coef-manual]
preferred_when: "utils.r is available in the environment"
see_also: [posthoc-coef-manual]
-->

```r
source('https://raw.githubusercontent.com/QuantGen/BGLR_AI/refs/heads/main/utils/utils.r')
coef.BGLR(fmB)
```

---

### Posterior mean and SD (error variance)

<!--kb
id: posthoc-errorvar-summary
agent: posthoc
prompt: Get the posterior mean and posterior SD of the residual (error) variance from a fitted BGLR model.
requires: [fmB]
produces: [error variance summary]
tags: {output_type: summary, parameter: error_variance}
see_also: [posthoc-errorvar-trace, posthoc-errorvar-interval]
-->

```r
c('Post-mean' = fmB$varE, 'Post-SD' = fmB$SD.varE)
```

---

### Trace plot of the error variance

<!--kb
id: posthoc-errorvar-trace
agent: posthoc
prompt: Plot the MCMC trace of the error variance, with the posterior mean overlaid, to assess convergence.
requires: [fmB, "varE.dat (side-effect file written to disk during fitting)"]
produces: [vE]
tags: {output_type: diagnostic_plot, display: trace_plot, parameter: error_variance}
see_also: [posthoc-errorvar-summary, posthoc-errorvar-interval]
note: >
  varE.dat is written to the working directory during MCMC sampling, not
  stored on the fmB object itself. Requires the fitting run to have already
  completed in the same working directory.
-->

```r
vE <- scan('varE.dat')

plot(vE, type = 'o', col = 4)
abline(h = fmB$varE, col = 2, lty = 2, v = fmB$burnIn / fmB$thin, lwd = 2)
```

---

### Posterior credibility interval

<!--kb
id: posthoc-errorvar-interval
agent: posthoc
prompt: Compute a 95% posterior credibility interval for the error variance, removing burn-in samples.
requires: [vE (raw, pre-burn-in-removal; from posthoc-errorvar-trace)]
produces: [CR]
tags: {output_type: interval_estimate, method: quantile, parameter: error_variance}
see_also: [posthoc-errorvar-trace, posthoc-errorvar-density]
note: >
  Uses simple quantiles here; highest-posterior-density intervals are an
  alternative (see coda::HPDinterval()).
-->

```r
# Remove burn-in
vE <- vE[-c(1:(fmB$burnIn / fmB$thin))]
CR <- quantile(vE, prob = c(0.025, 0.975))
```

---

### Posterior density plot

<!--kb
id: posthoc-errorvar-density
agent: posthoc
prompt: Plot the posterior density of the error variance with the 95% credibility interval marked.
requires: [vE (burn-in removed), CR]
produces: [density plot]
tags: {output_type: display, display: density_plot, parameter: error_variance}
see_also: [posthoc-errorvar-interval]
-->

```r
plot(density(vE), col = 4)
abline(v = CR, col = 2)
```

---

### Compare coefficients across interfaces

<!--kb
id: posthoc-coef-comparison
agent: posthoc
prompt: Compare coefficient estimates from the formula-interface fit and the incidence-matrix fit, to confirm the two approaches agree.
requires: [fmB, fmB2, utils.r sourced]
produces: [comparison output]
tags: {output_type: comparison, purpose: validation}
see_also: [fixedeffects-fit-formula, fixedeffects-fit-incidence, posthoc-coef-helper]
-->

```r
coef.BGLR(fmB)
coef.BGLR(fmB2)
```

*The two fits specify the same model — one via formula, one via a pre-built
incidence matrix — so the coefficient estimates should match up to Monte
Carlo error.*
