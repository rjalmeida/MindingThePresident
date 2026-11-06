This README gives detailed instructions on how to use the Python (and C++) codes for constructing the prevalence measures from the pre-processed text data. 

The project structure is as follows: 
```
.
├──LDA
│  ├──Data ***
│  │  ├──corpus.csv
│  │  ├──doc_codes.csv
│  │  ├──lexicon_decrease.csv
│  │  ├──lexicon_increase.csv
│  │  ├──tax_docs.csv
│  │  ├──tax_lexicons.csv
│  │  ├──tax_speeches.csv
│  │  ├──terms.csv
│  │  └──yang_dates.csv
│  ├──Est1 *
│  ├──Est2 *
│  ├──Results *
│  │  ├──k_tax.csv
│  │  ├──phi1.csv
│  │  ├──phi2.csv
│  │  ├──prevalences.csv
│  │  ├──theta1.csv
│  │  └──theta2.csv
│  ├──Graphs *
│  ├──GibbsLDA.cpp
│  ├──GibbsLDA.out **
│  ├──RunLDA.py
│  ├──CalculateTopicPrevalences.py
│  └──PrepareGraphs.py
├──README.md
└──requirements.txt
```
where:
- \* Indicates that the directory (and files in directory) is created by the code.
- ** Indicates that the file is created by compiling the code.
- *** Indicates that the directory is created by the user using the downloaded data.

The _Data_ directory contains the following files:
- terms.csv is the list of terms used in the speeches (vocabulary). The i-th term in the list is coded as i in the data.
- doc_codes.csv is the list of documents. The first 8 digits indicate the date of the speech (YYYYMMDD). The following 2 digits indicate the number of the speech within given day. The last 3 digits indicate the number of the paragraph within a given speech. The d-th document in the list is coded as d in the data.
- corpus.csv is the processed presidential speeches. Each row represents a single token. The first column indicates the term (see terms.csv), the second column indicates the document (see doc_codes.csv)
- lexicon_increase.csv is the list of terms identified as indicative of discussing tax hikes
- lexicon_decrease.csv is the list of terms identified as indicative of discussing tax cuts
- tax_speeches.csv is the list of speeches identified as tax announcements by Romer and Romer (2009) and Yang (2007). The first 8 digits of 'Code' indicate the date of the speech (YYYYMMDD). The following 2 digits indicate the number of the speech within given day. 'Policy' is the name eventually given to the announced legislation. 'Direction' indicates whether the legislation resulted in net increase (1) or decrease (-1) of tax liabilities. 'Mixed' indicated whether the legislation consisted of both measures that increased and decreased certain taxes. 'Description' is the name given to the speech in the Public Papers of the Presidents.
- yang_dates.csv is the list of legislative lags identified by Yang (2007). 'DATE_ANN' is the date of the first announcement of given legislation. 'DATE_ENA' is the date the legislation was enacted (i.e. signed by the president). 'Direction' indicates whether the legislation resulted in net increase (1) or decrease (-1) of tax liabilities.


# Preparation:

## Data:
The pre-processed data can be found in the folder _Data_. Since running the code (_RunLDA.py_) may take several weeks, we 
have collected all output in the _Results_ folder.

## Compile C++ code:
- GibbsLDA.cpp requires a g++ compiler (tested 9.4.0 and 11.4.0) with boost c++ libraries installed 
(tested libboost-all-dev 1.71.0 and 1.74.0.3).

Example (Ubuntu):
```bash
sudo apt install libboost-all-dev
```
Compile (Ubuntu):
```bash
g++ GibbsLDA.cpp -o GibbsLDA.out
```

The program takes the following keyword arguments (* indicates non-optional):

- writePath* - path to save outputs
- readPath* - path from which the necessary data is read
- dataFile - name of the corpus file (default=corpus.csv)
- etaFile - name of the file containing eta used in the second step (default=eta.csv)
- nTop* - number of topics
- cAlpha - shape parameter of alpha prior (default=0.01)
- sAlpha - scale parameter of alpha prior (default=100)
- etaKnown - if =1 then eta assumed to be know (loaded from etaFile)
- cEta - shape parameter of eta prior, if eta not know (default=0.01)
- sEta - scale parameter of eta prior, if eta not know (default=100)
- seed - random seed, if -1 then random (default=0)
- maxIter - number of iterations to perform (default=15000)
- saveAfter - number of iterations after which parameters are logged (default=5000)
- saveEvery - log parameters each saveEvery iterations, if 1 then log every iteration (default=10)

## Python Code:
It is advisable to use a virtual environment to install the required packages, indicated in the _requirements.txt_ file.

Documentation to learn about virtual environments can be found: https://docs.python.org/3/tutorial/venv.html

Sample instructions (in Ubuntu):

### 1. Install `python3-venv` or `python3.x-venv`
If your system doesn't have `venv` library, install it using apt.

```bash
sudo apt install python3-venv
```

### 2. To create a virtual environment, decide which directory where you want to place it
You should place it in the directory where you will be working on your project and where you already stored all files.
For example:
```bash
mkdir MindingThePresident
cd MindingThePresident
```

### 3. Run `venv` module as a script in your chosen directory path
```bash
python3 -m venv .venv
```

That command will create a new `.venv` directory in your directory. The new directory contains a copy of Python 
interpreter and various supporting files.

### 4. Activate your virtual environment
To activate the virtual environment, you need to run the script that is in the `bin` directory inside the virtual 
environment directory.

```bash
source .venv/bin/activate
```

After you run this command, the terminal or command prompt you used will show what virtual environment you are 
using.

### 5. Install packages from `requirements.txt`
```bash
pip install -r requirements.txt
```
This will run `pip install package-name` repeatedly as many the packages listed in `requirement.txt`.

### 6. Run the python code
For example to run the first file `RunLDA.py`:
```bash
python RunLDA.py
```

### 7. Deactivate the virtual environment
To deactivate the virtual environment, you can run the following command:
```bash
deactivate
```

# Code:

1. `RunLDA.py` handles full procedure for the estimation of the 2-step LDA model. It requires a /Data/ folder containing 
_corpus.csv_, _lexicon_increase.csv_, _terms.csv_, _doc_codes.csv_, _lexicon_decrease.csv_, 
_tax_speeches.csv_, _yang_dates.csv_ and  _eta2.csv_ (created in first step). This script creates the directories 
_Est1_, _Est2_ and _Results_ to save the intermediate and final results of the first and second step of the LDA model. 
*This code takes a very long time to run, probably a couple of weeks.* The script has variable `chk_code_runs = True` to
check if the code is running using only a few iterations. It should be set to `False` to run the replications.

2. `CalculateTopicPrevalences.py` calculates topic prevalences from the estimated mixing proportions. Assumes directory
_Results_ exists and contains _theta1.csv_ and _theta2.csv_ files. This script creates the directory _Graphs_ to save the
calculated prevalences in _prevalences.csv_. This file can be run using the results folder that can be found in the 
shared folder.

3. `PrepareGraphs.py` produces the wordclouds, topic prevalence graphs and the mixing proportions boxplots, after 
running both previous files. This script creates the directory _Graphs_ to save the produced graphs.

