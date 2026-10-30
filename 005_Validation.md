<!--intro starts -->

# Three ways of producing predictions in validation data using BGLR

Validation involves making prediction of known phenotype or response variable without
exposing that information to the model. This is an important approach to evaluating the
reliability of a modeling approach.

In the following examples we demonstrate how to make predictions by:

- Masking response (y) variables to make within a test set
- Using a genomic relationship matrix (G-matrix)
- Cross-fold validation using for loops and parallel processing

<!--intro ends -->

### Menu

<div id="menu" />
  
   * [0) Generating test data](#Setup)
   * [1) Making response variables](#Mask)
   * [2) G-matrix](#Gmat)
   * [3) Cross Validation](#Cross)

<div id="Setup" />

<!--chunk starts -->

<!--kb
id: Validation-setup
agent: coding
package: BGLR
prompt: Define a testing subset within the wheat data set using random sampling
-->

## Setup

Before doing validation, we need to load BGLR and select of subset of samples as our testing set

```R
  # Load BGLR
  library(BGLR)
  
  # Get wheat data set
  data(wheat)
  
  # Define predictor and response variables
  X=scale(wheat.X)
  y=wheat.Y[,2]
  
  # Define testing subset
  n=length(y)
  nTST=150
  tst=sample(1:n,size=nTST)
```

<!--chunk ends -->

<div id="Mask" />

<!--chunk starts -->

<!--kb
id: Validation-Masking Response variable
agent: coding
package: BGLR
prompt: Mask the response variable for our test set and fit a linear model
-->

## Masking response variables (y)

For our first approach, we will mask the response values (y) inside our test set by setting them to NA.

BGLR will deal with this missing data problems internally.

```R
  # Mask response variable (y) in our test set
  yNA=y
  yNA[tst]=NA
  
  # Fit the model
  fm1=BGLR(y=yNA,ETA=list(list(X=X,model='BRR')),nIter=6000,burnIn=1000)
  yHat_1=fm1$yHat[tst]
  yHat_1SD=fm1$SD.yHat[tst]
  
  # Plot the first 50 point of the testing set (red points are the actual values)
  plot(yHat_1[1:50],ylab='yHat +/- SD', ylim=range(c(-2.5,2.5)))
  arrows(1:50, yHat_1[1:50]-yHat_1SD[1:50], 1:50, yHat_1[1:50]+yHat_1SD[1:50],length=0.05, angle=90, code=3)
  points(y[tst[1:50]],col='red',pch=16)
```

<!--chunk ends -->

<div id="Gmat" />

## Using genomic relationships

Next, we will use genomic relationships within our data set to make predictions within the test set

<!--chunk starts -->

<!--kb
id: Validation-Training and testing sets
agent: coding
package: BGLR
prompt: Fit a linear regression model on training data and use results to make predictions of response variable in the test set
-->

### Define training and testing data

For this, we will need to define training and testing data sets for both predictors (X) and response (y) variables. 

We can also make predictions WITHOUT using genomic relationships (yHat_2), which we will we use as a point of comparison.

(Note: we don't need to censor response variables here as the response values of test set are never seen by BGLR)

```R
  # Defining trainning and testing data in both X andy
  yTRN=y[-tst]; yTST=y[tst]
  X.TRN=X[-tst,]; X.TST=X[tst,]
  
  # Fit on training data and apply to testing without a G-matrix
  fm2=BGLR(y=yTRN,ETA=list(list(X=X.TRN,model='BRR')),nIter=6000,burnIn=1000)
  yHat_2=fm2$mu+as.vector(X.TST%*%fm2$ETA[[1]]$b)
```

<!--chunk ends -->

<!--chunk starts -->

<!--kb
id: Validation-Genetic relationships
agent: coding
package: BGLR
prompt: Fit a GBLUP model on training data using a genomic relationship matrix and use results to make predictions of response variable in the test set
-->

### Using a genomic relationship matrix

Now, we use genomic relationships to make predictions using genetic relationships (yHat_3). 

(Note: this approach is only valid for GBLUP)

```R
  # Define the overall G-matrix
  G=tcrossprod(X)/ncol(X)
  
  G11=G[-tst,-tst] # genomic relationships in the training data
  G21=G[tst,-tst] # genomic relationships between 
  
  # Fit on training data and apply to testing with a G-matrix
  fm3=BGLR(y=yTRN,ETA=list(list(K=G11,model='RKHS')),nIter=6000,burnIn=1000)
  yHat_3=fm3$mu+as.vector(G21%*%solve(G11)%*%fm3$ETA[[1]]$u)
  
  # Compared results to previous models
  print("Correlation between validation approaches")
  cor(cbind(yHat_1,yHat_2,yHat_3))
```
<!--chunk ends -->

<div id="Cross" />

## Cross-validation

Finally, we will make predictions withing a cross validation scheme where multiple testing sets are defined.

While there are many approaches to cross-validation, for our example we will use five non-overlapping folds
which gives a 1:4 ratio of testing to training data. This will allow us to predict each response variable in our
data using a setup where most of the data set is available to the model, but the response values of interest
are masked for that run.

We will also consider two implementations of cross-fold validation, one using a loop and one using parallel
processing using multiple cores.

<!--chunk starts -->

### Using a loop

<!--kb
id: Validation-Cross fold validation in a loop
agent: coding
package: BGLR
prompt: Use a loop to do cross fold validation where the response variable is masked withing each fold and used to fit a linear model
-->

Here we define our folds, then iteratively run each one through BGLR inside of for loop which
adds the results to a predefined (yHatCV) vector

```R
 # Define 5 folds
 folds=sample(1:5,size=n,replace=T)
 
 # Create a vector to hold our predictions
 yHatCV=rep(NA,n)
 
 timeIn=proc.time()[3]
  for(i in 1:max(folds)){ # For each fold
  	tst=which(folds==i)
  	
  	# Mask the test set response variable
  	yNA=y
    yNA[tst]=NA
    
    # Run the model and extract results for the test set
    fm=BGLR(y=yNA,ETA=list(list(X=X,model='BRR')),nIter=6000,burnIn=1000)
    yHatCV[tst]=fm$yHat[tst]
  }
  
  print("Run Time (seconds)")
  print(proc.time()[3]-timeIn)
```
<!--chunk ends -->

<!--chunk starts -->

<!--kb
id: Validation-Cross fold validation in a loop
agent: coding
package: BGLR
prompt: Use parallel processing to do cross fold validation where the response variable is masked withing each fold and used to fit a lienar model
-->

### Using multiple cores (parallel processing)

Using the same folds as above, will we now run cross-fold validation in parallel using multiples core.

There are important considerations when using a parallel approach:

- Because each fold is being run in parallel, we will need to define a function which selects the proper fold,
runs the validation and returns the results for that fold
- Because each fold is being run in parallel, nothing inside of the function can depending on the results of another
fold (this is why its important that we define folds beforehand)
- For maximum speed up, we will need to have as many core as folds available to run cross-validation

```R
  # First create a function that fits one fold
  fitFold=function(y,W,folds,fold){
    # Select the fold
  	tst=which(folds==fold)
  	
  	# Make response variable within the test data
  	yNA=y
    yNA[tst]=NA
    
    # Run the model and extract results for the test set
    fm=BGLR(y=yNA,ETA=list(list(X=W,model='BRR')),nIter=6000,burnIn=1000,verbose=F)
    tmp=fm$yHat[tst]
    names(tmp)=tst
    
    # Return the results
    return(tmp)
  }
  
  # We need the parallel library to run across core
  library(parallel)
   
   # Run cross-validation in parallel
   # Note: X define the fold within each process
   print("Total run time will be reported one all processes finish")
   system.time( tmp<-mclapply(FUN=fitFold,y=y,W=X,folds=folds,X=1:5,mc.cores=5))
   
   # Unpack and order results
   yHatCV2=unlist(tmp)
   yHatCV2=yHatCV2[order(as.integer(names(yHatCV2)))] # need to order the vector
   
   # Compare results between methods
   print("Correlation of for-loop vs. parallel")
   cor(yHatCV,yHatCV2)
```
