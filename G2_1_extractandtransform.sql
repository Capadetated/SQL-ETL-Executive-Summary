# Code name:  {G2_1_extractandtransform.sql} 
# Code written by Group 2: Ted Fitch, Jesse Ford, Michael Goddard, Somayah Eltoweissy
# UMGC DATA 620, February 17, 2021
# Professor Al-Ghandour
#
# This code creates a database called 'week6' 
# then the data wizard was used to import the 3 csv files that were then transformed and aggregated
# to be exported to a csv in Part 2
# Pre-requisite: Download and save the 4 files associated with this assignment before running this script

# Step 1a: Create a new database called 'week6' (dropping it first if it already exists)
drop database if exists week6;
Create database week6; 

#Step 1b: Activate the database
Use week6;

# Step 2: Open and run the script 'week6_business_units.sql'
# This creates 2 tables: product_bu and business_unit

# Step 3a-c: Create 3 tables called 2012_product_data_students,  2013_product_data_students,  2014_product_data_students
# Do this by right clicking on the newly created database and selecting Table Data Import Wizard
# Navigate to each csv and import, do this for all 3 csv files

# Step 4: Create a product table:  contains all distinct product names along with a primary key product id 
#4a. create the table called products that will list each distinct product_name
create table products as select distinct product_name from product_bu;
#4b. Add a primary key to the products table that will start at 1 and auto-increment 
ALTER TABLE products ADD product_id INT PRIMARY KEY AUTO_INCREMENT FIRST;

# Step 5: Create an orders table that includes the 3 imported tables stacked and aligned
# This table is created iteratively by first creating a table called orders_working,
# modifying it, creating a final table called orders and deleting the working table 

#5a. the comments below describe the transformations to the imported files to align all the data
# A variable called year was created for each row to identify the year the data was associated with
# For the 2012 data, the Order total variable was renamed to remove the space in the variable name
# For the 2013 data, Quantity was calculated by adding the quantity_1 and quantity_2 values
#      then order_total was calculated by multiplying the value for quantity by the 'Per-Unit Price' value
# For the 2014 data, the Order_total variable was calculated by
#      subtracting the 'quantity discount' from the 'order subtotal'
# Overall, the orders table has 6 variables: product, region, year, month, quantity, order_total (sorted sequentially by year and month)
# 		and other variables that were not available for each table were dropped, including country/state
create table orders_working as 
select product,region,2012 as year,month,quantity, `order total` as order_total
	 from 2012_product_data_students 
union all
select product,region,2013 as year,month,(quantity_1+quantity_2) as quantity, 
		(quantity_1+quantity_2)*`Per-Unit Price` as order_total
	 from 2013_product_data_students
union all
select product,region,2014 as year,month,quantity,(`order subtotal`-`quantity discount`) as order_total
	 from 2014_product_data_students
order by year, month;

#5b. Add a primary key to the orders table that will start at 1 and auto-increment 
ALTER TABLE orders_working ADD orders_id INT PRIMARY KEY AUTO_INCREMENT FIRST;

#Note- we confirmed the relationship between product names in the imported data and product_bu:
# all product names in the orders table and the product_bu table match
select distinct product, product_name from orders_working 
join product_bu on orders_working.product=product_bu.product_name;

#5c. The final orders table is created in this step. To normalize the data, 
# product (a text variable prone to error) is replaced with a product_id foreign key
create table orders as 
select b.product_id as products_product_id, a.region, a.year, a.month, a.quantity, a.order_total
from orders_working a
left join products b 
on a.product=b.product_name;

#5d. The intermediate orders_working table is deleted
drop table if exists orders_working;

# Step 6. Prod_bu is created using the product_bu table (that will be dropped). 
#6a. To normalize the data in the product_bu table, 
# product_name is replaced with the foreign key products_product_id
# and BU_name is replaced with the foreign key business_unit_BU_ID
create table prod_bu as 
select a.Prod_BU_ID, a.Prod_BU_Year,
		b.product_id as products_product_id,c.BU_Id as business_unit_BU_ID
from product_bu a
left join products b
on a.product_name=b.product_name
left join business_unit c on a.BU_name=c.BU_name;

#6b. The intermediate product_bu table is deleted
drop table if exists product_bu;

# Step 7. Merge the tables to obtain bu_name, bu_designation from the business_unit table 
# and product_name from the products table linked to the orders data
# Orders data with BU_designation='Decline' will be excluded
create table data_all as 
select business_unit.bu_name,business_unit.bu_designation,products.product_name,region, year,month,quantity,order_total
from orders
left join products on orders.products_product_id=products.product_id
join prod_bu on prod_bu.products_product_id=products.product_id and prod_bu.prod_bu_year=orders.year 
join business_unit on prod_bu.business_unit_BU_ID=business_unit.BU_ID
where BU_designation <>'Decline';

-- Business decision: We will extract records with a quantity of 0 or order total of 0. 
-- currency formatting is price in cents. 

# Step 8. Aggregate the data
# by rolling it up within bu_designation, bu_name, product_name, region, year, month
# Records will also be sorted by these fields in ascending order, with the left-most ones having precendence 
create table data_aggregate as 
select distinct bu_designation,bu_name,product_name,region, year,month,
			sum(quantity) as `Sum of Quantity`,sum(order_total) as `Sum of Order Total`
from data_all
group by bu_designation, bu_name, product_name, region, year, month
order by bu_designation, bu_name, product_name, region, year, month,`Sum of Quantity`,`Sum of Order Total`;

