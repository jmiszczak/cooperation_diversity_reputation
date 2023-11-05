#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# %% initial imports
import pandas as pd
import numpy as np

import matplotlib as mpl
import matplotlib.figure as figure
import matplotlib.colors as colors
from matplotlib.ticker import AutoMinorLocator

from IPython.display import display

mpl.rc('text', usetex=True)
mpl.rc('font', family='serif')
mpl.rc('font', size=9)

# %% data loading
# file with data from the experiment
# Note: header=6 is for NetLogo data

# experiment name
exp_desc = 'random-local-roaming'
# variables usd in the plots
v = ["neighborhood-type", "roaming-agents", "synergy-factor", "mean-cooperators1k"]

data = pd.read_csv(exp_desc + '.csv', header=6)

# data fram used for plots
df = pd.DataFrame(columns=v)
var0s = data[v[0]].unique()
var1s = data[v[1]].unique()
var2s = data[v[2]].unique()


for v0 in var0s:
    for v1 in var1s:
        for v2 in var2s: 
          df.loc[len(df.index)] = [
                v0,
                v1,
                v2,
                data[(data[v[0]] == v0) & (data[v[1]] == v1) & (data[v[2]] == v2)]['mean-cooperators1k'].mean()
            ]

# df = df.replace('nan', 0)

#%% plot 
# leves for contour plot
# levels = list(map( lambda x : x/20, list(range(0,23))))
levels = [0.0, 0.1, 0.5, 0.95, 0.98, 1.0]


# color map for contour plot
# cmap = colors.LinearSegmentedColormap.from_list('', ['darkred', 'red', 'orange', 'yellow', 'darkgreen'])
# cmap = colors.LinearSegmentedColormap.from_list('', ['red', 'orange', 'white'])
# cmap = colors.ListedColormap( ['red', 'yellow', 'white'])
# cmap = colors.LinearSegmentedColormap.from_list('', ['red', 'white'])
# cmap = 'viridis'

plotColors = ['tomato','orange' , 
              'yellow', 'palegreen', 'lightblue']
cmap, norm = colors.from_levels_and_colors(levels, plotColors)


# cmap ='Reds_r'
# contained for plotted data
plot_data = dict()

# one figure for all cases of v0
fig = figure.Figure(figsize=(5, 6))
for i, v0 in enumerate(var0s):
  # Note: 3*2 is the number of cases for var0s 
  axs = fig.add_subplot(321+i);
 
  plot_data[v0] = df[df[v[0]] == v0][[v[1], v[2], v[3]]].to_numpy()
  
  axs.contour(
    plot_data[v0].T[0].reshape((len(var1s),len(var2s))),
    plot_data[v0].T[1].reshape((len(var1s),len(var2s))),
    plot_data[v0].T[2].reshape((len(var1s),len(var2s))),
    levels=levels[1::],
    linestyles='dashed',
    linewidths=.5,
    colors = ['black']
    )

  
  im = axs.contourf(
    plot_data[v0].T[0].reshape((len(var1s),len(var2s))),
    plot_data[v0].T[1].reshape((len(var1s),len(var2s))),
    plot_data[v0].T[2].reshape((len(var1s),len(var2s))),
    levels=levels,
    cmap = cmap,
    norm = norm,
    interpolation=None
    )

  axs.set_yticks([2.5,3,3.5,4,4.5,5,5.5,6])
  axs.set_xticks([0.0,.2,.4,.6,.8,1.0])
  
  if i in [0,2,4]:
    axs.set_ylabel(r'synergy factor $r$')
  
  # if i in [4,5]:
  axs.set_xlabel(r'roaming agents participation $\delta$')
      
  if i not in [0,2,4]:
      axs.set_yticklabels([])
      
  # axs.yaxis.grid(False, which='minor')
  axs.yaxis.set_minor_locator(AutoMinorLocator(n=5))
  axs.xaxis.set_minor_locator(AutoMinorLocator(n=4))
  
  # if i not in [4,5]:
      # axs.set_xticklabels([])
      
  axs.set_title(str(v0))
  # axs.text(0.5/2,6.6,r'$K$='+str(v0), ha='center')

  # axs.set_xlabel(vl[1])
#  if i == 0:
      # axs.set_ylabel(vl[2])

  # im = axs.matshow (plot_data[3].T[2].reshape(len(var1s), len(var2s)), cmap='Reds', norm=colors.Normalize(vmin=0, vmax=1))

  axs.grid(True, which='major',linestyle='-.', linewidth=0.25, c='k', alpha=0.75)
  # axs.grid(True, which='minor',linestyle=':', linewidth=0.25, c='k', alpha=0.5)


cbar_ax = fig.add_axes([0.125, 1.02, 0.8, 0.015])
cbar = fig.colorbar(im, cax=cbar_ax, orientation="horizontal")
cbar.set_ticklabels([str(l) for l in levels])

fig.tight_layout()
display(fig)

# %% saving
fName = "plots/plot_" + exp_desc + ".pdf"
print("[INFO] Saving " + fName)
fig.savefig(fName, format="pdf", bbox_inches='tight')

#%% min delta
data_md = dict()
data_max1 = dict()
data_max2 = dict()
thr1 = 0.95
thr2 = 0.99

for k in var0s:
    data_md[k] = df[df[v[0]] == k][[v[1], v[2], v[3]]]
                                
for k in var0s:
    data_max1[k] = data_md[k][data_md[k]['mean-cooperators1k'] >= thr1 ]
    data_max2[k] = data_md[k][data_md[k]['mean-cooperators1k'] >= thr2 ]
    
#min_delta1 = [min(data_max1[x]['roaming-agents']) for x in var0s]
#min_delta2 = [min(data_max2[x]['roaming-agents']) for x in var0s]

min_delta1 = [min(data_max1[x][data_max1[x]['synergy-factor'] == min(data_max1[x]['synergy-factor'])]['roaming-agents'])  for x in var0s]
min_delta2 = [min(data_max2[x][data_max1[x]['synergy-factor'] == min(data_max2[x]['synergy-factor'])]['roaming-agents'])  for x in var0s]

print(min_delta1)

print(min_delta2)

