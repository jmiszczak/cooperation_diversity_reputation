#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# %%
import pandas as pd
import numpy as np
import matplotlib as mpl
import matplotlib.colors as colors

mpl.rc('text', usetex=True)
mpl.rc('font', family='serif')
mpl.rc('font', size=10)

# %%
# file with data from the experiment
# Note: header=6 is for NetLogo data

exp_desc = 'cooperators-diversity'

data = pd.read_csv(exp_desc + '.csv', header=6)

#sxs = { 'vN' : "von Neumann", 'M': 'Moore', 'rvN' : 'random von Neumann', 'rM': 'random Moore'} #, 'rvNM': 'random von Neumann or random  Moore' }
sxs = { 'vN' : "von Neumann"}

markers = ['o', 'x', 's', '^', '2']
colors = ['k--', 'r-.', 'b:', 'g-', 'm']

# %% calculate plotted data

# [
#  '[run number]', 'noise-factor', 'synergy-factor', 'neighborhood-type',
#   'world-size', '[step]', 'cooperators-fraction', 'mean-cooperators1k'
#   ]

v = [ 'synergy-factor', 'neighborhood-type', 'world-size', 'mean-cooperators-fraction' ]

# NOTE: start with some subset of data
var0s = data['synergy-factor'].unique()
var1s = data['neighborhood-type'].unique()[:1]
var2s = data['world-size'].unique()[:1]

df = pd.DataFrame(columns=v)

for v0 in var0s:
    for v1 in var1s:
        for v2 in var2s: 
          df.loc[len(df.index)] = [
                v0,
                v1,
                v2,
                data[(data[v[0]] == v0) & (data[v[1]] == v1) & (data[v[2]] == v2)]['cooperators-fraction'].mean()
            ]
          
          
# %% plot data

