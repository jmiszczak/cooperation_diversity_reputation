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

exp_desc = 'cooperators-realizations-32-vN'
data = pd.read_csv(exp_desc + '.csv', header=0)

# select variables for the analysis 
# this depends on the experiment

# values of the synergy factor
sfs = data["synergy-factor"].unique()
#sfs = [3.0, 4.0, 5.0]
steps = data["[step]"].unique()

# skip some steps further on
skip = 50

v = ['synergy-factor', '[step]', 'cooperators-fraction-mean', 'cooperators-fraction-std']
df = pd.DataFrame(columns=v)


#%% data calculation

for sf in sfs:
    for st in steps[::skip]:
          df.loc[len(df.index)] = [
              sf,
              st,
              data[(data["synergy-factor"] == sf) & (data["[step]"] == st)]["cooperators-fraction"].mean(),
              data[(data["synergy-factor"] == sf) & (data["[step]"] == st)]["cooperators-fraction"].std()
          ]


#%% plotting

fig = mpl.figure.Figure(figsize=(2*6, 2*5.5))
for i, sf in enumerate(sfs):
  axs = fig.add_subplot(4,4,i+1)
  plot_data = df[df['synergy-factor'] == sf][["[step]","cooperators-fraction-std"]].to_numpy()
  
  axs.set_xscale("log", base=10)
  axs.set_yscale("log", base=10)
  axs.plot(plot_data.T[0], plot_data.T[1])
  
  axs.set_ylim([0.001, 1])
  #axs.set_xlim([0, max(steps)])
  axs.grid(True, linestyle=':', linewidth=0.5, c='k')
  
  #axs.set_yticks([0.1, .25, .50, .75, 1.00])
  #axs.set_xticks(steps[::10*skip])
  


fig.tight_layout()
display(fig)

# %% saving
fName = "plot_" + exp_desc + ".pdf"
print("INFO] Saving " + fName)
fig.savefig(fName, format="pdf", bbox_inches='tight')
