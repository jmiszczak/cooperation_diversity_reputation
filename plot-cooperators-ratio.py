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