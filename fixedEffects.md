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

 # linear regression of wage on sex, ethnicity, age, and years of experience
  # lm()

  # BGLR

[Back to list of examples](https://github.com/QuantGen/BGLR_AI/#examples)

```

**Using incidence matrices**



  
 
