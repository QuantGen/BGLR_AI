# An intercept only model


BGLR fits Guassian models of the form

$$y=1\mu+X_1\beta_1+X_2\beta_2+...+u_1+u+2+...+\varepsilon$$

where $y$ ($n \times 1$) is a vector of phenotypes, $\mu$ is an intercept, $X_j$ are incidence matrices for each of the $\beta_j$'s, $u_k$ are vectors of random effects, and $\varepsilon$ is a vector of error terms, which are assumed to be Gaussian and independent.

The terms of the linear predictor ($_1\beta_1+X_2\beta_2+...+u_1+u+2$) are specified through the argument `ETA`, when this ter mis not included in the model, by default, BGLR fits an intercept model of the form

$$y=1\mu+\varepsilon.$$

The following script shows how to fit this model, which will estimate $\mu$ and $Var(\varepsilon)=\sigma^2_{\varepsilon}$.

```r
 # simulating data
  mu=123
  n=1000
  error=rnorm(n,sd=2)
  y=mu+error

# fitting the model
 fm=BGLR(y=y, nIter=6000,burnIn=1000, verbose=FALSE)

```

Retrivying posterior means and posterior SDs.

```r
 # sample meqan versus posterior mean of mu (MOM versus posterior mean)
  round(`MOM`=c(mean(y), `Bayes`=fm$mu), 4)

# Error variance (MOM versus posterior mean)
  c(`MOM`=var(y),`Bayes`=fm$varE)

```

