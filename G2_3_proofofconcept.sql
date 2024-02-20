# Code name:  {G2_3_proofofconcept.sql} 
# Code written by Group 2: Ted Fitch, Jesse Ford, Michael Goddard, Somayah Eltoweissy
# UMGC DATA 620, February 17, 2021
# Professor Al-Ghandour
#
#This code contains queries to demonstrate the proof of concept regarding the business questions presented

#Activate database
Use week6;

#A- Demonstrate that the Growth segment should show at least 10% year over year growth
# in either quantity sold or order total

#Aggregated orders data by bu_designation, year (rolled up bu_name,product_name,region,month)
create table year_aggregate as 
select distinct bu_designation, year, 
			sum(`Sum of Quantity`) as quantity ,sum(`Sum of Order Total`) as order_total
from data_aggregate
group by bu_designation, year 
order by bu_designation, year;

#Calculated Year over Year growth for bu_designation='Growth' 
# by joining the table on itself to obtain the prior year's data
#You can uncomment the rows below to see the source data and do the calculations yourself
select distinct now.bu_designation, prior.year as year_lag, now.year, 
	#	prior.quantity as prior_q, now.quantity as now_q,
((now.quantity-prior.quantity)/prior.quantity)*100 as quantity_YoYgrowth,
	# prior.order_total as prior_o, now.order_total as now_o,
((now.order_total-prior.order_total)/prior.order_total)*100 as order_total_YoYgrowth
#, ordertotal_YoYgrowth
from year_aggregate now
left join year_aggregate prior
on now.bu_designation=prior.bu_designation and now.year=prior.year+1
where now.bu_designation='Growth' and prior.year is not null;

#B- Mature segment should remain pretty much the same in terms of quantity and order totals
#Look at the Mature segment, previously aggregated by bu_designation and year
select * from year_aggregate where bu_designation='Mature';

#this syntax produces the same results (without querying the new year_aggregate table)
select distinct bu_designation, year, 
			sum(`Sum of Quantity`) as quantity ,sum(`Sum of Order Total`) as order_total
from data_aggregate
group by bu_designation, year
having  bu_designation='Mature';