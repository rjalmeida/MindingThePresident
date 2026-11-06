import os
import errno
import numpy as np
import pandas as pd
from tqdm import tqdm
from mpltern.datasets import get_dirichlet_pdfs

from matplotlib import pyplot as plt
from wordcloud import WordCloud as WC

# SETUP FOLDERS
rootDir = os.getcwd()

# Specify folder containing additional data
dataDir = os.path.join(rootDir, "Data", "")

# Specify folders containing estimation results
resultsDir = os.path.join(rootDir, "Results", "")

# Specify folders to output graphs
graphsDir = os.path.join(rootDir, "Graphs", "")

try:
    os.mkdir(graphsDir)
except OSError as exc:
    if exc.errno != errno.EEXIST:
        raise
    pass

# PREPARE WORDCLOUDS
# Functions for coloring the terms
def GreyColorFunc(word, font_size, position, orientation, random_state=None, **kwargs):
    return (120, 120, 120)


def LexiconColorFunc(word, font_size, position, orientation, random_state=None, **kwargs):
    # Color the words based on lexicons
    if word not in lexiconInc and word not in lexiconDec:
        return (120, 120, 120)
    elif word in lexiconInc:
        return '#2c90c9'
    elif word in lexiconDec:
        return '#c98000'

# Function for preparring and plotting a wordcloud
def DoWordCloud(phi_k, topN, color_func, saveAs):
    # Get the topN terms with probabilities
    sel = (-phi_k).argsort()[0:topN]
    top = [(termList[termInd], phi_k[termInd]) for termInd in sel]

    # Prepare wordcloud
    wc = WC(width=2400, height=1400, prefer_horizontal=1,
            background_color='white').fit_words(dict(top))

    # Recolor
    plt.figure(figsize=(24, 14))
    plt.imshow(wc.recolor(color_func=color_func))

    # Save
    plt.axis("off")
    plt.tight_layout()
    plt.savefig(saveAs)
    plt.close()


# Load the list of terms and the lexicons
termList = np.loadtxt(os.path.join(dataDir, "terms.csv"), dtype=str)
lexiconInc = np.loadtxt(os.path.join(dataDir, "lexicon_increase.csv"), dtype=str)
lexiconDec = np.loadtxt(os.path.join(dataDir, "lexicon_decrease.csv"), dtype=str)

# Read which topic was identified as TaxGeneral in step 1
with open(os.path.join(resultsDir, "k_tax.txt"), 'r') as fileIn:
    kTax = int(fileIn.read())

# Load phi from step 1 and from step 2
phi1 = np.loadtxt(os.path.join(resultsDir, "phi1.csv"), delimiter=',')
# phi2 = np.loa(os.path.join(resultsDir, "phi2-original.csv"), delimiter=',')
phi2 = np.loadtxt(os.path.join(resultsDir, "phi2.csv"), delimiter=',')

# Create wordclouds
# General tax topic (first step)
DoWordCloud(phi1[kTax], 150, LexiconColorFunc, os.path.join(graphsDir, 'wc_TaxGeneral.pdf'))
plt.close()
# All the topics from second step
for k in tqdm(range(26)):
    if k <= 1:
        # For tax topics color the terms based on lexicons
        DoWordCloud(phi2[k], 150, LexiconColorFunc, os.path.join(graphsDir, 'wc_Top' + "%02d" % k + '.pdf'))
        plt.close()
    if k >= 2:
        DoWordCloud(phi2[k], 150, GreyColorFunc, os.path.join(graphsDir, 'wc_Top' + "%02d" % k + '.pdf'))
        plt.close()


# TOPIC PREVALENCES + LEGISLATIVE LAG

prev = pd.read_csv(os.path.join(resultsDir, 'prevalences.csv'), index_col=0, parse_dates=True)
yangDates = pd.read_csv(os.path.join(dataDir, 'yang_dates.csv'))
anns = pd.to_datetime(yangDates.DATE_ANN)
enas = pd.to_datetime(yangDates.DATE_ENA)
signs = yangDates.Direction

fig, ax = plt.subplots(2, 1, sharex='col', figsize=(10, 6))

# AX1 - increase
ax[0].plot(prev.Top_0, color='#2475a3', lw=1.5, label='Tax increase topic prevalence')
ax[0].set_ylim(0, 0.15)
ax[0].set_ylabel('Topic prevalence')
ax[0].set_frame_on(False)

alpha = 0.2
first_inc = True
first_dec = True
for sign, ann, ena in zip(signs, anns, enas):
    if sign == 1:
        c = '#2c90c9'
        l = 'Tax hike legislation'

        # Plot spans for legislative lag
        if first_inc:
            first_inc = False
            ax[0].axvspan(ann, ena, color=c, lw=0.6, alpha=alpha)
        else:
            ax[0].axvspan(ann, ena, color=c, lw=0.6, alpha=alpha)

    if sign == -1:
        c = '#c98000'
        l = 'Tax cut legislation'

        # Plot spans for legislative lag
        if first_dec:
            first_dec = False
            ax[0].axvspan(ann, ena, color=c, lw=0.6, alpha=alpha)
        else:
            ax[0].axvspan(ann, ena, color=c, lw=0.6, alpha=alpha)

# AX2 - decrease
ax[1].plot(prev.Top_1, color='#c98000', lw=1.5, label='Tax decrease topic prevalence')
ax[1].set_ylim(0, 0.15)
ax[1].set_ylabel('Topic prevalence')

ax[1].xaxis.tick_top()
ax[1].set_frame_on(False)

