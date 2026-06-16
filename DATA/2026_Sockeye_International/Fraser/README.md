# 2026 Fraser Sockeye Data Set

Most of the data was extracted from the Pacific Salmon Commission data page in June 2026. 

* All the returns by age and spawner estimates through 2024 are extracted from the detailed version of the [Fraser Sockeye Spawner-Recruit Data Set][https://www.psc.org/publications/data/fraser-sockeye-stock-recruit-dataset/]. The code that does the extraction is in [this script](https://github.com/SOLV-Code/SalmonPrize_DataManagement/blob/main/CODE/1_ReorganizeData.R). The downloaded source file is [here](https://github.com/SOLV-Code/SalmonPrize_DataManagement/tree/main/DATA/2026_Sockeye_International/Fraser/1_SourceData/PSC_Download).

* Spawner estimates through 2025 were provided by DFO (Kaitlyn Dionne, Brian Smith) in June 2026. Any recent spawner estimates missing from the PSC surce file are filled in from the DFO spawner file, which is [here](The downloaded source file is [here](https://github.com/SOLV-Code/SalmonPrize_DataManagement/tree/main/DATA/2026_Sockeye_International/Fraser/1_SourceData/DFO_SpawnerFile).


Some important notes regarding these data are listed below. For more details, refer to the [data documentation report](https://www.psc.org/download/130/frp-data/19739/stock-recruit-data-documentation.pdf)

## Notes


* The data on the PSC data website has been reviewed and agreed-upon by the Fraser River Technical Committee of the PSC, and is considered the best available stock-recruit data.

* One aspect of the data review is the *Run Size Adjustment* (RSA), which accounts for known biases and blind spots of the assessment program. The RSA method was recently peer-reviewed through CSAS ([DFO 2025] (https://csas-scas.dfo-mpo.gc.ca/publications-publications/8aa949ac-7960-44bc-887e-61c7e085ea3a?lang=en) )

* If the post-RSA estimate is not yet available, an in-season estimate is provided e.g. for 2025. Some years, the post-RSA run size is very similar to the in-season run size and some years like 2024, they are substantially different. Especially for years when the post-RSA estimate is substantially different than the in-season run size, several RSA meetings are required to achieve agreement and sign off and then the process can take much longer than in other years.

* For forecasting, the post-RSA run size estimate should be used when available, but the in-season run size estimates can be used when the post-RSA run size estimates are not yet available. Forecasters should be aware of the difference in the quality of the estimates. This is the reason why PSC provides the detailed stock-recruit file so it is clear for which years post-RSA estimates are not yet available.

* Occasionaly, past years of data are updated as well through the RSA process, so make sure to always update all years of data for the salmon prize data pack!

* The spawner estimates included here as the default are total brood year spawners, but an alternate version showing effective female spawners (i.e., accounting for pre-spawn mortality and sex ratio) is also included as a separate source.