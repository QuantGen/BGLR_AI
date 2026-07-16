# Fixed Effects Model with BGLR


## Key concepts

 - Linear regression with factors and covariates
 - Model specification using a formula interface versus pre-build incidence matrices
 - Using flat priors in a regression model
 - Posterior means, posterior SDs
 - Convergence assessments

## Fitting a linear regression in BGLR using a flat prior 

**With a formula interface**

```r
 # Reading the data
  folder='https://raw.githubusercontent.com/QuantGen/BGLR_AI/refs/heads/main/DATA/'
  fname='wages.txt'
  DATA=read.table(paste0(folder,'/',fname),header=TRUE,sep='')

 # Libraries
  library(BGLR)

 # linear regression of wage on sex, ethnicity, age, and years of experience
  # lm
     fmLM<-lm(wage~education+region+sex+ethnicity+experience+union,data=DATA)

  # BGLR (LP=linear predictor, 2-level list, formula interface calls model.matrix internally)
     LP=list( predictors=list( ~education+region+sex+ethnicity+experience+union,
                               model="FIXED",
                               data=DATA))

     fmB<-BGLR(y=DATA$wage, ETA=LP,nIter=12000,burnIn=2000,verbose=FALSE)
```

## Output retrieval and formatting

**Coefficients**


```r
 # lm
  RES=summary(fmLM)$coef[,1:2]

# posterior means, posterior SD of regression coefficients.
  RES.BAYES=cbind( fmB$ETA$predictors$b, fmB$ETA$predictors$SD)
  colnames(RES.BAYES)=c('Post-mean','Post-SD')
  # Adding the intercept
  RES.BAYES=rbind('Intercept'=c(fmB$mu,fmB$SD.mu),RES.BAYES)

# Coefficients can also be extracted using coef.BGLR()
 source('https://raw.githubusercontent.com/QuantGen/BGLR_AI/refs/heads/main/utils/utils.r')
coef.BGLR(fmB)

```

**Error variance**

```r
  # posterior mean and posterior SD
  c('Post-mean'=fmB$varE,'Post-SD'=fmB$SD.varE)

  vE=scan('varE.dat') 

  # Trace plot
   plot(vE,type='o',col=4) ;abline(h=fmB$varE,col=2,lty=2, v=fmB$burnIn/fmB$thin,lwd=2)

  # Posteriro credibility interval
   # Removing burn-in
   vE=vE[-c(1:(fmB$burnIn/fmB$thin))]
   CR=quantile(vE,prob=c(0.025,0.975)) # could use hig-posterior density intervals, e.g. in coda HPDinterval()
  # Posterior density plot
   plot(density(vE),col=4);abline(v=CR,col=2)

```

## Using incidence matrices

When we use a formula to specify an element of the linear predictor (argument `ETA` in BGLR), internally, BGLR uses the function `model.matrix()` to generate the corresponding incidence matrix which is used to represent th emodel in terms of matrices and vectors ($y=X\beta+\varepsilon$). In many cases, e.g., regression on SNPs, rather than using a formula interface it is better to pass the incidence matrix directly to BGLR. The following example shows how to fit the same model that was used above, in this casee, creating the model matrix outside BGLR.


```r
 # Incidence matrix (note: we remove the incidence vector for the intercept because an intercept will be always included by BGLR

 XF=model.matrix(~education+region+sex+ethnicity+experience+union, data=DATA)[,-1]

 LP=list( predictors=list( X=XF, model="FIXED",data=DATA))

 fmB2<-BGLR(y=DATA$wage, ETA=LP,nIter=12000,burnIn=2000,verbose=FALSE)

 coef.BGLR(fmB)
 coef.BGLR(fmB2)
```





  
[Back to list of examples](https://github.com/QuantGen/BGLR_AI/#examples)

