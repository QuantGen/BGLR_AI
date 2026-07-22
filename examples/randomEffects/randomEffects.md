# Random Effects Model with BGLR


## Key concepts

 - Random effects with a covariance (kernel) structure
 - Specifying random effects in BGLR using `model="RKHS"`
 - Variance components and heritability
 - Posterior means and posterior SDs of random effects
 - Convergence assessments

Adapted from the [RKHS example](https://github.com/gdlc/BGLR-R/blob/master/inst/md/RKHS.md) in [BGLR-R](https://github.com/gdlc/BGLR-R).

## The model

Whereas a fixed-effects model estimates a separate constant for each predictor, a **random-effects** model treats the effects as draws from a common distribution with an estimated variance. BGLR fits Gaussian random effects of the form

$$y=1\mu+u+\varepsilon,\qquad u\sim N(0,K\sigma^2_u),\qquad \varepsilon\sim N(0,I\sigma^2_\varepsilon)$$

where $u$ is a vector of correlated random effects, $K$ is a known covariance (or kernel) matrix describing how the levels of $u$ are related, $\sigma^2_u$ is the variance of the random effects, and $\sigma^2_\varepsilon$ is the residual variance. In BGLR this is specified with `model="RKHS"`, passing the covariance matrix through the argument `K`.

## Fitting a random-effects (RKHS) model

```r
 library(BGLR)

 # Data: 599 wheat lines genotyped at 1,279 markers, evaluated in 4 environments
 # (bundled with BGLR, so no external file is needed)
  data(wheat)
  X=wheat.X
  y=wheat.Y[,1]

 # Covariance (kernel) structure among individuals
 # Gaussian kernel built from marker-derived (squared, scaled) distances
  D=as.matrix(dist(X,method="euclidean"))^2
  D=D/mean(D)
  h=1
  K=exp(-h*D)

 # Random-effects model: y = 1*mu + u + e,  with u ~ N(0, K*varU)
  ETA=list( g=list(K=K, model="RKHS") )
  fm=BGLR(y=y, ETA=ETA, nIter=6000, burnIn=1000, verbose=FALSE, saveAt="re_")
```

## Variance components and heritability

```r
 # Posterior means of the variance components
  varU=fm$ETA$g$varU     # variance of the random effects
  varE=fm$varE           # residual variance
  round( c('varU'=varU, 'varE'=varE), 4)

 # Genomic heritability = varU / (varU + varE)
  h2=varU/(varU+varE)
  round(c('h2'=h2), 4)
```

## Random-effect predictions

```r
 # Posterior means and posterior SDs of the random effects (u)
  RES=cbind('Post-mean'=fm$ETA$g$u, 'Post-SD'=fm$ETA$g$SD.u)
  head(RES)

 # The shared helper handles RKHS terms and returns the same estimates
  source('https://raw.githubusercontent.com/QuantGen/BGLR_AI/refs/heads/main/utils/utils.r')
  coef.BGLR(fm)
```

## Convergence assessment

```r
 # Trace plot of the random-effect variance
  varU=scan('re_ETA_g_varU.dat')
  plot(varU,type='o',col=4,ylab='varU'); abline(h=fm$ETA$g$varU,col=2,lty=2, v=fm$burnIn/fm$thin,lwd=2)

 # Posterior credibility interval and density (after removing burn-in)
  varU=varU[-c(1:(fm$burnIn/fm$thin))]
  CR=quantile(varU,prob=c(0.025,0.975)) # could use high-posterior density intervals, e.g. coda::HPDinterval()
  plot(density(varU),col=4,main='Posterior of varU'); abline(v=CR,col=2)
```

[← Back to examples](https://github.com/QuantGen/BGLR_AI)
