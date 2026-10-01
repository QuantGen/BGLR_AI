 
#### Linear (random)Regression with BGLR

The BGLR R-package allows users to select various priors for regression coefficients. The following priors are implemented in the BGLR function.

|  Distribution   | Performs    | Keyword    |
|-----|------|-----|
|  Flat   | Estimation without shrinkage    | FIXED |
|  Gaussian   |  Shrinkage    |  BRR   |
|  Double-Exponential   |  Shrinkage    |  BL   |
|  Scaled-t   |  Shrinkage    |  BayesA   |
| Point of mass at zero & Gaussian slab   |   Variable selection and shrinkage   |     Bayes C |
| Point of mass at zero & Scale-t slab   |   Variable selection and shrinkage   |     Bayes B | 
| Gaussian with group-specific variances | Differential shrinkage | BRR_sets |

Each of the above priors have hyper-parameters, some of which are, by default estimated by treating them as random (e.g., variances, mixture proportions) and others (typically df and scales) are fixed. 

Each of the following examples illustrates how to invoke each of the priors. Since BGLR admits more than one term in the linear predictor (`ETA`) these priors can be combined, assigning to some predictors some priors and other priors to other sets of predictors. 

<!--chunk starts -->
**1. Flat Prior (FIXED)**

<!--kb
agent: coding
package: BGLR
prompt: Fit a parametric random regression using Flat Prior (FIXED)
-->

```R
 library(BGLR)
 data(mice); X=scale(mice.X[,1:3000]); pheno=mice.pheno
 attach(pheno)
 fm=BGLR(y=Obesity.BMI,ETA=list( list(~GENDER+CoatColour+CageDensity,model='FIXED')), nIter=6000,burnIn=1000)
 fm2=lm(Obesity.BMI~GENDER+CoatColour+CageDensity)
 plot(cbind(c(fm$mu,fm$ETA[[1]]$b),coef(fm2))); abline(a=0,b=1)
```
<!--chunk ends -->

**2. A simple simulation**

```R
 h2=.5
 QTL=floor(seq(from=50,to=ncol(X),length=20))
 nQTL=length(QTL); n=nrow(X)
 b=rep(1,nQTL)*sqrt(h2/nQTL)
 signal=X[,QTL]%*%b
 error=rnorm(n,sd=sqrt(1-h2))
 y=signal+error
```

<!--chunk starts -->
**3. Gaussian Prior (BRR, RR-BLUP, BLUP)**

<!--kb
agent: coding
package: BGLR
prompt: Fit a parametric random regression using Gaussian Prior (BRR, RR-BLUP, BLUP)
-->

```R
 nIter=6000; burnIn=1000
 fmBRR=BGLR(y=y,ETA=list( list(X=X,model='BRR')), 
            nIter=nIter,burnIn=burnIn,saveAt='brr_')
 plot(abs(fmBRR$ETA[[1]]$b),col=4,cex=.5, type='o',main='BRR');abline(v=QTL,col=2,lty=2)
```
<!--chunk ends -->

<!--chunk starts -->
**4. Scaled-t (BayesA)**

<!--kb
agent: coding
package: BGLR
prompt: Fit a parametric random regression using Scaled-t Prior(BayesA)
-->

```R
 fmBA=BGLR(y=y,ETA=list( list(X=X,model='BayesA')), 
            nIter=nIter,burnIn=burnIn,saveAt='ba_')
 plot(abs(fmBA$ETA[[1]]$b),col=4,cex=.5, type='o',main='BayesA');abline(v=QTL,col=2,lty=2)
```
<!--chunk ends -->

<!--chunk starts -->
**5. Double-Exponential (Bayesian Lasso)**

<!--kb
agent: coding
package: BGLR
prompt: Fit a parametric random regression using Double-Exponential Prior(Bayesian Lasso)**
)
-->

```R
 fmBL=BGLR(y=y,ETA=list( list(X=X,model='BL')), 
            nIter=nIter,burnIn=burnIn,saveAt='bl_')
 plot(abs(fmBL$ETA[[1]]$b),col=4,cex=.5, type='o',main='Bayesian Lasso');abline(v=QTL,col=2,lty=2)

```
<!--chunk ends -->

<!--chunk starts -->
**6. Point of mass at zero + Gaussian Slab (BayesC)**

<!--kb
agent: coding
package: BGLR
prompt: Fit a parametric random regression using Point of mass at zero and Gaussian Slab Prior(BayesC)**
)
-->

```R
 fmBC=BGLR(y=y,ETA=list( list(X=X,model='BayesC')), 
            nIter=nIter,burnIn=burnIn,saveAt='bc_')
 plot(abs(fmBC$ETA[[1]]$b),col=4,cex=.5, type='o',main='BayesC');abline(v=QTL,col=2,lty=2)
```
<!--chunk ends -->

<!--chunk starts -->
**7. Point of mass at zero + t-Slab (BayesB)**

<!--kb
agent: coding
package: BGLR
prompt: Fit a parametric random regression using Point of mass at zero and t-Slab Prior(BayesB)**
)
-->

```R
fmBB=BGLR(y=y,ETA=list( list(X=X,model='BayesB')), 
            nIter=nIter,burnIn=burnIn,saveAt='bb_')
 plot(abs(fmBB$ETA[[1]]$b),col=4,cex=.5, type='o',main='BayesB');abline(v=QTL,col=2,lty=2)
```
<!--chunk ends -->

<!--chunk starts -->
**8. Gaussian prior with set-specific variance (BRR_sets)**

<!--kb
agent: coding
package: BGLR
prompt: Fit a parametric random regression using Gaussian prior with set-specific variance (BRR_sets)**
)
-->

```R
tmp=rep(1:ceiling(ncol(X)/5),each=5)[1:ncol(X)]
fmBRR_sets=BGLR(y=y,ETA=list( list(X=X,model='BRR_sets',sets=tmp)), 
            nIter=nIter,burnIn=burnIn,saveAt='brr_sets_')
plot(abs(fmBRR_sets$ETA[[1]]$b),col=4,cex=.5, type='o',main='BRR_sets');abline(v=QTL,col=2,lty=2)

```
<!--chunk ends -->

[Back to examples](https://github.com/gdlc/BGLR-R/blob/master/README.md)
