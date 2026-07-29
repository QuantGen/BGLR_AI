
# A function to extract coefficients from models fitted using (single-trait) BGLR or BLRXy

coef.BGLR=function(fm){
  # fm: a model fitted using BGLR	or BLRXy
	nTerms=length(fm$ETA)

	coef=list()
	tmp=cbind('Estimate'=fm$mu,'SD'=fm$SD.mu)
    rownames(tmp)='mu'
    coef[[1]]=tmp
	for(i in 1:nTerms){
		if(fm$ETA[[i]]$model=='RKHS'){
			coef[[i+1]]=cbind('Estimate'=fm$ETA[[i]]$u,'SD'=fm$ETA[[i]]$SD.u)
			rownames()
		}else{
			coef[[i+1]]=cbind('Estimate'=fm$ETA[[i]]$b,'SD'=fm$ETA[[i]]$SD.b)
		}
		
	}
	names(coef)=c('Intercept',names(fm$ETA))
	return(coef)
}
