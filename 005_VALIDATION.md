---
title: "Validation"
author: "QuantGen"
date: "2026-11-03"
output: pdf_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```


```{r,echo=FALSE}
 runCode=TRUE

```

<!--intro starts -->

# Assessing Predicting Ability with BGLR

The ability of a trained model to predict phenotypes (or genetic values) of individuals whose phenotypes were not used to fit the model is an important aspect of model assessment and is also commonly used for model comparison. 


We show here several ways this can be done using BGLR. 

1. **Predicting one testing set.** We show two ways of doing it: masking phenotypes (`NA`) and using a true data partition (for SNP models and for G-matrix models).
2. **Replication over many testing sets** We discuss two approaches: cross-validation and replicated training-testing partitions.
3. **Comparing models.** We discuss how to compare models when validation was done using the same training-testing partitions.
4. **Measuring prediction accuracy.** Discuss several ways to assess predictive ability and prediction accuracy.

Throughout, we use the notation `y` (phenotypes), `X` (marker genotypes), `G` (genomic relationship matrix), `trn` (indexes of the training set) and `tst` (indexes of the testing set). To keep Sections 1 to 3 self-contained we will use the correlation between predictions and observations as the measure of accuracy; Section 4 discusses this and other measures in detail.

### Menu

<div id="menu" />

   * [0) Setup](#Setup)
   * [1) Predicting a single testing set](#Single)
       * [1.1) Masking phenotypes](#Mask)
       * [1.2) Using a true data partition](#Partition)
   * [2) Generating partitions](#Partitions)
       * [2.1) K-fold cross-validation](#Cross)
       * [2.2) Replicated training-testing partitions](#Replicated)
   * [3) Comparing models](#Compare)
   * [4) Measures of prediction accuracy][WIP](#Accuracy)

<div id="Setup" />

<!--chunk starts -->

<!--kb
id: Validation-setup
agent: coding
package: BGLR
prompt: Create a random partition of a data set into training (trn) and testing (tst) using the Wheat599 data set.
-->

## 0) Setup

Loading the libraries, an example data set, and creating a random training-testing partition. 

```{R, eval=runCode}
  # Load BGLR
  library(BGLR)

  # Get wheat data set
  data(wheat)

  # Define predictor (X) and response (y) variables
  X=scale(wheat.X,center=TRUE,scale=FALSE)
  y=wheat.Y[,2]

  # Define testing subset
  set.seed(123)
  n=length(y)
  nTST=150
  tst=sample(1:n,size=nTST)
  trn=setdiff(1:n,tst)
```

<!--chunk ends -->

<!--intro ends -->

<div id="Single" />

## 1) Predicting a single testing set

Given a training set and a testing set there are two ways of obtaining predictions for the testing set. In the first, the testing phenotypes are hidden *inside* the model (they are masked by setting the testing phenotypes to `NA`). In the second, the testing individuals are kept entirely out of the fit and the predictions are computed afterwards from the estimated effects. 

<div id="Mask" />

<!--chunk starts -->

<!--kb
id: Validation-Masking Response variable
agent: coding
package: BGLR
prompt: Mask phenotypes in the testing set and run a linear model to make predictions
-->

### 1.1) Masking phenotypes (the `NA` approach)

In the first approach we mask the response values (`y`) of the testing set by setting them to `NA`. Internally, BGLR treats missing phenotypes as any other unknown: in every cycle of the sampler the missing values are sampled from their fully conditional distributions. The software returns posterior means of the linear predictor (`$yHat`) for all the observations, including those that had missing values.

This approach works for any model, whether it is based on SNPs or on a relationship matrix. 

Note that the genotypes (or the relationship matrix entries) of the testing individuals are available when the model is fitted; only their phenotypes are hidden.

```{R, eval=runCode}
  # Mask response variable (y) in our test set
  yNA=y
  yNA[tst]=NA

  # Fit the model
  PWD=getwd()
  setwd(tempdir()) # use this to save posterior samples in a temporary directory. Do not be concerned if you see a warning about the workign directory being chaged
   fm1=BGLR(y=yNA,ETA=list(list(X=X,model='BRR')),nIter=6000,burnIn=1000,verbose=FALSE)
  setwd(PWD)
  
  yHat_1=fm1$yHat[tst]
  yHat_1SD=fm1$SD.yHat[tst]

  # Plot the first 50 points of the testing set (red points are the actual values)
  library(ggplot2)
  DF=data.frame(y=y[tst],yHat=yHat_1,SD=yHat_1SD)

  p=ggplot(DF,aes(x=y,y=yHat))+
          geom_errorbar(aes(ymin = yHat - SD, ymax = yHat + SD), width = 0.2, color ="pink")+
          geom_point(col=4)
  p
  
  # A first measure of accuracy (see Section 4 for others)
  cor(y[tst],yHat_1)
