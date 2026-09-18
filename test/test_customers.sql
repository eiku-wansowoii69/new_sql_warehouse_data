/*
脚本说明：在DWD进行数据清洗时需测试数据清洗的必要性和类型，此脚本是进行客户维度表清洗时的测试文本。
*/
--ods.crm_cust_info
select cst_id from ods.crm_cust_info
where cst_id is null or cst_id<=0

select cst_key from ods.crm_cust_info
where cst_key!=trim(cst_key)

select cst_firstname from ods.crm_cust_info
where cst_firstname!=trim(cst_firstname)

select cst_lastname from ods.crm_cust_info
where cst_lastname!=trim(cst_lastname)

select distinct cst_marital_status from ods.crm_cust_info

select distinct cst_gndr from ods.crm_cust_info

select cst_create_date
from ods.crm_cust_info
where cst_create_date is not null
or try_convert(date,cst_create_date,111) is null

--ods.erp_cust_az12
select cid from ods.erp_cust_az12
where cid!=trim(cid) or cid not like 'NAS%'

select bdate
from ods.erp_cust_az12
where bdate is not null
or try_convert(date,bdate,111) is null

select distinct gen from ods.erp_cust_az12

select gen from ods.erp_cust_az12
where gen!=trim(gen)

--ods.erp_loc_a101
select distinct cntry from ods.erp_loc_a101

select cntry from ods.erp_loc_a101
where cntry!=trim(cntry)

--dim_customers







