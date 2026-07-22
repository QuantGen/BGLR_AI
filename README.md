# BGLR AI: Resources to Power the use of AI with BGLR

In this repository we will create a sequence of examples that can be used to train AI to write code for BGLR (including preparing the data, developing scripts to run models, extracting outputs and displaying results.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the example structure, metadata schema, and validation steps.

## Examples

| Name | Concepts| Data | Source | Status |
|--------|--------|------|------|--------|
| [Intercept Only](examples/interceptOnly/interceptOnly.md) | Shows the most basic model one can run with BGLR | Simulated | None | TBR |
| [Fixed Effects](examples/fixedEffects/fixedEffects.md) | <ul><li> Linear regression w/factors and covariates</li><li>  Posterior means and posterior SD</li><li>  Trace plots</li><li> Posterior density plots</li><li> Posterior credibility regions</li><li> Posterior (co)variance of estimates </li></ul> | [wages](data/wages/wages.txt) |None | TBR |
| [Random Effects](examples/randomEffects/randomEffects.md) | <ul><li> Random effects with a covariance (kernel) structure</li><li> Specifying random effects with `model="RKHS"`</li><li> Variance components and heritability</li><li> Posterior means and posterior SD of random effects</li><li> Convergence assessments</li></ul> | `BGLR::wheat` (bundled) | [BGLR-R](https://github.com/gdlc/BGLR-R/blob/master/inst/md/RKHS.md) | TBR |
| `BayesianAlphabet.md` | <ul><li> Linear regression on SNPs (large p) </li><li> Shrinkage and Variable Selection  </li></ul> | Simulated using mice genotypes | [BGLR-R](https://github.com/gdlc/BGLR-R/blob/master/inst/md/BayesianAlphabet.md)| TBD |

**Status legend:** `TBR` = To Be Reviewed (draft written, pending review); `TBD` = To Be Developed (planned, not yet written).