```

<!--chunk ends -->

<div id="Partition" />

### 1.2) Using a true data partition

The masking approach requires the genotypes of the testing individuals at fitting time. In many applications the testing individuals are genuinely new: neither their phenotypes nor their genotypes are available when the model is trained. In that case we split *both* `X` (or `G`) and `y`, fit the model using the training data only, and then predict the testing set from the estimated effects. How we do this depends on how the model is parameterized.


<!--chunk starts -->

<!--kb
id: Validation-Training and testing sets
agent: coding
package: BGLR
prompt: Fit a linear regression model on training data and use results to make predictions of response variable in the test set
-->

#### 1.2.1) Models using SNPs

For SNP-based models we predict by adding the intercept to the product of the testing genotypes and the estimated SNP effects.

```{R, eval=runCode}
  # Define training and testing data in both X and y
  yTRN=y[trn]; yTST=y[tst]
  X.TRN=X[trn,]; X.TST=X[tst,]

  # Fit on training data and apply to testing data
  setwd(tempdir())
   fm2=BGLR(y=yTRN,ETA=list(list(X=X.TRN,model='BRR')),nIter=6000,burnIn=1000,verbose=FALSE)
  setwd(PWD)
  yHat_2=fm2$mu+as.vector(X.TST%*%fm2$ETA[[1]]$b)
```


<!--kb
id: Validation-Genetic relationships
agent: coding
package: BGLR
prompt: Fit a GBLUP model on training data using a genomic relationship matrix and use results to make predictions of response variable in the test set
-->

#### 1.2.2) Models using a genomic relationship matrix

When the model is parameterized with a relationship matrix we have no SNP effects to multiply by the testing genotypes. Instead, the genetic values of the testing individuals are predicted from the estimated genetic values of the training individuals using the BLUP formula.

$$\hat{\boldsymbol{u}}_2=\boldsymbol{G}_{21}\boldsymbol{G}_{11}^{-1}\hat{\boldsymbol{u}}_1$$

where subscript `1` denotes the training set, subscript `2` the testing set, $\boldsymbol{G}_{11}$ is the relationship matrix among the training individuals, $\boldsymbol{G}_{21}$ contains the relationships between testing and training individuals, and $\hat{\boldsymbol{u}}_1$ is the vector of predicted genetic values of the training individuals. 

(Note: this approach is only valid for GBLUP, that is, a Gaussian prior on the genetic values with covariance proportional to $\boldsymbol{G}$.)

```{R, eval=runCode}
  # Define the overall G-matrix (built using all individuals)
  G=tcrossprod(X)
  G=G/mean(diag(G))

  G22=G[trn,trn] # genomic relationships in the training data
  G12=G[tst,trn] # genomic relationships between testing and training

  # Fit on training data and apply to testing with a G-matrix
  setwd(tempdir())
   fm3=BGLR(y=yTRN,ETA=list(list(K=G22,model='RKHS')),nIter=6000,burnIn=1000,verbose=FALSE)
  setwd(PWD)
  yHat_3=fm3$mu+as.vector(G12%*%solve(G22)%*%fm3$ETA[[1]]$u)
```

<!--chunk ends -->

<!--chunk starts -->

<!--kb
id: Validation-Compare single test approaches
agent: coding
package: BGLR
prompt: Assuming that multiple single test approaches to validation have been run, compare the results to each other and to the known response values using correlation
-->

#### Comparing the three sets of predictions

These three approaches, masking (yHat_1), partitioning SNPs (yHat_2), and partitioning with a genomic relationship matrix (yHat_3) describe the same underlying model. As such, their predictions should be very similar, but they will not be identical because differences in Monte Carlo Error (masking phenotypes usually leads to higher MC error than prediction using SNP effects or BLUP equations) and due to small differences in prior assumptions.

```{R, eval=runCode}
  print("Correlation between prediction approaches")
  round(cor(cbind(yHat_1,yHat_2,yHat_3)),3)

  print("Correlation between predictions and observed values in the testing set")
  round(cor(cbind(yHat_1,yHat_2,yHat_3),yTST),3)
