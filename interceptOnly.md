# An intercept only model


BGLR fits Guassian models of the form

$$y=1\mu+X_1\beta_1+X_2\beta_2+...+u_1+u+2+...+\varepsilon$$

where $y$ ($n \times 1$) is a vector of phenotypes, $\mu$ is an intercept, $X_j$ are incidence matrices for each of the $\beta_j$'s, $u_k$ are vectors of random effects, and $\varepsilon$ is a vector of error terms, which are assumed to be Gaussian and independent.

The terms of the linear predictor ($_1\beta_1+X_2\beta_2+...+u_1+u+2$) are specified through the argument `ETA`, when this ter mis not included in the model, by default, BGLR fits an intercept model of the form

$$y=1\mu+X_1\beta_1+X_2\beta_2+...+u_1+u+2+...+\varepsilon$$

$$y=1\mu+\varepsilon.$$



