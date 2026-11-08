---
contributors:
  - Lenard Lieb
  - Adam Jassem
  - Rui Jorge Almeida
  - Nalan Baştürk
  - Stephan Smeekes
---

## Overview

The code in this replication package constructs the analysis file from the ten data sources using C++, Python, R, and Matlab.
Two main files run all the code to generate the data for the 18 figures (7 in the main text and 11 in appendix) 
and 14 tables (3 in the main text and 11 in appendix) in the paper.
The replicator should expect the code to run for about 2 weeks for the Python/C++ code for the main calculations and 
3 minutes for the Python, Matlab and R code that creates all additional analysis and figures.


## Replication from GitHub

This GitHub repository contains the code and data needed for the econometric analysis in
`02-analysis_prevalence_measures` (Stage 2). It also includes the published topic-model figures in
`01-construction_prevalence_measures/Graphs`. The additional inputs and intermediate results for
constructing the topic-prevalence measures (Stage 1) are available in the
[complete openICPSR replication package (V1)](https://doi.org/10.3886/E205441V1).

### Econometric analysis (GitHub only)

The econometric analysis requires R and MATLAB (with the Statistics and Machine Learning
Toolbox). Run the following commands from the repository root.

**First-time replication (install R dependencies and run the analyses):**

```bash
./00-setup/analysis_replication.sh --install
```

**Subsequent replications (skip installation):**

```bash
./00-setup/analysis_replication.sh
```

The default is `--no-install`; it can also be specified explicitly. Run
`./00-setup/analysis_replication.sh --help` to see the available options.

With `--install`, the script first runs `0_setup.R` to install the R dependencies listed
under Software Requirements below. Installing R packages from source may require additional
system libraries or build tools, depending on the operating system. MATLAB must be installed
separately.

The script then runs the R analyses (`GC_analysis.R` and `Correlation_analysis.R`) and the
MATLAB analyses (`IRs_Analysis.m`, `Predict_Analysis.m`, and `Plot_pValues_GC.m`) in a
single MATLAB session. It uses the input files already included in
`02-analysis_prevalence_measures` and creates output directories when needed. It does not
re-estimate the topic model or regenerate the Stage 1 figures.

### Topic-model analysis (additional files from openICPSR)

To reproduce Stage 1 calculations or regenerate the topic-model figures, download the
[openICPSR replication package (V1)](https://doi.org/10.3886/E205441V1) and copy its
`01-construction_prevalence_measures/Data/` and `01-construction_prevalence_measures/Results/`
directories into the same locations in your GitHub checkout:

```text
01-construction_prevalence_measures/
├── Data/      # Inputs, including the processed presidential communications
├── Results/   # Intermediate estimates, including theta1.csv and theta2.csv
└── Graphs/    # Published figures (already included on GitHub)
```

The Stage 1 estimation takes approximately two weeks on a standard desktop computer.
Researchers who only want to inspect the published figures do not need to regenerate them.
The processed presidential communications data are shared for replication purposes, subject
to the permissions described below.

## Data Availability and Provenance Statements

### Statement about Rights

- [X] I certify that the author(s) of the manuscript have legitimate access to and permission to use the data used in
  this manuscript.

All data used in this paper is made freely available by the respective data providers.
The data is made available in this package for replication and reproducibility of the results in the paper.
All data citations should be made to the original data providers.

### Summary of Availability

- [X] All data **are** publicly available.
- [ ] Some data **cannot be made** publicly available.
- [ ] **No data can be made** publicly available.


### Details on each Data Source

The `Provided` column refers to the full openICPSR replication package; not all Stage 1 files are included in this GitHub repository.

| Data.Name                         | Data.Files           | Location                                 | Provided | Citation                                                |
|-----------------------------------|----------------------|------------------------------------------|----------|---------------------------------------------------------|
| Tax Receipts                      | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | U.S. Bureau of Economic Analysis (2020c)                |
| Income Taxes                      | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | U.S. Bureau of Economic Analysis (2020c)                |
| Corporate Taxes                   | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | U.S. Bureau of Economic Analysis (2020c)                |
| Payroll Taxes                     | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | U.S. Bureau of Economic Analysis (2020c)                |
| Cyclically Adjusted Revenue       | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | Romer and Romer (2010b)                                 |
| Implicit Tax Rate                 | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | Leeper et al. (2012b)                                   |
| RR All Tax Changes                | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | Romer and Romer (2010b),                                |
| RR All Exogenous Tax Changes      | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | Romer and Romer (2010b),                                |
| RR News All Tax Changes           | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | Romer and Romer (2010b),                                |
| RR News Exogenous Tax Changes     | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | Romer and Romer (2010b),                                |
| MR Unanticipated Tax Changes      | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | Mertens and Ravn (2014b)                                |
| GDP                               | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | U.S. Bureau of Economic Analysis (2020b)                |
| Consumption                       | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | U.S. Bureau of Economic Analysis (2020b)                |
| Investment                        | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | U.S. Bureau of Economic Analysis (2020b)                |
| Government Spending               | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | U.S. Bureau of Economic Analysis (2020c)                |
| Government Debt                   | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | Federal Reserve Bank of Dallas (2020)                   |
| 3-month T-Bill                    | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | Board of Governors of the Federal Reserve System (2020) |
| Federal Funds Rate                | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | Board of Governors of the Federal Reserve System (2020) |
| Unemployment Rate                 | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | U.S. Bureau of Labor Statistics (2020c)                 |
| CPI                               | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | U.S. Bureau of Labor Statistics (2020a)                 |
| S&P 500                           | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | Shiller (2020)                                          |
| Government Spending News          | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | Ramey (2011b)                                           |
| Job Approval of the President     | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | Woolley and Peters (2019)                               |
| Congress Concurrence              | Data.xlsx            | 02-analysis_prevalence_measures/Data     | TRUE     | Brookings Institution (2022)                            |
| RR & Yang Identified Tax Speeches | tax_speeches.csv     | 01-construction_prevalence_measures/Data | TRUE     | Romer and Romer (2009), Yang (2007)                     |
| Yang Identified Legislative Lags  | yang_dates.csv       | 01-construction_prevalence_measures/Data | TRUE     | Yang (2007)                                             |
| Presidential Speeches (corpus)    | corpus.csv           | 01-construction_prevalence_measures/Data | TRUE     | Woolley and Peters (2019)                               |
| Presidential Speeches (Dates)     | doc_codes.csv        | 01-construction_prevalence_measures/Data | TRUE     | Woolley and Peters (2019)                               |
| Presidential Speeches (Terms)     | terms.csv            | 01-construction_prevalence_measures/Data | TRUE     | Woolley and Peters (2019)                               |
| Tax Increase Lexicon              | lexicon_increase.csv | 01-construction_prevalence_measures/Data | TRUE     |                                                         |
| Tax Decrease Lexicon              | lexicon_decrease.csv | 01-construction_prevalence_measures/Data | TRUE     |                                                         |



### Data sources
All data we use in this paper is freely available online and and accessible to everyone. 
In the bibliography we provide URLs to all data we use. We next provide all relevant details of every data set (and every data series) organised by source.

- **Woolley and Peter's "_American Presidency Project_"**

  - Text Data: All public communications by U.S. Presidents, source: Wolley and Peters (2019). The URL in the
    bibilography links to the Wolley and Peter's APP document collection. 

    We analyse the texts of all the documents contained in "_The Public Papers of the Presidents_". 
    This includes speeches, but also other public communications (e.g., interviews, letters). 
    We retrieved the raw texts from Woolley and Peters (2019) the "_American Presidency Project_" on 2019-03-25
    by scraping all documents from https://www.presidency.ucsb.edu/documents. The raw dataset consists of 59,214
    texts spanning from 1949-01-20 to 2017-01-19. 

    The dataset was pre-processed. In a first step divide the texts are divided into individual paragraphs, resulting in
    a total of 1,119,200 documents. The text is then split further along non-alphanumeric characters into tokens
    (individual words). Stop words are removed. Rare words (words that appear in less than 20 documents) are
    removed.  The remaining tokens are then lemmatised - all the nouns are turned into singular form, and the
    verbs are turned into present tense first person form.
    Lastly, we identify meaningful collocations of two words - bigrams. If a combination of two consecutive words
    (e.g. “tax” and “cut”) appears more often than predicted by their individual frequency (as measured by a χ2
    score) it is considered a bigram (i.e. “tax cut”). A bigram is treated as a separate term in the vocabulary
    and each instance of a bigram in the texts is treated as a single token.
    The final vocabulary consists of 50,851 terms, including 29,815 bigrams.

    After pre-processing, the presidential speeches were processed into 3 different files. The file `terms.csv`
    contains the list of terms used in the speeches (vocabulary). The i-th term in the list is coded as i in the
    data. The file `doc_codes.csv` contains the list of documents containing speeches and other public
    communications by the President. The first 8 digits indicate the date of the speech (YYYYMMDD). The following
    2 digits indicate the number of the speech within given day. The last 3 digits indicate the number of the
    paragraph within a given speech. The d-th document in the list is coded as d in the data.
    Finally, the files `corpus.csv` is the processed presidential speeches. Each row represents a single token.
    The first column indicates the term included in `terms.csv`, the second column indicates the document from
     `doc_codes.csv`.

    In this research, we created two lexicons related to tax increase and tax decrease terms. These files serve
    as a basis for the construction of the measures of tax changes. These files contain a list of terms
    identified as indicative of discussing tax hikes or tax cuts. The lexicons are provided in the files
    `lexicon_increase.csv` and `lexicon_decrease.csv`.

    The file `tax_docs.csv` contains the list of documents containing speeches and other public communications by
    the President. The first 8 digits indicate the date of the speech (YYYYMMDD). The following 2 digits indicate
    the number of the speech within a given day. The last 3 digits indicate the number of the paragraph within a
    given speech. The d-th document in the list is coded as d in the data.

  - Job Approval of the President (b), Gallup Approval Poll, Gallup approval poll of the president. Irregular
    frequency. Source: Woolley and Peters (2020)

    The URL in the bibliography links to tables with Gallup poll data for every president from 1949 tp 2007.
    We focus on the percentage of respondents who approve of how the President is handling his job.
    Polls are taken at irregular intervals. To construct quarterly averages of approval data, we avergage all
    polling data in a given quarter. The end date of each poll determines the quarter in which it is
    included. In a couple of quarters no polls have been conducted. In these cases we impute
    missing values by averaging results from the preceding and the following quarters.

    The file `Data.xlsx` contains a copy of the time series of the polling data.

  We have received permission from John Woolley to share the above mentioned (text) data files for the purpose
  of replicating the results in our paper. Any use beyond replicating the results in our paper requires
  approval from the APP.

- **U.S. Bureau of Economic Analysis**

  The following data is retrieved from the website of the B.E.A. The URLs in the bibilography links directly to
  the data file (a xlsx file). The account codes together with the information in the bibliography uniquely
  identify each time series. We use data at quarterly frequency ranging from 1949Q1 to 2007Q4. 

  - Implicit Price Deflator, Index 2012=100, quarterly frequency, seasonally adjusted. Source: U.S. Bureau of
    Economic Analysis (2020a), account code: A191RD

  - GDP (a), Gross domestic product, In millions of Dollars, quarterly frequency, seasonally adjusted at annual
    rate. Source: U.S. Bureau of Economic Analysis (2020b), account code: A191RC

  - Consumption (a), Personal consumption expenditures, In millions of Dollars, quarterly frequency, seasonally
    adjusted at annual rate. Source: U.S. Bureau of Economic Analysis (2020b), account code: DPCERC

  - Investment (a), Gross private investment, In millions of Dollars, quarterly frequency, seasonally adjusted at
    annual rate. Source: U.S. Bureau of Economic Analysis (2020b), account code: A006RC

  - Tax Receipts (a), Federal government current tax receipts, In billions of Dollars, quarterly frequency,
    seasonally adjusted at annual rate. Source: U.S. Bureau of Economic Analysis (2020c), account code: W006RC 

  - Income Taxes (a), Federal government personal income tax receipts, In billions of Dollars, quarterly
    frequency, seasonally adjusted at annual rate. Source: U.S. Bureau of Economic Analysis (2020c), account
    code: A074RC 

  - Corporate Taxes (a), Federal government corporate income tax receipts, In billions of Dollars, Quarterly
    Frequency, seasonally adjusted at annual rate. Source: U.S. Bureau of Economic Analysis (2020c), account
    code: B075RC

  - Payroll Taxes (a), Federal government payroll tax receipts, Contributions for government social insurance in
    billions of Dollars, quarterly frequency, seasonally adjusted at annual rate. Source: U.S. Bureau of Economic
    Analysis (2020c), account code: W780RC

  - Government Spending (a), Federal Government current Expenditures, In billions of Dollars, quarterly
    frequency, seasonally adjusted at annual rate. Source: U.S. Bureau of Economic Analysis (2020c), account
    code: W013RC

  Data from the B.E.A is in the public domain and may be used or reproduced without specific permission. The file
  `Data.xlsx` contains a copy of the time series we retrieved from the B.E.A.
  
- **U.S. Bureau of Labor Statistics**

  The data from the B.L.S. has been retrieved from the Federal Reserve Economic Data (FRED) database. The URLs
  in the bibilography lead to the download page at FRED. The downloaded time series are sampled at monthly
  frequency and range from 1949M1 to 2007M12.

  - CPI (b), Consumer Price Index for All Urban Consumers: All Items in U.S. City Average, Index 1982-1984=100,
    monthly frequency, seasonally adjusted. Source: U.S. Bureau of Labor Statistics (2020a)

  - Population (b), Civilian noninstitutional population is defined as persons 16 years of age and older residing
    in the 50 states and the District of Columbia [thousands of persons], monthly frequency, not seasonally
    adjusted. Source: U.S. Bureau of Labor Statistics (2020b)

  - Unemployment Rate (b), Unemployed as percentage of the labor force, Monthly frequency, seasonally adjusted.
    Source: U.S. Bureau of Labor Statistics (2020c)

  The data from the B.L.S. (retrieved from FRED) is in the public domain data can be used for personal,
  educational, and non-commercial purposes. The file `Data.xlsx` contains a copy of the following time series: 

- **Board of Governors of the Federal Reserve System**

  The following data is retrieved from the website of the Board of Governors of the Federal Reserve System. The
  URLs in the bibilography lead to the download page. The following two series are downloaded at monthly
  frequency.

   - 3-month T-Bill (b), Secondary market rate 3-month Treasury bill, Daily frequency. Source: Board of Governors
     of the Federal Reserve System (2020)
     
   - Federal Funds Rate (b), Federal funds effective rate, Daily frequency.
     Source: Board of Governors of the Federal Reserve System (2020)
  
  To retreive the data from the donwload page proceed as follows: 1. Navigate to the data download program (click on the
  item *Data Download*). 2. i) Choose *Data set: Selected Interest Rates*; ii) *Choose Instrument: FF* or *TB*; iii) Choose
  *Maturity: overnight* for *FF* and three month for *TB*; iv) Select *Frequency: Monthly*; v) Click on *Add to package*.
  3. Click on *Format package*; Choose Dates from 1949M1 to 2007M12 for TB and 1953M7 to 2007M12 for FF. 4. Choose
  your preferred file type and click on *Go to download*.

  Data obtained from the Federal Reserve Board is in the public domain and may be copied and distributed without
  permission. The file `Data.xlsx` contains a copy of the time series we retrieved from the Federal Reserve Board.

