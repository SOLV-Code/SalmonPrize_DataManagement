# SalmonDataOntology_TestCase


## Background

*Ontology* = a standardized dictionary and grammar book for a specific type of data

Salmon data comes in many variations. Even for the most basic quantities we quickly encounter a dizzying diversity when trying to combine information from multiple sources (e.g., gross escapement vs. total spawners vs. total natural spawners vs total wild spawners).

There has been a lot of work at DFO and PSC over the last few years to develop tools and templates for a salmon ontology:

* Salmon Domain Ontology ([Website](https://salmon-data-mobilization.github.io/salmon-domain-ontology/),[GitHub repo](https://github.com/salmon-data-mobilization/salmon-domain-ontology))
* Salmon Data Package Specification ([GitHub Repo](https://github.com/salmon-data-mobilization/smn-data-pkg))
* *metasalmon* R Package ([GitHub Repo](https://github.com/salmon-data-mobilization/metasalmon))


**Insert brief outline of how these pieces fit together, general workflow: **explain how it extracts notes, matches to ontology terms, and generates a "proper" version of the data.  And once that is set up, the ontology-compliant data can become part of the data package that's posted on the competition page.





## The Salmon Prize as a Test Case


### Test Case Part 1: Improving Documentation and Standard Data Package for Competing Teams 


**Challenge**

The salmon prize competition is pulling together very different types of source data into a single data package, which is then used by competing teams with very diverse backgrounds. 

The 2026 Sockeye forecasting competition includes:

- 3 data sets for the Columbia River, provided by the [Columbia River Inter-Tribal Fish Commission](https://critfc.org/): These represent the total Columbia and 2 major component stocks. In the current version, only adult returns (by age) to the lower Columbia are available, and are use as a proxy for both total returns and brood year abundance. Other data sources are potentially available (e.g., spawning ground estimates) from other organizations (e.g., [Okanagan Nation Alliance](https://syilx.org/) , but could not be included for the current competition. 

- 8 data sets from Bristol Bay, provided by the [Alaska Department of Fish & Game](https://www.adfg.alaska.gov/): Each data set represents a large river system and includes total run size by age as well as total spawners. 

- 5 data sets from the Fraser River, provided by [Fisheries and Oceans Canada](https://www.dfo-mpo.gc.ca/index-eng.html) and the [Pacific Salmon Commission](https://www.psc.org/): Each data set represents 1 stock, defined based on rearing lakes and run timing (i.e., the whole Fraser would correspond in scope to one of the Bristol Bay data sets, but here only 5 of the 20+ component stocks are included in the competition)

There are several fundamental consistency challenges in the combined data set for the 3 systems:

- Returns and spawners are defined differently in the 3 systems.
- The age notation thing has to be handled properly
- One of the stock names differs between Canadian and US conventions (Okanagan vs Okanogan)
- One stock includes two of the others (Bonneville Lock and Dam includes both Wenatchee and Okanagan)
- When mapping onto brood year, need to make decisions re: what's a "full cohort", and then filter the fields that show a recruits value accordingly
- There will be annual data packages for the next few years as long as the competition continues

Currently, the data management is set up as some basic csv files with notes, and R scripts that merge the data (see [this folder](https://github.com/SOLV-Code/SalmonPrize_DataManagement/tree/main/DATA)). The data set for the 2025 competition is available [here](https://github.com/SOLV-Code/SalmonPrize_Diagnostics/tree/main/Sockeye_International_2025/CompetitionDataSet).

All competitors from 2025 flagged challenges with data reorganization and lack of clarity re: definitions and differences across data sets. These challenges were especially pronounced for competitors without previous salmon modelling experience.

Future versions of the data set should be more easily usable (e.g., machine readable) and clearer to people who come with totally different backgrounds to bring fresh perspectives and new tools to salmon forecasting. 


**Approach**


*INSERT IDEAS*


### Test Case Part 2: Streamlining the data flow across multiple organizations to support timely release for future competitions.


**Challenge**

* lots of coordination to sort out. Has been a lot of trouble each year


**Approach**


*INSERT IDEAS*

### Test Case Part 3: Analyzing the competition results



**Challenge**

As more annual competitions unfold,and more teams try out more diverse methods, a very rich data set of model descriptions and competition results is accumulating. As part fot their submission, each team provides a short abstract of methods plus optionally some additional write-up. All the material is being compiled in a single location: https://github.com/SOLV-Code/SalmonPrize_Diagnostics

To learn over time, we need to develop a systematic classification of the competing models, so that we can properly analyze the rapidly growing body of submissions. Do some "types" of models do better in some years and/or in some systems? Is there a "type" of model that sticks out across systems and years?  Or do the specifics matter more? (e.g., is there a particular covariate that seems to help across model types?). 

As an illustration, here's an examples of a model descriptions from [this submission](https://github.com/SOLV-Code/SalmonPrize_Diagnostics/tree/main/Sockeye_International_2025/Team_Submissions/Hooked%20On%20Data):


*Machine Learning-Based Prediction of Salmon Returns Using Environmental and Spawner Data*


*We developed a machine learning framework to predict salmon returns for individual rivers using a combination of return data, spawner counts, and environmental variables. Our approach was based on annual observations from year y to y–5, with the goal of predicting salmon returns in year y+1. We applied time series-aware data splits by river, using the first 80% of samples for training and the last 20% for testing. To enhance model performance and generalizability, we tested a suite of configurations that included different machine learning algorithms, subsets of predictive features, time-lagged variables, and optionally an ARIMA model applied to the residuals of the machine-learning model. Each model was trained separately for the three major river systems. The final model for each river ("winner model") was selected based on test-set performance (minimum Mean Absolute Percentage Error), while ensuring limited overfitting by removing models with high divergence in R² between training and test sets. These winner models were retrained on all data up to 2024 and used to generate final predictions for 2025.*




**Approach**


*INSERT IDEAS*














