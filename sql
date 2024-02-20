select*from user_data
--sử dụng boxplot-IQR để tìm ra outliers
--B1: tính Q1,Q3,IQR
--B2: xác định min = Q1-1,5*IQR, max = Q3+15*IQR
with cte as(
select Q1-1.5*IQR as min_value,
	Q3+15*IQR as max_value
from(
select
percentile_cont(0.25) within group (order by users) as Q1,
percentile_cont(0.75) within group (order by users) as Q3,
percentile_cont(0.75) within group (order by users) - percentile_cont(0.25) within group (order by users) as IQR
from user_data)) 
--B3: Xác định outliers <min hay >max
select*from user_data
where users < (select min_value from cte )
or users > ( select max_value from cte);
--cách 2: sử dụng Z-Score = (users-avg)/stddev
with cte as (
	select data_date, users,
(select avg(users) 
from user_data) as avg,
(select stddev(users) 
 from user_data) as stddev
from user_data)

,twt_ouliers as(
select data_date, users, (users-avg)/stddev as z_score
from cte
where abs((users-avg)/stddev)>3)
update user_data
set users = (select avg(users)
from user_data)
where users in (select users from twt_outliers)
