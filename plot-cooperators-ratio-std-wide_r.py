#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# %%
import pandas as pd
import numpy as np
import matplotlib as mpl
import matplotlib.colors as colors

mpl.rc('text', usetex=True)
mpl.rc('font', family='serif')
mpl.rc('font', size=11)

# %%
# file with data from the experiment
# Note: header=6 is for NetLogo data

exp_desc = 'cooperators-final-long-128-v1'

data = pd.read_csv(exp_desc + '.csv', header=6)

sxs = { 'vN' : "von Neumann",  'rvN' : 'random von Neumann', 'M': 'Moore', 'rM': 'random Moore'} #, 'rvNM': 'random von Neumann or random  Moore' }
#sxs = { 'vN' : "von Neumann"}

markers = ['o', 'x', 's', '^', '2']
colors = ['k--', 'r-.', 'b:', 'g-', 'm']

# %% calculate plotted data

# [
#  '[run number]', 'noise-factor', 'synergy-factor', 'neighborhood-type',
#   'world-size', '[step]', 'cooperators-fraction', 'mean-cooperators1k'
#   ]

v = [ 'synergy-factor', 'neighborhood-type', 'world-size', 'mean-cooperators-fraction', 'std-cooperators-fraction']

# NOTE: start with some subset of data
var0s = data['synergy-factor'].unique()
var1s = data['neighborhood-type'].unique()[:4]
var2s = data['world-size'].unique()[:1]

exp_desc = exp_desc + '_' + str( var2s[0] )

df = pd.DataFrame(columns=v)

for v0 in var0s:
    for v1 in var1s:
        for v2 in var2s: 
          df.loc[len(df.index)] = [
                v0,
                v1,
                v2,
                data[(data[v[0]] == v0) & (data[v[1]] == v1) & (data[v[2]] == v2)]['cooperators-fraction'].mean(),
                data[(data[v[0]] == v0) & (data[v[1]] == v1) & (data[v[2]] == v2)]['cooperators-fraction'].std()
            ]
          
          
# %% plot data
fig = mpl.figure.Figure(figsize=(5, 3.75))
axs = fig.add_subplot()
for i, nt in enumerate( list(sxs.values())):

    plot_data = df[df['neighborhood-type'] == nt][['synergy-factor', 'mean-cooperators-fraction']].to_numpy()
    axs.plot(plot_data.T[0], plot_data.T[1], color=colors[i][0], marker=markers[i], fillstyle='none', markersize=4, label=nt,  linestyle='--', lw=0.75)


axs.set_xlabel('synergy factor $r$')
axs.set_ylabel('mean of cooperators fraction')

axs.grid(True, linestyle=':', linewidth=0.5, c='k')
axs.legend(ncols=1,loc='best',fontsize='8')

# %%
fig.tight_layout()
display(fig)

fig.savefig("plot_" + exp_desc + "-mean.pdf", format="pdf", bbox_inches='tight')
print("[INFO] Saving " + "plot_" + exp_desc + "-mean.pdf")


# %% plot data
fig = mpl.figure.Figure(figsize=(5, 3.75))
axs = fig.add_subplot()
for i, nt in enumerate( list(sxs.values())):

    plot_data = df[df['neighborhood-type'] == nt][['synergy-factor', 'std-cooperators-fraction']].to_numpy()
    axs.plot(plot_data.T[0], plot_data.T[1], color=colors[i][0], marker=markers[i], fillstyle='none', markersize=4, label=nt,  linestyle='--', lw=0.75)


axs.set_xlabel('synergy factor $r$')
axs.set_ylabel('std of cooperators fraction')

axs.grid(True, linestyle=':', linewidth=0.5, c='k')
axs.legend(ncols=1,loc='best',fontsize='8')

# %%
fig.tight_layout()
display(fig)

fig.savefig("plot_" + exp_desc + "-std.pdf", format="pdf", bbox_inches='tight')
print("[INFO] Saving " + "plot_" + exp_desc + "-std.pdf")


# %% plot data
fig = mpl.figure.Figure(figsize=(5, 3.75))
axs = fig.add_subplot()
for i, nt in enumerate( list(sxs.values())):

    plot_data_mean = df[df['neighborhood-type'] == nt][['synergy-factor', 'mean-cooperators-fraction']].to_numpy()
    plot_data_std = df[df['neighborhood-type'] == nt][['synergy-factor', 'std-cooperators-fraction']].to_numpy()

    axs.fill_between(plot_data_mean.T[0], 
                       plot_data_mean.T[1]+plot_data_std.T[1], 
                       plot_data_mean.T[1]-plot_data_std.T[1], color=colors[i][0], alpha=.25, linewidth=.35)
    axs.plot(plot_data_mean.T[0], plot_data_mean.T[1], color=colors[i][0], marker=markers[i], fillstyle='none', markersize=4, label=nt,  linestyle='--', lw=0.75)


axs.set_xlabel('synergy factor $r$')
axs.set_ylabel('mean of cooperators fraction')

axs.grid(True, linestyle=':', linewidth=0.5, c='k')
axs.legend(ncols=1,loc='best',fontsize='8')

# %%
fig.tight_layout()
display(fig)

fig.savefig("plot_" + exp_desc + "-mean-std.pdf", format="pdf", bbox_inches='tight')
print("[INFO] Saving " + "plot_" + exp_desc + "-mean-std.pdf")