- **Federal Reserve Bank of Dallas**

  The following data is retrieved from the website of the Federal Reserve Bank of Dallas. The URL in the
  bibilography links directly to the data file (a xlsx file).

   - Government Debt$ (a, b), Par value of privately held gross federal debt, In millions of Dollars, monthly
     frequency, not seasonally adjusted, values reported are for the last business day of the month. Source:
     Federal Reserve Bank of Dallas (2020)

  Data obtained from the Federal Reserve Bank of Dallas is in the public domain and may be copied and
  distributed without permission. The file `Data.xlsx` contains a copy of the time series we retrieved from the
  Federal Reserve Bank of Dallas.

- **Romer and Romer (2010b)**

  The following data is from the *openicpsr* database. The URL in the bibilography links to the
  replication material. To retrieve the time series below,
  download the file *Romer-RomerFiscalData.xlsx*. The data is sampled at quarterly frequency. We use data on the
  following five time series from 1949Q1 to 2007Q4.

   - Cyclically Adjusted Revenue, Change in real cyclically adjusted federal government revenues as percent of
     real GDP. Source: Romer and Romer (2010b), variable "DRCARA"

   - RR All Tax Changes, RR's identified endogenous and exogenous tax changes divided by nominal GDP. Source:
     Romer and Romer (2010b), variable "SUMMANRRATIO"

   - RR Exogenous Tax Changes, RR's identified deficit-driven and long-run tax changes divided by nominal GDP.
     Source: Romer and Romer (2010b), variable "EXOGENRRATIO"

   - RR News All Tax Changes& Present value (at time of enactment) of RR's identified endogenous and exogenous
     tax changes divided by nominal GDP. Romer and Romer (2010b), variable "SUMMAPDVRATIO"
   
   - RR News Exogenous Tax Changes, Present value (at time of enactment) of RR's identified deficit-driven and
     long-run tax changes divided by nominal GDP. Source: Romer and Romer (2010b), variable "EXOGEPDVRATIO"

  The data is available under a Creative Commons Attribution 4.0 International Public License.
  The file `Data.xlsx` contains a copy of the five time series above.

