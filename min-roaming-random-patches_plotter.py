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
mpl.rc('font', size=8)

# %% data loading
# file with data from the experiment
# Note: header=6 is for NetLogo data

# experiment name
# exp_desc = 'min-roaming-random-patches-small-150'
# exp_desc = 'min-roaming-random-patches-l64-even'
exp_desc = 'min-roaming-random-patches-medium'

# variables usd in the plots
v = ["random-patches-number", "roaming-agents", "synergy-factor", "mean-cooperators1k"]

data = pd.read_csv(exp_desc + '.csv', header=6)

# data from used for plots
df = pd.DataFrame(columns=v)
var0s = data[v[0]].unique()
var1s = data[v[1]].unique()
var2s = data[v[2]].unique()
# var0s = np.array([4,6,8,10,12])

# %% preprocess
for v0 in var0s:
    for v1 in var1s:
        for v2 in var2s: 
          df.loc[len(df.index)] = [
                v0,
                v1,
                v2,
                data[(data[v[0]] == v0) & (data[v[1]] == v1) & (data[v[2]] == v2)]['mean-cooperators1k'].mean()
            ]


# #%% plot 
# var0s = np.array([4,6,8,10])

# # levels for contour plot
# # levels = list(map( lambda x : x/10, list(range(0,11))))

# # color map for contour plot
# # cmap = colors.LinearSegmentedColormap.from_list('', ['darkred', 'red', 'orange', 'yellow', 'white'])

# # levels = list(map( lambda x : x/20, list(range(0,23))))
# levels = [0, 0.1, 0.5, 0.75, 0.9, 0.95, 0.98, 1]


# plotColors = ['orange', 'red', 
#               'tomato', 'yellow', 
#               'palegreen', 'lightblue', 
#               'white']
# cmap, norm = colors.from_levels_and_colors(levels, plotColors)


# # contained for plotted data
# plot_data = dict()

# # one figure for all cases of v0
# fig = figure.Figure(figsize=(6,5))
# for i, v0 in enumerate(var0s):
#   # Note: 3*2 is the number of cases for var0s 
#   axs = fig.add_subplot(221+i)
 
#   plot_data[v0] = df[df[v[0]] == v0][[v[1], v[2], v[3]]].to_numpy()
  
#   axs.contour(
#     plot_data[v0].T[0].reshape((len(var1s),len(var2s))),
#     plot_data[v0].T[1].reshape((len(var1s),len(var2s))),
#     plot_data[v0].T[2].reshape((len(var1s),len(var2s))),
#     levels=levels[1::],
#     linestyles='dashed',
#     linewidths=.75,
#     colors = ['black']
#     )

#   im = axs.contourf(
#     plot_data[v0].T[0].reshape((len(var1s),len(var2s))),
#     plot_data[v0].T[1].reshape((len(var1s),len(var2s))),
#     plot_data[v0].T[2].reshape((len(var1s),len(var2s))),
#     levels=levels,
#     cmap = cmap,
#     norm = norm
#     )

#   axs.set_yticks([3,4,5,6,7,8])
#   axs.set_xticks([0,.1,.2,.3,.4])
  
#   if i in [0,2]:
#     axs.set_ylabel(r'synergy factor $r$')
  
#   if i not in [0,2]:
#     axs.set_yticklabels([])
  
#   if i in [2,3]:
#     axs.set_xlabel(r'roaming agents participation $\delta$')
  
#   if i not in [2,3,4,5,6]:  
#     axs.set_xticklabels([])
      
#   axs.yaxis.set_minor_locator(AutoMinorLocator(n=5))
#   axs.xaxis.set_minor_locator(AutoMinorLocator(n=4))
#   axs.set_title(r'$K$='+str(v0))

#   axs.grid(True, which='major',linestyle='-.', linewidth=0.25, c='k', alpha=0.75)

# cbar_ax = fig.add_axes([0.12, 1.025, 0.8, 0.02])
# cbar = fig.colorbar(im, cax=cbar_ax, orientation="horizontal")
# cbar.set_ticklabels([str(l) for l in levels])

# fig.tight_layout()
# display(fig)

# # %% saving
# fName = "plots/plot_" + exp_desc + ".pdf"
# print("[INFO] Saving " + fName)
# fig.savefig(fName, format="pdf", bbox_inches='tight')

#%% min delta
var0s = np.array([4,6,8,10])
data_md = dict()
data_max1 = dict()
data_max2 = dict()
thr1 = 0.90
thr2 = 0.98
pm = lambda x : '-' if x < a else '+'


for k in var0s:
    data_md[k] = df[df[v[0]] == k][[v[1], v[2], v[3]]]
                                
for k in var0s:
    data_max1[k] = data_md[k][data_md[k]['mean-cooperators1k'] >= thr1 ]
    data_max2[k] = data_md[k][data_md[k]['mean-cooperators1k'] >= thr2 ]
    
#min_delta1 = [min(data_max1[x]['roaming-agents']) for x in var0s]
#min_delta2 = [min(data_max2[x]['roaming-agents']) for x in var0s]

min_delta1 = [min(data_max1[x][data_max1[x]['synergy-factor'] == min(data_max1[x]['synergy-factor'])]['roaming-agents'])  for x in var0s]
min_delta2 = [min(data_max2[x][data_max1[x]['synergy-factor'] == min(data_max2[x]['synergy-factor'])]['roaming-agents'])  for x in var0s]


fig = figure.Figure(figsize=(2.2,1.8),dpi=200)
axs = fig.add_subplot()
axs.set_ylim(-0.01,0.5)

# thr1
axs.plot(var0s, min_delta1, 'x', color='steelblue', label=r'$\geq$ {}\%'.format(100*thr1))
a, b = np.polyfit(var0s, min_delta1, 1)
print(a,b)
axs.plot(var0s, a*var0s+b, '--', color='steelblue', lw=0.75)
# axs.annotate(r'$f_1(K) = {:4.3f}K + {:4.3f}$ '.format(a,b), xy=(6,0.1), xycoords='data')

loc = np.array((5,a*5))
axs.text(*loc, r'$f_{}(K) = {:4.3f}K {} {:4.3f}$ '.format('{'+str(thr1)+'}',a,pm(b),abs(b)),
          rotation=np.rad2deg(np.arctan(a)), rotation_mode='anchor',
              transform_rotates_text=True)

# thr2
axs.plot(var0s, min_delta2, 'ro', fillstyle='none', label=r'$\geq$ {}\%'.format(100*thr2))
a, b = np.polyfit(var0s, min_delta2, 1)
print(a,b)
axs.plot(var0s, a*var0s+b,'r--', lw=0.75)
# axs.annotate(r'$f_2(K) = {:4.3f}K + {:4.3f}$ '.format(a,b), xy=(6,0.05), xycoords='data')


loc = np.array((4.3,a*5+b+0.07))
axs.text(*loc, r'$f_{}(K) = {:4.3f}K {} {:4.3f}$ '.format('{'+str(thr2)+'}',a,pm(b),abs(b)),
         rotation=np.rad2deg(np.arctan(a)), rotation_mode='anchor',
              transform_rotates_text=True)

axs.grid(True, linestyle=':', linewidth=0.5, c='k')
axs.set_xlabel(r'$K$')
# axs.set_ylabel(r'optimal $\delta$')

# axs.legend(ncols=2, loc='upper left', shadow=None)
fig.tight_layout()
display(fig)

fName = "plots/plot_" + exp_desc + "-min_delta.pdf"
print("[INFO] Saving " + fName)
fig.savefig(fName, format="pdf", bbox_inches='tight')