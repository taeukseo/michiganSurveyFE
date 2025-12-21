# About

This GitHub repository contains the package for constructing survey-based individual forecast errors, based on Rozsypal and Schlafmann (2023), and used in Mitra, Seo, and Xu (2025). The package includes minor modifications to the original code. It extends the sample period (from July 1986 - December 2013 to July 1986 - November 2021), and simplifies several sections for faster results without changes in output. For example, the package does not calculate bootstrapped standard errors for average forecast errors in real income growth rates (Figure 1, page 340, Rozsypal and Schlafmann 2023).

Requirements: An up-to-date Stata installation, Internet connection to download data and custom stata packages.

Download: Download updated survey data from the [link here](https://www.dropbox.com/scl/fi/6gnv824iwds9ajc5af15d/data_MichSurvey.zip?rlkey=uh76t05xzz5v025oslaimmuag&st=2bgn7cyk). Unzip and copy the `data_MichSurvey.dta` file to `./files/downloaded`.

Run: run the master code `main.do` with command `do main.do`

Output: Produces two files in the directory `./figures`

- `figForecastErrorsMeanExtended.pdf`: Figure 1.A (Average income forecast error)
- `figForecastErrorsDistribution.pdf`: Fig 1.B (Cross sectional percentiles)

When using the package, please cite:

Rozsypal, Filip, and Kathrin Schlafmann. 2023. "Overpersistence Bias in Individual Income Expectations and Its Aggregate Implications." American Economic Journal: Macroeconomics 15 (4): 331–71.

Mitra, Indrajit, Taeuk Seo, and Yu Xu, 2025. "Ambiguity and Unemployment Fluctuations." Working Paper.

For questions, please contact Taeuk Seo at [taeuk.seo@fsa.ulaval.ca](mailto:taeuk.seo@fsa.ulaval.ca).