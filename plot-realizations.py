#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# %% initial imports
import pandas as pd
#import numpy as np
import matplotlib as mpl
#import matplotlib.colors as colors

mpl.rc('text', usetex=True)
mpl.rc('font', family='serif')
mpl.rc('font', size=10)

# %% data loading
# file with data from the experiment
# Note: header=6 is for NetLogo data

exp_desc = 'cooperators-realizations-64-long'
sxs = { 'vN' : "von Neumann", 'M': 'Moore', 'rvN' : 'random von Neumann', 'rM': 'random Moore'} #, 'rvNM': 'random von Neumann or random  Moore' }
#sxs = { 'vN' : "von Neumann"}

markers = ['o', 'x', 's', '^', '2']
colors = ['k--', 'r-.', 'b:', 'g-', 'm']

#%% read data
data = dict() 
v = ['synergy-factor', '[step]', 'cooperators-fraction-mean', 'cooperators-fraction-std']
df = dict()

for sx in sxs :
    data[sx] = pd.read_csv(exp_desc + '-' + sx + '.csv', header=0)
    df[sx] = pd.DataFrame(columns=v)

# select variables for the analysis 
# this depends on the experiment


#%% values of the synergy factor
# sfs = data["synergy-factor"].unique()[::2] # read from file
sfs = [3.5, 3.6, 3.7, 3.8, 3.9, 4.0, 4.2, 4.5, 4.9, 5.2, 5.4, 5.5 ] # preselected values
steps = data['vN']["[step]"].unique() # read from file

# skip some steps further on
skip = 1024


#%% data calculation
for sx in sxs :
    for sf in sfs:
        for st in steps[::skip]:
              df[sx].loc[len(df[sx].index)] = [
                  sf,
                  st,
                  data[sx][(data[sx]["synergy-factor"] == sf) & (data[sx]["[step]"] == st)]["cooperators-fraction"].mean(),
                  data[sx][(data[sx]["synergy-factor"] == sf) & (data[sx]["[step]"] == st)]["cooperators-fraction"].std()
              ]


#%% plotting
plot_data = dict()

fig = mpl.figure.Figure(figsize=(6.5, 6.5))
for i, sf in enumerate(sfs):
  axs = fig.add_subplot(3,4,i+1)
  # axs.set_xscale("log", base=10)
  # axs.set_yscale("log", base=10)
  axs.set_ylim([0.0, 1.05])
  # axs.set_xlim([0.0, 100])
  axs.set_xlim([1, max(steps)])
  axs.set_xticks([0,10000,20000,30000])
  axs.set_yticks([0,0.25,0.5,0.75,1])
  axs.grid(True, linestyle=':', linewidth=0.5, c='k')
  
  if i % 4 != 0:
      axs.set_yticklabels([])
      
  if i < 8:
      axs.set_xticklabels([])
  else:
      axs.set_xticklabels(["0","1", "2", "3"])
      axs.set_xlabel(r"step $[\times 10^3]$")
      
  for i, sx in enumerate( sxs ) :
      plot_data[sx] = df[sx][df[sx]['synergy-factor'] == sf][["[step]","cooperators-fraction-mean"]].to_numpy()
      axs.set_title(r"$r={}$".format(sf))

      axs.plot(plot_data[sx].T[0], plot_data[sx].T[1],  colors[i], label = sxs[sx] )
  

  
  #axs.set_yticks([0.1, .25, .50, .75, 1.00])
  #axs.set_xticks(steps[::10*skip])
  
handles, labels = axs.get_legend_handles_labels()
lgd = fig.legend(handles, labels, loc='upper center', bbox_to_anchor=(0.525,1.03), ncol=5)

fig.tight_layout()
display(fig)

# %% saving
fName = "plot_" + exp_desc + ".pdf"
print("INFO] Saving " + fName)
fig.savefig(fName, format="pdf", bbox_inches='tight')