- **Leeper et al. (2012b)**

  The code and date to construct the implicit tax rate is taken from the *openicpsr* database. The URL in the
  bibilography links to the replication material. All replication material needs to be downloaded.
  To (re-)construct the implict tax rate we run the authors's Matlab file *AFTR.m* (contained in the folder "*MFiles*") which produces
  the variable *ITR1Y* (as input the data file *Raw_Muni_Treasury_Fed_Data.csv* is required, which can be found in the folder "*Data*"
  in the authors's replication material). *ITR1Y* is time series of interest, sampled at monthly frequency. We use this time series
  to calculate quarterly averages. The data provided by the authors allows us to construct a time series
  of implicit tax rates from 1954Q1 to 2005Q4.

  - Implicit Tax Rate, Risk-adjusted implicit tax rate with one year maturity as constructed in Leeper et al.
    (2012a). Leeper et al. (2012a) define the implicit tax rate as $`1-Y_m/Y_t`$ where $`Y_m`$ is the yield of a municipal
    bond and Yt is the yield of a Treasury bond. We use municipal and treasury bond yields with one year maturity
    at monthly frequency. We use their provided Matlab code to construct rolling quarterly averages of monthly
    data. Source: Leeper et al. (2012b)

  The data is available under a Creative Commons Attribution 4.0 International Public License.
  The file `Data.xlsx` contains a copy of the time series above.

- **Mertens and Ravn (2014b)**

  The following time series is retrieved from Karel Mertens's personal webpage (https://karelmertens.com/). The URL in the
  bibilography links directly to the data file (a xlsx file). The provided time series, sampled at quarterly frequency,
  ranges from 1950Q1 to 2006Q4.
  
  - MR Unanticipated Tax Changes, Mertens and Ravn (2014a) identified exogenous tax changes for which the
    legislation and implementation date are less than one quarter apart. Source: Mertens and Ravn (2014b),
    variable ``Tax Narrative''.

   We have received the explicit permission from the authors to share the data above in this repository.
   The file `Data.xlsx` contains a copy of the time series above.

- **Shiller, R. (2020)**

  The following monthly time series is retrieved from Robert J. Shiller's personal webpage (https://shillerdata.com/). The URL in the
  bibilography links directly to the data file (a xls file). From the excel file we extract data ranging from 1949M1 to 2007M12.
  
  - S\&P500 (a,b), S\&P composite prices, Composite prices are daily-close, monthly averages. Source: Shiller
    (2020)
    
  We have received the explicit permission to share the data above in this repository.
  The file `Data.xlsx` contains a copy of the time series above.

- **Ramey (2011b)**

  The following quarterly time series is retrieved from Valerie Ramey's personal webpage (https://econweb.ucsd.edu/~vramey).
  The URL in the bibilography links directly to the data file (a xls file). From the excel file we extract data ranging from 1949Q1 to 2007Q4.

  - Government Spending News, Nominal present value of Ramey's government spending news variable divided b
    nominal GDP of the previous quarter. Source: Ramey (2011b), variable "pdvmily"

  We have received the explicit permission from the authors to share the data above in this repository.
  The file `Data.xlsx` contains a copy of the time series above.

- **Brookings Institution**

  The following data is retrieved from the website of The Brookings Institution's Vital Statistics on Congress. The URL in the
  bibilography links directly to the data file (a xlsx file).

  - Congress Concurrence, Presidential Victories on Votes in Congress, Percentages indicate the number of
    congressional votes supporting the president divided by the total number of votes on which the president had
    taken a clear position. The percentages are normalized to eliminate the effects of absences as follows: support = (support)/(support
    $`+`$ opposition). Yearly data from 1953 to 2007. Source: Brookings Institution (2022)

  We have received the explicit permission from the The Brookings Institution to share the data above in this repository.
  The file `Data.xlsx` contains a copy of the time series above.

(a): Variable is expressed in real per capita terms. We use the population measure from the B.L.S. and the GDP implicit price deflator from 
the B.E.A. to transform nominal quantities in real per capita terms. 

(b): Series is transformed into quarterly averages.


## Computational requirements

### Software Requirements

- [X] The replication package contains one or more programs to install all dependencies and set up the necessary
  directory structure.

- Python 3.10.12
    - `numpy` 1.24.4
    - `tqdm` 4.66.4
    - `pandas` 2.0.3
    - `matplotlib` 3.7.5
    - `wordcloud` 1.9.3
    - `mpltern` 1.0.4
    - the file "`requirements.txt`" lists these dependencies, please run "`pip install -r requirements.txt`" as the
    first step.
- g++ compiler 11.4.0 
    - boost c++ libraries installed (libboost-all-dev 1.74.0.3).
- Matlab 2019a
    - Statistics and Machine Learning Toolbox
- R 4.4.0
    - `this.path` 2.5.0
    - `zoo` 1.8-12
    - `glmnet` 4.1-8
    - `bootUR` 1.0.4
    - `readxl` 1.4.3
    - `ggplot2` 3.5.1
    - the file "`0_setup.R`" will install all dependencies (with the indicated version), and should be run once prior to running other programs.
    - Rtools 4.4 (Windows only) [https://cran.r-project.org/bin/windows/Rtools/](https://cran.r-project.org/bin/windows/Rtools/)
    - Xcode developer tools + GNU Fortran compiler 12.2 (MacOS only) [https://mac.r-project.org/tools/](https://mac.r-project.org/tools/)
    - Rtools (Windows) / Xcode developer tools + GNU Fortran compiler 12.2 (MacOS) I only needed to install dependency R packages from source in the specific version

The setup of the code uses bash scripting, which may require Linux.

### Controlled Randomness

- [X] Random seed is set at line 34 of file Correlation_Analysis.R.

### Memory, Runtime, Storage Requirements

#### Summary

Approximate time needed to reproduce the tax prevalence measure estimation on a standard (2024) desktop machine:

- [ ] <10 minutes
- [ ] 10-60 minutes
- [ ] 1-2 hours
- [ ] 2-8 hours
- [ ] 8-24 hours
- [ ] 1-3 days
- [ ] 3-14 days
- [X] \> 14 days

Approximate time needed to reproduce the analyses and figures on a standard (2024) desktop machine:

- [X] <10 minutes
- [ ] 10-60 minutes
- [ ] 1-2 hours
- [ ] 2-8 hours
- [ ] 8-24 hours
- [ ] 1-3 days
- [ ] 3-14 days
- [ ] \> 14 days

Approximate storage space needed:

- [ ] < 25 MBytes
- [ ] 25 MB - 250 MB
- [ ] 250 MB - 2 GB
- [X] 2 GB - 25 GB
- [ ] 25 GB - 250 GB
- [ ] \> 250 GB



#### Details

The calculations of the topic prevalence measures take about 2 weeks to run on a standard desktop machine.
All other analysis and calculations take about 2 minutes to run on a standard desktop machine.


## Description of programs/code

- Programs in `01-construction_prevalence_measures` will construct the prevalence measures from the pre-processed text data.
Descriptive statistics off the prevalence measures are also calculated.
These are the C++ and Python programs.
- Programs in `02-analysis_prevalence_measures` will perform the analysis of the prevalence measures. 
These are the R and Matlab programs.

### License for Code

The code is licensed under a CC-BY license. See [LICENSE.TXT](LICENSE.TXT) or [CC-BY](https://creativecommons.org/licenses/by/4.0/) for details.

## Instructions to Replicators

For the GitHub-only econometric workflow, run `00-setup/analysis_replication.sh --install`
on the first run and `00-setup/analysis_replication.sh` on subsequent runs, as described
above. The original instructions below describe the complete replication package and may
require additional Stage 1 files from openICPSR.

All software, dependencies and requirements are listed in the previous sections and should be installed.
The bash scripts in the folder `00-setup` assume a Linux environment (e.g., Ubuntu).

- For all files in the folder `00-setup`
  - Apply `chmod a+x` to the file `make_sh_executable.sh`.
  - run the file `make_sh_executable.sh` to make all bash files executable (e.g. `./make_sh_executable.sh`).

Since the tax prevalence measure estimation takes a long time to run, we include the partial results and different replication bash files.
- `00-setup/figures_replication.sh` that will run all code except the tax prevalence measure estimation `01-construction_prevalence_measures/RunLDA.py` and construction `01-construction_prevalence_measures/CalculateTopicPrevalences.py`.
  - This script is useful to replicate all figures and tables in the paper.
  - This scripts checks if all software is installed, creates the Python virtual environment and installs all R packages.
  - This script runs `01-construction_prevalence_measures/PrepareGraphs.py`, all R analysis files in `02-analysis_prevalence_measures/RCodes/`, all Matlab analysis files in `02-analysis_prevalence_measures/MatlabCodes/`.
- `00-setup/tax_prevalence_replication.sh` that will run all code and will run the tax prevalence measure estimation `01-construction_prevalence_measures/RunLDA.py` with only a few iterations in the 2-step LDA model. 
  - This script is useful to make sure the code is running correctly.
  - This script installs _libboost-all-dev_, compiles the `GibbsLDA.cpp` C++ code and runs `01-construction_prevalence_measures/RunLDA.py`.
  - Edit line 11 of the file `01-construction_prevalence_measures/RunLDA.py` to set `chk_code_runs = False`, if you want to run the full estimation. **(takes a long time to run)**

Here are the steps in each of the scripts (assumes all necessary software is installed):

### Steps to replicate all analysis and figures
- Create the Python environment by running `pip install -r 00-setup/requirements.txt` in the main directory.
- Run `01-construction_prevalence_measures/PrepareGraphs.py` to produce the wordclouds, topic prevalence graphs and the mixing proportions boxplots.
- Run `02-analysis_prevalence_measures/RCodes/0_setup.R` to install all dependencies.
- Run `02-analysis_prevalence_measures/RCodes/Run_all.R` to perform Granger causality and correlation analysis.
    - This script runs `02-analysis_prevalence_measures/RCodes/GC_analysis.R` and `02-analysis_prevalence_measures/RCodes/Correlation_analysis.R`.
- Run `02-analysis_prevalence_measures/MatlabCodes/Run_All.m` to perform all impulse response analyses, tests, and to create the plots of p-values for Granger causality tests.
  - Set the MATLAB current directory to `/02-analysis_prevalence_measures/MatlabCodes/`.
  - This script runs `02-analysis_prevalence_measures/MatlabCodes/IRs_Analysis`, `02-analysis_prevalence_measures/MatlabCodes/Predict_Analysis` and `02-analysis_prevalence_measures/MatlabCodes/Plot_pValues_GC`.


### Steps to check that the tax prevalence measure estimation is running correctly
- Compile the C++ code by running `g++ GibbsLDA.cpp -o GibbsLDA.out` in the `01-construction_prevalence_measures` directory.
- Create the Python environment by running `pip install -r 00-setup/requirements.txt` in the main directory.
- Run `01-construction_prevalence_measures/RunLDA.py` to estimate the 2-step LDA model. 


### Steps to run the full estimation of tax prevalence measure estimation **(takes a long time to run)**
- Compile the C++ code by running `g++ GibbsLDA.cpp -o GibbsLDA.out` in the `01-construction_prevalence_measures` directory.
- Create the Python environment by running `pip install -r 00-setup/requirements.txt` in the main directory.
- Edit line 11 of the file `01-construction_prevalence_measures/RunLDA.py` to set `chk_code_runs = False`.
- Run `01-construction_prevalence_measures/RunLDA.py` to estimate the 2-step LDA model. **(takes a long time to run)**
- Run `01-construction_prevalence_measures/CalculateTopicPrevalences.py` to calculate the topic prevalences.

### Details

Folder `00-setup`:
- `00-setup/check_softwares.sh` checks if all necessary software is installed.
- `00-setup/compile_gibbslda.sh` installs libboost-all-dev and compiles the `GibbsLDA.cpp` C++ code.
- `00-setup/create_python_env.sh` creates a Python environment and installs the necessary packages included in `requirements.txt`.
- `00-setup/make_sh_executable.sh` makes all bash files executable.
- `00-setup/run_matlab_analsysis.sh` runs all the Matlab analysis files included in `02-analysis_prevalence_measures/MatlabCodes/`.
- `00-setup/run_python_analysis.sh` loads the Python environment and runs `PrepareGraphs.py`.
- `00-setup/run_R_analysis.sh` installs all R packages and runs all the R analysis files included in `02-analysis_prevalence_measures/RCodes/`.
- `00-setup/figures_replication.sh` runs the figures replication code (see above).
- `00-setup/tax_prevalence_replication.sh` runs the tax prevalence measure estimation code (see above).


Folder `01-construction_prevalence_measures`:
- `01-construction_prevalence_measures/RunLDA.py` handles full procedure for the estimation of the 2-step LDA model.
    - Requires the compiled binary `GibbsLDA.out` (for Linux/OSX) or `GibbsLDA.exe` (for Windows) in the same directory. 
    - Requires directory `Data` with the files: `Data/corpus.csv`, `Data/lexicon_increase.csv_`, `Data/terms.csv`, `Data/doc_codes.csv`, `Data/lexicon_decrease.csv`, 
  `Data/tax_speeches.csv`, `Data/yang_dates.csv` and  `Data/eta2.csv` .
    - This script creates the directories `Est1`, `Est2` and `Results` to save the intermediate and final results of the first and second step of the LDA model.
    - *This code takes a very long time to run.*
    - The script has variable `chk_code_runs = True` to check if the code is running using only a few iterations.
    - It should be set to `False` to run the replications (see instructions to Replicators).
- `01-construction_prevalence_measures/CalculateTopicPrevalences.py` calculates topic prevalences from the estimated mixing proportions. 
  - Requires directory `Results` with the files `Results/theta1.csv` and `Results/theta2.csv`. 
  - Saves the calculated prevalences in `Results/prevalences.csv`.
  - To assist in the replication of figures, a `Results` folder is also shared (see instructions to Replicators).
- `01-construction_prevalence_measures/PrepareGraphs.py` produces the wordclouds, topic prevalence graphs and the mixing proportions boxplots. 
  - This script creates the directory `Graphs` to save the produced graphs.

Folder `02-analysis_prevalence_measures`:
- `02-analysis_prevalence_measures/RCodes/0_setup.R` installs all dependencies.
  - Requires directory `input` with the file `input/HDGCvar_0.2.0.tar.gz` (HDGCvar package).
- `02-analysis_prevalence_measures/RCodes/Run_all.R` runs the following scripts:
- `02-analysis_prevalence_measures/RCodes/GC_analysis.R` performs the Granger causality analysis.
  - Requires directory `input` with the files `input/Data.xlsx`, `input/PrevalenceMeasures.xlsx` and `input/Functions.R` (auxiliary functions).
  - Saves the p-values in `MatlabCodes/DataCopy/GC_pValues.csv`.
- `02-analysis_prevalence_measures/RCodes/Correlation_analysis.R` performs the correlation analysis.
  - Requires directory `input` with the files `input/Data.xlsx`, `input/PrevalenceMeasures.xlsx`, `input/TopicLabels.csv` and `input/Functions.R` (auxiliary functions)..
  - Saves the figure in `output/Figure_A2_Correlations.pdf`.
- `02-analysis_prevalence_measures/MatlabCodes/IRs_Analysis.m` performs all impulse response analyses
  - Saves figures to `MatlabCodes/Output/Figures`.
- `02-analysis_prevalence_measures/MatlabCodes/Pred_Analysis.m` performs all tests.
  - Saves tables to `MatlabCodes/Output/Tables`.
- `02-analysis_prevalence_measures/MatlabCodes/Plot_pValues_GC.m` creates the plots of p-values in `GC_pValues.csv` (created by `RCodes/GC_analysis.R`).
  - Saves figures to `MatlabCodes/Output/Figures`
- `02-analysis_prevalence_measures/MatlabCodes/AuxFunction/` contains the auxiliary functions used in Matlab analysis.   


## List of tables and programs


The provided code reproduces:

- [ ] All numbers provided in text in the paper
- [ ] All tables and figures in the paper
- [X] Selected tables and figures in the paper, as explained and justified below.

Only tables done in LaTeX are excluded from code.

TODO: Check line numbers before submitting.

| Figure/Table # | Program/Code                                                    | Line Number | Output File                         | Note                 |
|----------------|-----------------------------------------------------------------|-------------|-------------------------------------|----------------------|
| Figure 1       | 01-construction_prevalence_measures/PrepareGraphs.py            | 82, 88      | wc_TaxGeneral.pdf, wc_Top01.pdf     | (1)                  |
| Figure 2       | 01-construction_prevalence_measures/PrepareGraphs.py            | 259         | theta_boxplots.pdf                  |                      |
| Table 1        | Own construction Latex                                          |             |                                     |                      |
| Table 2        | Own construction Latex                                          |             |                                     |                      |
| Figure 3       | 01-construction_prevalence_measures/PrepareGraphs.py            | 174         | tax_topic_prevalences.pdf           |                      |
| Figure 4       | 01-construction_prevalence_measures/PrepareGraphs.py            | 184         | prev_topic_9.pdf, prev_topic_15.pdf | Cold War/ War Terror |
| Figure 5       | 02-analysis_prevalence_measures/MatlabCodes/Plot_pValues_GC.m   | 88          | Figure5.pdf                         |                      |
| Table 3        | 02-analysis_prevalence_measures/MatlabCodes/Predict_Analysis.m  | 315         | Table3.pdf                          |                      |
| Figure 6       | 02-analysis_prevalence_measures/MatlabCodes/IRs_Analysis.m      | 402         | Figure6.pdf                         |                      |
| Figure 7       | 02-analysis_prevalence_measures/MatlabCodes/IRs_Analysis.m      | 688         | Figure7.pdf                         |                      |
| Table A.1      | 02-analysis_prevalence_measures/MatlabCodes/Predict_Analysis.m  | 341         | TableA1.pdf                         |                      |
| Table A.2      | 02-analysis_prevalence_measures/MatlabCodes/Predict_Analysis.m  | 366         | TableA2.pdf                         |                      |
| Table A.3      | 02-analysis_prevalence_measures/MatlabCodes/Predict_Analysis.m  | 389         | TableA3.pdf                         |                      |
| Table A.4      | 02-analysis_prevalence_measures/MatlabCodes/Predict_Analysis.m  | 412         | TableA4.pdf                         |                      |
| Table A.5      | 02-analysis_prevalence_measures/MatlabCodes/Predict_Analysis.m  | 436         | TableA5.pdf                         |                      |
| Table A.6      | 02-analysis_prevalence_measures/MatlabCodes/Predict_Analysis.m  | 459         | TableA6.pdf                         |                      |
| Table A.7      | 02-analysis_prevalence_measures/MatlabCodes/Predict_Analysis.m  | 483         | TableA7.pdf                         |                      |
| Table A.8      | 02-analysis_prevalence_measures/MatlabCodes/Predict_Analysis.m  | 507         | TableA8.pdf                         |                      |
| Figure A.1     | 02-analysis_prevalence_measures/MatlabCodes/Plot_pValues_GC.m   | 158         | FigureA1.pdf                        |                      |
| Figure A.2     | 02-analysis_prevalence_measures/RCodes/Correlation_analysis.R   | 64          | Figure_A2_Correlations.pdf          |                      |
| Figure A.3     | 02-analysis_prevalence_measures/MatlabCodes/IRs_Analysis.m      | 608         | FigureA3.pdf                        |                      |
| Figure A.4     | 02-analysis_prevalence_measures/MatlabCodes/IRs_Analysis.m      | 612         | FigureA4.pdf                        |                      |
| Figure A.5     | 02-analysis_prevalence_measures/MatlabCodes/IRs_Analysis.m      | 525         | FigureA5.pdf                        |                      |
| Figure A.6     | 02-analysis_prevalence_measures/MatlabCodes/IRs_Analysis.m      | 685         | FigureA6.pdf                        |                      |
| Figure A.7     | 02-analysis_prevalence_measures/MatlabCodes/IRs_Analysis.m      | 857         | FigureA7.pdf                        |                      |
| Figure A.8     | 02-analysis_prevalence_measures/MatlabCodes/IRs_Analysis.m      | 929         | FigureA8.pdf                        |                      |
| Figure B.1     | 01-construction_prevalence_measures/PrepareGraphs.py            | 286         | AppendixB1.pdf                      |                      |
| Table C.1      | Own construction Latex                                          |             |                                     |                      |
| Table D.1      | Own construction Latex                                          |             |                                     |                      |
| Table D.2      | Own construction Latex                                          |             |                                     |                      |
| Figure D.1     | 01-construction_prevalence_measures/PrepareGraphs.py            | 88          | wc_Top02.pdf – wc_Top10.pdf         | Tax topics           |
| Figure D.2     | 01-construction_prevalence_measures/PrepareGraphs.py            | 88          | wc_Top11.pdf – wc_Top25.pdf         | All other topics     |

(1) random_state and scale options where not set on the wordcloud function, so the position of words can change in the figure.


## References

Board of Governors of the Federal Reserve System (2020). Selected Interest Rates, Table H-15. Retrieved June, 2020 
from https://www.federalreserve.gov/releases/H15/default.htm.

Brookings Institution (2022). Vital statistics on Congress, Chapter 8 - Political polarization in Congress and changing 
voting alignments, Table 8-1. Retrieved January, 2023 from 
https://www.brookings.edu/wp-content/uploads/2017/01/vitalstats_ch8_tbl1.xlsx.

Federal Reserve Bank of Dallas (2020). Market Value of U.S. Government Debt. Retrieved June, 2020 from 
https://www.dallasfed.org/~/media/documents/research/govdebt.xlsx.

Leeper, E. M., A. W. Richter, and T. B. Walker (2012b). Replication data for: Quantitative effects of fiscal foresight. 
Nashville, TN: American Economic Association; distributed by Inter-university Consortium for Political and Social 
Research, Ann Arbor, MI. https://doi.org/10.3886/E114780V1.

Mertens, K. and M. O. Ravn (2014b). Replication data for: A reconciliation of SVAR and narrative estimates of tax 
multipliers. retrieved June, 2020 from https://karelmertens.com/wp-content/uploads/2017/09/jme2014_data.xls.

Ramey, V. A. (2011b). Replication data for: Identifying government spending shocks: It’s all in the timing. retrieved 
June, 2020 from https://econweb.ucsd.edu/~vramey/research/Ramey_Govt_Public_Data.xls.

Romer, C. D. and D. H. Romer (2009). A narrative analysis of postwar tax changes. Working paper, University of 
California, Berkeley. https://eml.berkeley.edu/~dromer/papers/nadraft609.pdf.

Romer, C. D. and D. H. Romer (2010b). Replication data for: The macroeconomic effects of tax changes: Estimates based 
on a new measure of fiscal shocks. Nashville, TN: American Economic Association; distributed by Inter-university 
Consortium for Political and Social Research, Ann Arbor, MI. https://doi.org/10.3886/E112357V1.

Shiller, R. (2020). Us stock price, earnings and dividends as well as interest rates and cyclically adjusted price 
earnings ratio (cape) since 1871. Retrieved June, 2020 from https://img1.wsimg.com/blobby/go/e5e77e0b-59d1-44d9-ab25-4763ac982e53/downloads/e1fcc664-eaa1-48ed-b682-88e0c33db496/ie_data.xls?ver=1733242673788 this link can be found on https://shillerdata.com/.

U.S. Bureau of Economic Analysis (2020b). Section 1 - Domestic Product and Income, Table 1.1.5, National Income and 
Product Accounts Tables. Retrieved June, 2020 from 
https://apps.bea.gov/national/Release/XLS/Survey/Section1All_xls.xlsx.

U.S. Bureau of Economic Analysis (2020c). Section 3 - Government Current Receipts and Expenditures, Table 3.2, National
Income and Product Accounts Tables. Retrieved June, 2020 from 
https://apps.bea.gov/national/Release/XLS/Survey/Section3All_xls.xlsx.

U.S. Bureau of Labor Statistics (2020a). Consumer Price Index for All Urban Consumers: All Items in U.S. City Average. 
Retrieved June, 2020 from https://fred.stlouisfed.org/series/CPIAUCSL.

U.S. Bureau of Labor Statistics (2020c). Unemployment Rate. Retrieved June, 2020 from 
https://fred.stlouisfed.org/series/UNRATE.

Woolley, J. and G. Peters (2019). The American Presidency Project. University of California, Santa Barbara. Retrieved 
March, 2019 from https://www.presidency.ucsb.edu/documents

Woolley, J. and G. Peters (2020). The American Presidency Project. University of California, Santa Barbara. Retrieved 
June, 2020 from https://www.presidency.ucsb.edu/statistics/data/presidential-job-approval-all-data

Yang, S.-C. S. (2007). A chronology of postwar US federal income tax policy. CAEPR Working Papers 2007-021, Center for 
Applied Economics and Policy Research, Indiana University. https://caepr.indiana.edu/RePEc/inu/caeprp/caepr2007-021.pdf

---


