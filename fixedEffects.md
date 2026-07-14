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

**Inspecting output**


```r
 # lm
  RES=summary(fmLM)$coef[,1:2]

# posterior means, posterior SD of regression coefficients.
  RES.BAYES=cbind( fmB$ETA$predictors$b, fmB$ETA$predictors$SD)
  colnames(RES.BAYES)=c('Post-mean','Post-SD')
  # Adding the intercept
  RES.BAYES=rbind('Intercept'=c(fmB$mu,fmB$SD.mu),RES.BAYES)
  
```

**Using incidence matrices**



  
[Back to list of examples](https://github.com/QuantGen/BGLR_AI/#examples)

