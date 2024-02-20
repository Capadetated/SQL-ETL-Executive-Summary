# Code name:  {G2_2_load.sql} 
# Code written by Group 2: Ted Fitch, Jesse Ford, Michael Goddard, Somayah Eltoweissy
# UMGC DATA 620, February 17, 2021
# Professor Al-Ghandour
#
# This code will use the week6 database created in part 1 and query the data to export it to a CSV

# Activate the database that was created using G2_1_extractandtransform.sql
USE week6;

# Now we will place the file we imported into format that will be exported into CSV.
# This will place commas in between the data so that it is separated by a comma. 
# This SQL code selects bu_designation,bu_name,product_name,region, year,month,`Sum of Quantity`,`Sum of Order Total`
# sorted by ascending values of each field, with the left-most ones having precendence 

SELECT bu_designation, ',', bu_name, ',','"',product_name ,'"', ',', region, ',', 
		year, ',', month, ',', `Sum of Quantity`,',',`Sum of Order Total`
from data_aggregate
order by bu_designation, bu_name, product_name, region, year, month,`Sum of Quantity`,`Sum of Order Total`;


# Finally, using the following commands, we will export the data we have selected
# Cd C:\Program Files\MySQL\MySQL Workbench 8.0 CE
# mysql.exe -h data620-9041-seltoweissy.mysql.database.azure.com -P 3306 -u adminuser@data620-9041-seltoweissy -p --batch < C:\somayah\Week6\G2_2_load.sql > C:\somayah\Week6\G2_output_final.csv



