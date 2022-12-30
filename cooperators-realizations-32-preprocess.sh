head -7 cooperators-realizations-32.csv | tail -1 > cooperators-realizations-32-vN.csv 
head -7 cooperators-realizations-32.csv | tail -1 > cooperators-realizations-32-M.csv 
head -7 cooperators-realizations-32.csv | tail -1 > cooperators-realizations-32-rvN.csv 
head -7 cooperators-realizations-32.csv | tail -1 > cooperators-realizations-32-rM.csv 
head -7 cooperators-realizations-32.csv | tail -1 > cooperators-realizations-32-rvNM.csv

cat cooperators-realizations-32.csv | grep "\"von Neumann\"" >> cooperators-realizations-32-vN.csv
cat cooperators-realizations-32.csv | grep "\"Moore\"" >> cooperators-realizations-32-M.csv
cat cooperators-realizations-32.csv | grep "\"random von Neumann\"" >> cooperators-realizations-32-rvN.csv
cat cooperators-realizations-32.csv | grep "\"random Moore\"" >> cooperators-realizations-32-rM.csv
cat cooperators-realizations-32.csv | grep "\"random von Neumann or" >> cooperators-realizations-32-rvNM.csv
