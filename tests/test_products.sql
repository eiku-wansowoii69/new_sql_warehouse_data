/*
脚本说明：在DWD进行数据清洗时需测试数据清洗的必要性和类型，此脚本是进行产品维度表清洗时的测试文本。
*/
--ods.crm_prd_info
select prd_id
from ods.crm_prd_info
where prd_id is null or prd_id<=0

select prd_key
from ods.crm_prd_info
where prd_key!=trim(prd_key)

select prd_nm
from ods.crm_prd_info
where prd_nm!=trim(prd_nm)

select distinct prd_line
from ods.crm_prd_info

select prd_line
from ods.crm_prd_info
where prd_line!=trim(prd_line)

select prd_start_dt
from ods.crm_prd_info
where prd_start_dt is null or prd_start_dt=''
or prd_start_dt<'1920-01-01' or prd_start_dt>dateadd(day,+1,getdate())

select prd_start_dt
from ods.crm_prd_info
where prd_start_dt is not null
or try_convert(date,prd_start_dt,111) is null

select prd_end_dt
from ods.crm_prd_info
where prd_end_dt is null or prd_end_dt=''
and prd_end_dt<'1920-01-01' or prd_end_dt>dateadd(day,+1,getdate())

select prd_end_dt
from ods.crm_prd_info
where prd_end_dt is not null
or try_convert(date,prd_end_dt,111) is null

--ods.erp_px_cat_g1v2
select id 
from ods.erp_px_cat_g1v2
where id!=trim(id)

select distinct id from ods.erp_px_cat_g1v2

select distinct cat from ods.erp_px_cat_g1v2
where cat!=trim(cat)

select distinct subcat from ods.erp_px_cat_g1v2
where subcat!=trim(subcat)

select distinct maintenance from ods.erp_px_cat_g1v2
where maintenance!=trim(maintenance)
