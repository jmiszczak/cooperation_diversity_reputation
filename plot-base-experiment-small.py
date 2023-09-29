#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# %% initial imports
import pandas as pd
#import numpy as np
import matplotlib as mpl
from os.path import exists
#import matplotlib.colors as colors

mpl.rc('text', usetex=True)
mpl.rc('font', family='serif')
mpl.rc('font', size=10)

# %% data loading
# file with data from the experiment
# Note: header=6 is for NetLogo data

exp_desc = 'base-experiment-small'
#sxs = { 'vN' : "von Neumann", 'rvN' : 'random von Neumann', 'M': 'Moore', 'rM': 'random Moore'} #, 'rvNM': 'random von Neumann or random  Moore' }
#sxs = { 'vN' : "von Neumann"}

markers = ['o', 'x', 's', '^', '2']
colors = ['k--', 'r-.', 'b:', 'g-', 'm']

#%% read data
#data = dict() 
v = ["random-patches-number","raoming-agents","synergy-factor", "mean-cooperators1k"]

data = pd.read_csv(exp_desc + '.csv', header=6)
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



fig = mpl.figure.Figure(figsize=(4, 3))
axs = fig.add_subplot()

levels = [0, 0.2, 0.4, 1]

plot_data = df[[v[1], v[2], v[3]]].to_numpy()

axs.contourf(
  plot_data,
  levels=3,
  colors='k',
  linestyles='dotted'
  )


fig.tight_layout()
display(fig)

# %%
fig.savefig("plot_" + exp_desc + ".pdf", format="pdf", bbox_inches='tight')