# An intercept only model


BGLR fits Gaussian models of the form

$$y=1\mu+X_1\beta_1+X_2\beta_2+...+u_1+u+2+...+\varepsilon$$

where $y$ ($n \times 1$) is a vector of phenotypes, $\mu$ is an intercept, $X_j$ are incidence matrices for each of the $\beta_j$'s, $u_k$ are vectors of random effects, and $\varepsilon$ is a vector of error terms, which are assumed to be Gaussian and independent.

The terms of the linear predictor ($1\beta_1+X_2\beta_2+...+u_1+u+2$) are specified through the argument `ETA`, when this term is not included in the model, by default, BGLR fits an intercept model of the form

$$y=1\mu+\varepsilon.$$


**Simulating posterior samples for an intercept only model**

<!--kb
id: intercept-only-model
agent: coding
package: BGLR
prompt: Fit an intercept-only model using BGLR.
-->

The following script shows how to fit this model, which will estimate $\mu$ and $Var(\varepsilon)=\sigma^2_{\varepsilon}$.

```r
 library(BGLR)

 # simulating data
  mu=123
  n=1000
  error=rnorm(n,sd=2)
  y=mu+error

# fitting the model
 fm=BGLR(y=y, nIter=6000,burnIn=1000, verbose=FALSE)
```

**Retrieving posterior means and posterior SDs.**


<!--kb
id: intercept-only-model-extract-estimates
agent: coding
package: BGLR
prompt: Extract posterior means of the intercept and error variance of a model using BGLR.
-->

The following script shows how to retrieve posterior means and posterior SD of the intercetp and the error variance.

```r
 # Intercept
  fm$mu #posterior mean
  fm$SD.mu $ posterior SD

 # Error variance
  fm$varE # posterior mean
  fm$SD.varE # posterior SD
```