```
<!--chunk ends -->

<div id="Partitions" />

## 2) Generating partitions

In Section 1 we evaluated the models using a single training-testing partition. A single partition gives a noisy estimate of predictive performance: a different split would give a different estimates, and with 150 testing records the sampling variance of the correlation is not small. To obtain more stable estimates we repeat the process over many partitions. Here we discuss two ways of generating them: K-fold cross-validation (Section 2.1) and replicated random training-testing partitions (Section 2.2). In both cases we use the masking approach of Section 1.1, but the same loops can be written with true partitions.

<div id="Cross" />

<!--chunk starts -->

### 2.1) K-fold cross-validation

In K-fold cross-validation the records are split into K non-overlapping folds. Each fold is used once as the testing set while the remaining K-1 folds are used for training. As a result every record is predicted exactly once, using a model that did not see its phenotype.

For our example we use five folds, which gives a 1:4 ratio of testing to training data. We assign records to folds so that fold sizes are as equal as possible.

<!--kb
id: Partition-Cross-validation
agent: coding
package: BGLR
prompt: Generate five non-overlapping folds of training and testing data then, for each fold, mask phenotype in the testing set and run a linear model to make predictions
-->

Here we define our folds, then run each one through BGLR inside a `for` loop, which adds the results to a predefined vector (`yHatCV`). Note that we use a different object name (`tstFold`) for the testing set of each fold so we do not overwrite the `tst` defined in the setup.

```{R, eval=runCode}
  # Define 5 folds of (almost) equal size
  K=5
  folds=sample(rep(1:K,length.out=n))

  # Create a vector to hold our predictions
  yHatCV=rep(NA,n)
  
  PWD=getwd()
  setwd(tempdir())
  for(i in 1:K){ # For each fold
    tstFold=which(folds==i)

    # Mask the test set response variable
    yNA=y
    yNA[tstFold]=NA

    # Run the model and extract results for the test set
    fm=BGLR(y=yNA,ETA=list(list(X=X,model='BRR')),nIter=6000,burnIn=1000,verbose=FALSE)
    yHatCV[tstFold]=fm$yHat[tstFold]
  }
  setwd(PWD)

```


#### Evaluating the cross-validation predictions

Once every record has a cross-validated prediction there are two natural ways of summarizing accuracy: pooling all predictions and computing one correlation, or computing a correlation within each fold and averaging. The two can differ, especially when folds differ in their mean (for example due to population structure) because pooling mixes between-fold and within-fold variation. We return to this in Section 4.

<!--kb
id: Partition-Evaluting cross validation
agent: coding
package: BGLR
prompt: Using the results of an existing cross fold validation with K folds and predictions in yHatCV, compare predictions across all folds to actual phenotype in y
-->

```{R, eval=runCode}
  # Pooled correlation
  cor(y,yHatCV)

  # Within-fold correlations
  accFold=sapply(1:K,function(i){ j=which(folds==i); cor(y[j],yHatCV[j]) })
  round(accFold,3)
  mean(accFold)
```

<!--chunk ends -->

<div id="Replicated" />

<!--chunk starts -->

<!--kb
id: Validation-Replicated training testing partitions
agent: coding
package: BGLR
prompt: Evaluate a model using replicated random training-testing partitions where the response variable is masked in each testing set
-->

### 2.2) Replicated training-testing partitions

An alternative to cross-validation is to repeat a random training-testing split R times. Compared with K-fold cross-validation, this gives full control over the size of the training and testing sets and over the number of replicates, which do not need to be tied to each other. The price is that testing sets of different replicates overlap, so some records may be predicted many times and others never.

In the following example we use R=15 replicates and the same testing set size as before. For actual validation, a much larger value of R should be used but using smaller values is reasonable for testing code in order to save time (the example below will take about 30 seconds with 15 reps)   

We **store the partitions**: when we compare models in Section 3, every model must be evaluated on exactly the same partitions.

```{R, eval=runCode}
  nRep=15
  partitions=vector("list",nRep) # stores the testing set of each replicate
  accRep=rep(NA,nRep)            # accuracy (correlation) in each replicate

  for(r in 1:nRep){
    tstRep=sample(1:n,size=nTST)
    
    # Mask the testing phenotypes
    yNA=y
    yNA[tstRep]=NA

    # Fit the model and evaluate predictions in the testing set
    setwd(tempdir())
     fm=BGLR(y=yNA,ETA=list(list(X=X,model='BRR')),nIter=6000,burnIn=1000,verbose=FALSE)
    setwd(PWD)
    accRep[r]=cor(y[tstRep],fm$yHat[tstRep])
  }

  round(accRep,3)
  c(mean=mean(accRep),sd=sd(accRep))
