[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10073045.svg)](https://doi.org/10.5281/zenodo.10073045)

# cooperation_diversity_reputation

NetLogo implementation of the model of cooperation with interaction diversity and reputation-updating timescale.

Currently, there are two version of the model provided: patch-based and turtle-based.

## Summary

The code provided in this repository was developed to reproduce results concerning the emergence of cooperation in model with interaction diversity and with reputation updating. For the original papers see references below.

Additionally:
- Scripts for running headless NetLogo experiments, preprocessing results, and producing plots are provided.
- Experiments definitions are provided in ``experiements.xml`` file.

## Requirements

- The model was developed using `NetLog` and testes in version 6.3.0. 
- Control scripts are written in ``bash``. 
- Plotting scripts are written in Python and require ``matplotlib`` and ``pandas`` packages.

## References

This code is based on the following publications:

- Lihui Shang, Sihao Sun, Jun Ai, Zhan Su,*Cooperation enhanced by the interaction diversity for the spatial public goods game on regular lattices*, Physica A: Statistical Mechanics and its Applications, Volume 593, 2022, 126999, https://doi.org/10.1016/j.physa.2022.126999

- Weiwei Han, Zhipeng Zhang, Junqing Sun, Chengyi Xia, *Emergence of cooperation with reputation-updating timescale in spatial public goods game*, Physics Letters A, Volume 393, 2021, 127173, https://doi.org/10.1016/j.physleta.2021.127173
