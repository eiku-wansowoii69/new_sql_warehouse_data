/*
脚本说明：在DWD进行数据清洗时需测试数据清洗的必要性和类型，此脚本是进行销售事实表清洗时的测试文本。
*/
select sls_ord_num
from ods.crm_sales_details
where sls_ord_num is null or sls_ord_num=''

select sls_prd_key
from ods.crm_sales_details
where sls_prd_key is null or sls_prd_key=''
or sls_prd_key!=trim(sls_prd_key)

select sls_prd_key
from ods.crm_sales_details
where sls_prd_key not in (select product_number from dwd.dim_products)

select sls_cust_id
from ods.crm_sales_details
where sls_cust_id is null or sls_cust_id=''

select sls_order_dt,
sls_ship_dt,
sls_due_dt
from ods.crm_sales_details
where sls_order_dt>sls_ship_dt or sls_order_dt>sls_due_dt

select
case when sls_order_dt=0 or len(sls_order_dt)!=8 then null --如果源表里存的是int类型就这样转
     else cast(cast(sls_order_dt as varchar) as date)
end as sls_order_dt
from ods.crm_sales_details

select
case when sls_order_dt= '0' or len(trim(sls_order_dt))!= 8 then null --如果源表里存的是varchar类型就这样转
     else try_convert(date,trim(sls_order_dt),112) --112的类型就是这种8位数字的日期
end as sls_order_dt
from ods.crm_sales_details

select sls_sales,
sls_quantity,
sls_price
from ods.crm_sales_details
where sls_sales!=sls_quantity*sls_price