```

The spread of `accRep` illustrates the point made at the beginning of this section: different partitions give noticeably different accuracies. This variability is shared by any two models evaluated on the same partitions, which is the key to the comparison methods described next.

<!--chunk ends -->

<div id="Compare" />

## 3) Comparing models

Suppose we want to know whether model A predicts better than model B. We can evaluate both on the partitions generated in Section 2 and obtain two vectors of accuracies, `accA` and `accB`, one entry per partition. Because both models are evaluated on the same partitions, `accA[r]` and `accB[r]` share a common factor. Treating `accA` and `accB` as independent samples ignores this positive correlation and wastes power. The sections below deal with this using paired analyses.

<!--chunk starts -->

<!--kb
id: Comparison-Compare two models with replicated partitions
agent: coding
package: BGLR
prompt: Evaluate two different models, GBLUP and RKHS, using replicated random training-testing partitions where the response variable is masked in each testing set
-->

For the example we compare two models, a GBLUP and a RKHS model using a Gaussian kernel. We evaluate the performances using replicated training/testing partitions.

```{r}
 library(BGLR)
 data(wheat)
 y=wheat.Y[,3]; X=scale(wheat.X,center=TRUE,scale=FALSE)

 G=tcrossprod(X)
 G=G/mean(diag(G))
 
 # Mapping GRM to distance and then to Gaussian Kernel
 D=matrix(nrow=n,ncol=n,0)
 for(i in 1:(n-1)){
  for(j in i:n){
    D[i,j]=G[i,i]+G[j,j]-2*G[i,j]
    D[j,i]=D[i,j]
  }  
 }
 K=exp(-D)
  
 # Training-testing partitions
 n=nrow(X)
 nRep=10 # number of training testing partitions
 nTst=150 # of observations used for testing
 COR_G=rep(NA,nRep)
 COR_K=rep(NA,nRep)
 
 # To speed up computations we precompute eiggen decomposition
 EVD.G=eigen(G)
 EVD.K=eigen(K)

 LP.G=list(list(V=EVD.G$vectors,d=EVD.G$values,model='RKHS'))
 LP.K=list(list(V=EVD.K$vectors,d=EVD.K$values,model='RKHS'))
 
 PWD=getwd()
 setwd(tempdir())
  for(i in 1:nRep){
   yNA=y
   tst=sample(1:n,size=nTst)
   yNA[tst]=NA
   
   # GBLUP
   fmG=BGLR(y=yNA,ETA=LP.G,nIter=6000,burnIn=1000,verbose=FALSE)
   COR_G[i]=cor(y[tst],fmG$yHat[tst])
   
   # Gaussian kernel
   fmRKHS=BGLR(y=yNA,ETA=LP.K,nIter=6000,burnIn=1000,verbose=FALSE)
   COR_K[i]=cor(y[tst],fmRKHS$yHat[tst])   
   
  }
 setwd(PWD)
```
 
 <!--kb 
 id: Comparison-Plot results of model comparison
agent: coding
package: BGLR
prompt: Assuming two models have already been run on the same replicated partitions, with results in COR_G and COR_K, plot the results against each other with a 45 degree line for reference
-->
 
 **Comparing predictions**
   
A scatterplot with a 45 degree line is a good way to examine the results. Points above the 45 degree line correspond to partitions in which the prediction correlation was higher for the method in the y-axis compared to the one displayed in the x-axis.
 
```{r}
   tmp=range(c(COR_G,COR_K))
   plot(COR_G,COR_K,xlim=tmp,ylim=tmp);abline(0,1,col=2);abline(v=mean(COR_G),lty=2,col=4);abline(h=mean(COR_K),lty=2,col=4)
```

<!--kb 
 id: Comparison-Formal testing of model comparison
agent: coding
package: BGLR
prompt: Assuming two models have already been run on the same replicated partitions, with results in COR_G and COR_K, plot the results against each other with a 45 degree line for reference
-->

**Formal testing**

A formal comparison can be done using a paired t-test or a mixed model. The mixed model can be used with an arbitrary number of models. 

The mixed model suggest that approximately 50% of the variance in prediction correlation is attributable to the partition.

The difference appears to be significant (t-value ~1.9) indicating that the Gaussian kernel predicted better than the GBLUP.

```{r}

 t.test(COR_G,COR_K,paired=TRUE) # t-test is highly significant

 library(lme4)
 DF=data.frame(Model=rep(c('GLBUP','RKHS'),each=nRep),Rep=rep(1:nRep,each=2),Cor=c(COR_G,COR_K))
 
 fm=lmer(Cor~Model+(1|Rep),data=DF)
 summary(fm)
 
```

<!--chunk ends -->