first_inc = True
first_dec = True
alpha = 0.2
for sign, ann, ena in zip(signs, anns, enas):
    if sign == 1:
        c = '#2c90c9'
        l = 'Tax hike legislation'

        # Plot spans for legislative lag
        if first_inc:
            first_inc = False
            ax[1].axvspan(ann, ena, color=c, lw=0.6, alpha=alpha)
        else:
            ax[1].axvspan(ann, ena, color=c, lw=0.6, alpha=alpha)

    if sign == -1:
        c = '#c98000'
        l = 'Tax cut legislation'

        # Plot spans for legislative lag
        if first_dec:
            first_dec = False
            ax[1].axvspan(ann, ena, color=c, lw=0.6, alpha=alpha)
        else:
            ax[1].axvspan(ann, ena, color=c, lw=0.6, alpha=alpha)

fig.tight_layout()

fig.legend(loc='upper left', bbox_to_anchor=(0.12, 0.97))
fig.savefig(os.path.join(graphsDir, 'tax_topic_prevalences.pdf'))
plt.close()

# OTHER TOPIC PREVALENCES
# Plot prevalences for non-topic
for k in range(2, 26):
    plt.figure(figsize=(5, 3))
    plt.plot(prev['Top_' + str(k)], lw=0.8, color='#4d4d4d')
    plt.tight_layout()

    plt.savefig(os.path.join(graphsDir, 'prev_topic_' + str(k) + '.pdf'), facecolor='white', edgecolor='none')
    plt.close()


# SELECTED SPEECHES - MIXING PROPORTION BOXPLOT
# Function for drawing a single scatter plot
def DrawScatter(ax, drDoc, drTheta, df):
    # Based on theta dir (inc/dec) - side of graph, dot color, label etc.
    if drTheta == -1:
        ax.set_xlim(1, -0.02)
        col = '#c98000'
        x = df[df.DIR == drDoc].THETA_DEC

        if drDoc == 1:
            ax.set_ylabel('Tax hikes\nspeeches', rotation=0)
        if drDoc == -1:
            ax.set_ylabel('Tax cuts\nspeeches', rotation=0)

    if drTheta == 1:
        ax.set_xlim(-0.02, 1)
        col = '#4287f5'
        x = df[df.DIR == drDoc].THETA_INC

    # Based on doc dir (inc/dec) - top/bottom of graph
    if drDoc == 1:
        if drTheta == -1:
            ax.set_xlabel(r'$\hat\hat\theta_{d,dec}$')
            ax.title.set_text('Proportion of tax decrease')
        if drTheta == 1:
            ax.set_xlabel(r'$\hat\hat\theta_{d,inc}$')
            ax.title.set_text('Proportion of tax increase')

    if drDoc == -1:
        ax.get_xaxis().set_visible(False)

    h = 0.2
    ax.set_ylim(1 - h, 1 + h)
    
    # Add random vertical scatter
    y = np.random.normal(1, 0.04 / (1 + x), len(x))

    ax.plot(x, y, '.', alpha=0.15, color=col)

    # Draw quantiles
    mean = x.mean()

    medianprops = dict(linestyle='-', linewidth=1.5, color='black')
    ax.boxplot(x, vert=False, whis=(10, 90), showfliers=False, medianprops=medianprops)

    ax.set_frame_on(False)
    ax.set_yticklabels([])
    ax.set_yticks([])


# Read data
theta2 = np.loadtxt(os.path.join(resultsDir, "theta2.csv"), delimiter=',')
docCodes = pd.read_csv(os.path.join(dataDir, "tax_docs.csv"))

# Record tax thetas of tax docs
docCodes['THETA_INC'] = theta2[docCodes.D, 0]
docCodes['THETA_DEC'] = theta2[docCodes.D, 1]

# Prepare
plt.rc('axes', titlesize=12)
plt.rc('axes', labelsize=12)
plt.rc('xtick', labelsize=12)
fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(12, 4))

# Draw each panel
DrawScatter(ax1, 1, -1, docCodes)
DrawScatter(ax2, 1, 1, docCodes)
DrawScatter(ax3, -1, -1, docCodes)
DrawScatter(ax4, -1, 1, docCodes)

plt.tight_layout(pad=0.0, w_pad=0.0, h_pad=0.0)
fig.savefig(os.path.join(graphsDir, 'theta_boxplots.pdf'))
plt.close()


# Information for legend
mu_1 = (0.33, 0.33, 0.33)
mu_2 = (0.5, 0.3, 0.2)

a_s = [2, 5, 10]*2
mu_s = (*([mu_1] * 3), *([mu_2] * 3))

# alphas for plots
alphas = ((0.33, 0.33, 0.33), (1.65, 1.65, 1.65), (3.3, 3.3, 3.3), (1.0, 0.4, 0.6), (2.5, 1.0, 1.5), (5.0, 2.0, 3.0))

fig = plt.figure(figsize=(10, 8))
fig.subplots_adjust(left=0.1, right=0.9, bottom=0.1, top=0.9, wspace=0.5, hspace=0.0)

for i, alpha in enumerate(alphas):
    ax = fig.add_subplot(2, 3, i + 1, projection="ternary")
    t, l, r, v = get_dirichlet_pdfs(n=61, alpha=alpha, prec=1e-3)
    cmap = "viridis"
    shading = "gouraud"
    cs = ax.tripcolor(t, l, r, v, cmap=cmap, shading=shading, rasterized=True)
    ax.set_axis_off()

    ax.set_title("a=" + str(a_s[i]) + "\n ${\\mathbf{\\mu}}$ = " + str(mu_s[i]))

plt.savefig(os.path.join(graphsDir, 'AppendixB1.pdf'))
plt.close()
