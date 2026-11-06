import os
from sys import platform
import errno
import subprocess
from glob import glob
from tqdm import tqdm
from datetime import datetime as dt
import numpy as np

# Check for code running, small number of iterations performed, otherwise goes to defaults.
chk_code_runs = True
if chk_code_runs:
    args_fast_run = ["maxIter=2", "saveAfter=1", "saveEvery=1"]
else:
    args_fast_run = []

# Set number of topics
nTop = 25

# SETUP FOLDERS
rootDir = os.getcwd()

# Specify folder containing corpus
# using os.path.join to ensure compatibility with different operating systems
dataDir = os.path.join(rootDir, "Data", '')

# Specify folders to output estimation results
est1Dir = os.path.join(rootDir, "Est1", '')
est2Dir = os.path.join(rootDir, "Est2", '')
resultsDir = os.path.join(rootDir, "Results", '')

# Create folders if necessary
try:
    os.mkdir(est1Dir)
except OSError as exc:
    if exc.errno != errno.EEXIST:
        raise
    pass

try:
    os.mkdir(est2Dir)
except OSError as exc:
    if exc.errno != errno.EEXIST:
        raise
    pass

try:
    os.mkdir(resultsDir)
except OSError as exc:
    if exc.errno != errno.EEXIST:
        raise
    pass

# STEP ONE - Unsupervised LDA

# Prepare arguments (for modifications see README file)
args = ["writePath=" + est1Dir, "readPath=" + dataDir, "nTop=" + str(nTop)]
args = [*args, *args_fast_run]


def run_lda(root_dir, lda_args):
    start = dt.now()
    if platform == "win32":  # os.name == 'nt'
        command_lda = [os.path.join(root_dir, "GibbsLDA.exe")] + lda_args
    else:
        command_lda = [os.path.join(root_dir, "GibbsLDA.out")] + lda_args
    result = subprocess.run(command_lda, capture_output=True)
    if result.stderr:
        raise subprocess.CalledProcessError(
            returncode=result.returncode,
            cmd=result.args,
            stderr=result.stderr
        )
        print(retuncode, stderr)
    end = dt.now()
    elapsed = end - start
    print("Took: %02d:%02d:%02d:%02d" % (
        elapsed.days, elapsed.seconds // 3600, elapsed.seconds // 60 % 60, elapsed.seconds % 60))


print(f"Start of step 1 estimation of the LDA model with {nTop} topics. This will take a while.")
print(f"Logs are saved in {est1Dir}")
run_lda(rootDir, args)


# Aggregate results into estimates of phi and theta - calculate posterior means
def AggregateTheta(estDir):
    # Get file lists
    listDoctops = sorted(glob(estDir + "doctop*"))
    listAlphas = sorted(glob(estDir + "alpha*"))
    nFiles = len(listDoctops)

    # Get shape - tokens x topics
    shape = np.loadtxt(listDoctops[0], delimiter=",").shape

    aggTheta = np.full(shape, 0, dtype=float)

    # Aggregate
    for i in tqdm(range(nFiles)):
        doctop = np.loadtxt(listDoctops[i], delimiter=",")
        alpha = np.loadtxt(listAlphas[i], delimiter=",")

        aggTheta += doctop
        aggTheta += alpha

    # Standardize
    theta = aggTheta / aggTheta.sum(axis=1)[:, np.newaxis]
    return theta


def AggregatePhi(estDir, eta=None):
    knownEta = (eta is not None)

    # Get file lists
    listTopterms = sorted(glob(estDir + "topterm*"))
    if not knownEta:
        listEtas = sorted(glob(estDir + "eta*"))
    nFiles = len(listTopterms)

    # Get shape
    shape = np.loadtxt(listTopterms[0], delimiter=",").shape

    aggPhi = np.full(shape, 0, dtype=float)

    # Aggregate
    for i in tqdm(range(nFiles)):
        topterm = np.loadtxt(listTopterms[i], delimiter=",")
        if not knownEta:
            eta = np.loadtxt(listEtas[i], delimiter=",")

        aggPhi += topterm
        aggPhi += eta

    # Standardize
    phi = aggPhi / aggPhi.sum(axis=1)[:, np.newaxis]
    return phi


theta1 = AggregateTheta(est1Dir)
phi1 = AggregatePhi(est1Dir)

print(f"Results of step 1 estimation saved in {resultsDir}.")
# Save to results
np.savetxt(os.path.join(resultsDir, "theta1.csv"), theta1, fmt='%.14f', delimiter=',')
np.savetxt(os.path.join(resultsDir, "phi1.csv"), phi1, fmt='%.14f', delimiter=',')

# CONSTRUCT INFORMED TOPIC PRIORS

m1 = 100  # Boost term probability by
m2 = 100  # Reduce term probability by
m3 = 10000  # Prior strength

# Load dictionary and lexicons
termList = np.loadtxt(os.path.join(dataDir, "terms.csv"), dtype=str)
lexiconInc = np.loadtxt(os.path.join(dataDir, "lexicon_increase.csv"), dtype=str)
lexiconDec = np.loadtxt(os.path.join(dataDir, "lexicon_decrease.csv"), dtype=str)

# Find the tax topic
kTax = phi1[:, termList == "tax"].argmax()
with open(os.path.join(resultsDir, 'k_tax.txt'), 'w') as fileOut:
    fileOut.write(str(kTax))

# Tax topics' priors (0 - increase, 1 - decrease)
eta2Inc = phi1[kTax].copy()
eta2Dec = phi1[kTax].copy()

for term in lexiconInc:
    eta2Inc[termList == term] *= m1
    eta2Dec[termList == term] /= m2

for term in lexiconDec:
    eta2Inc[termList == term] /= m2
    eta2Dec[termList == term] *= m1

# Standardize
eta2Inc /= eta2Inc.sum()
eta2Dec /= eta2Dec.sum()

# Priors for the other topics (2-...) have the same shape as estimated phi
eta2Rest = np.delete(phi1, kTax, axis=0)

# Create final eta
eta2 = np.concatenate((eta2Inc[np.newaxis, :], eta2Dec[np.newaxis, :], eta2Rest))
eta2 *= m3

# Save to dataDir because the cpp code expects it there
np.savetxt(os.path.join(dataDir, "eta2.csv"), eta2, fmt='%.14f', delimiter=',')

# STEP TWO - Semi-supervised LDA
# Prepare arguments (for modifications see README file)
args_s2 = ["writePath=" + est2Dir,
           "readPath=" + dataDir,
           "nTop=" + str(nTop + 1),
           "etaKnown=1"]
args_s2 = [*args_s2, *args_fast_run]

print(f"Start of step 1 estimation of the LDA model with {nTop+1} topics. This will take a while.")
print(f"Logs are saved in {est2Dir}")
run_lda(rootDir, args_s2)

# Aggregate results into estimates of phi and theta
theta2 = AggregateTheta(est2Dir)
phi2 = AggregatePhi(est2Dir, eta2)

# Save to results
print(f"Results of step 2 estimation saved in {resultsDir}.")
np.savetxt(os.path.join(resultsDir, "theta2.csv"), theta2, fmt='%.14f', delimiter=',')
np.savetxt(os.path.join(resultsDir, "phi2.csv"), phi2, fmt='%.14f', delimiter=',')
