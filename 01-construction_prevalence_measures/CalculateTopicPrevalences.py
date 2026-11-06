import os

import numpy as np
import pandas as pd

import datetime as dt

# SETUP FOLDERS
rootDir = os.getcwd()

# Specify folder containing additional data
dataDir = os.path.join(rootDir, "Data", '')

# Specify folders containing estimation results
resultsDir = os.path.join(rootDir, "Results", '')

# Read document codes
docCodes = np.loadtxt(os.path.join(dataDir, "doc_codes.csv"), dtype=str)

# Read theta from the second step
colNames = ["Top_" + str(i) for i in range(26)]
theta2 = pd.read_csv(os.path.join(resultsDir, "theta2.csv"), names=colNames)
theta2.index = docCodes

# Add the general tax topic estimated in the first step
with open(resultsDir + "k_tax.txt", 'r') as fileIn:
    kTax = int(fileIn.read())

theta2["TaxGeneral"] = np.loadtxt(os.path.join(resultsDir, "theta1.csv"), delimiter=",")[:, kTax]

# Get quarter's from document code
dates = [dt.datetime.strptime(docCode[0:8], '%Y%m%d') for docCode in docCodes]
theta2['DATE'] = dates
theta2['DATE'] = theta2['DATE'].dt.to_period('Q')

# Aggregate by quarter and compute means
prev = theta2.groupby('DATE').mean()

prev.to_csv(os.path.join(resultsDir, 'prevalences.csv'))

# Prepare the data for further analysis
project_dir = os.path.normpath(os.getcwd() + os.sep + os.pardir)
results_dir_r = os.path.join(project_dir, "02-analysis_prevalence_measures/RCodes/input/")
results_dir_matlab = os.path.join(project_dir, "02-analysis_prevalence_measures/MatlabCodes/DataCopy/")

# Drop the last row (single quarter)
prev.drop(prev.tail(1).index, inplace=True)

# Load extra data from the first step
aux_theta1 = pd.read_csv(os.path.join(resultsDir, "aux_theta1.csv"))
prev_xlsx = pd.concat([prev.iloc[:, :-1], aux_theta1], axis=1)
# Export to xlsx
prev_rep_names = [f"prev_t {i}" for i in range(2, 26)]
prev_names = ["Quarter", "prev_tax_hike", "prev_tax_cut"] + prev_rep_names + ["prev_tax_1st_stage",
                                                                              "lex_ave_tax_hike",
                                                                              "lex_ave_tax_cut"]
prev_xlsx.reset_index(inplace=True)
prev_xlsx.to_excel(os.path.join(results_dir_r, 'PrevalenceMeasures.xlsx'), index=True, header=prev_names)
prev_xlsx.to_excel(os.path.join(results_dir_matlab, 'PrevalenceMeasures.xlsx'), index=True, header=prev_names)

# Description of the topics
col_index_excel = [chr(i) for i in range(ord('A'), ord('Z') + 1)] + ["A" + chr(i) for i in
                                                                     range(ord('A'), ord('D') + 1)]
# This description was made manually, as described in the paper
col_topic_names = ("Quarter",
                   "Tax Hike",
                   "Tax Cut",
                   "Social Services",
                   "Legislative Process",
                   "Persuasive Rhetoric",
                   "Public Administration",
                   "Natural Resources, Energy & Technology",
                   "Health Care",
                   "Proclamations of Unity & Patriotism",
                   "Cold War",
                   "Nature & Environment",
                   "Tradition and Conservative Values",
                   "Middle East",
                   "Informal Speech",
                   "Executive Orders",
                   "War on Terror",
                   "Interviews",
                   "Crime",
                   "American Values",
                   "Paying Respect to Armed Forces",
                   "National Security & Emergencies",
                   "Economic Development",
                   "International Relations/Diplomacy",
                   "Freedom & Patriotism",
                   "Expressing Gratitude in Speeches",
                   "International Economics & Trade",
                   "General Tax Topic",
                   "Tax Hike - Lexicon approach",
                   "Tax Cut Lexicon - Lexicon approach")

col_notes = ["Main Tax News Measure used in Paper"] * 2 + [' ' for i in range(1, 25)] + \
            ['Prevalence of general tax topic estimated in the first step of LDA'] +\
            ['Measures have been created by counting how many tokens from a given lexicon are present in the documents. For each document a proportion of tokens that belong to a lexicon is calculated. Then, those proportions are averaged for each quarter (this is the most similar approach to what we use to calculate topic-based prevalences)']

# create a pandas dataframe
desc_topics = pd.DataFrame(list(zip(col_index_excel, prev_names, col_topic_names, col_notes)),
                           columns=["Column", "Name", "Topic", "Notes"])

# Export to xlsx
desc_topics.to_excel(os.path.join(results_dir_r, 'PrevalenceMeasures_DescriptionTopics.xlsx'), index=False)
desc_topics.to_excel(os.path.join(results_dir_matlab, 'PrevalenceMeasures_DescriptionTopics.xlsx'), index=False)
