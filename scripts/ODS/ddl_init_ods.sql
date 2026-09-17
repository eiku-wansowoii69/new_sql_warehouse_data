/*
脚本功能：搭建数仓ODS原始数据层
说明：
1. 创建数据库NewDataWareHouse，新建ods架构，用于存放源系统原始数据
2. 采用OBJECT_ID判断，仅当表不存在时建表，脚本可重复执行
3. 共6张表，对接CRM、ERP业务源，保留原始字段，不做数据清洗
表清单：
ods.crm_cust_info      CRM客户基础信息
ods.crm_prd_info       CRM产品信息
ods.crm_sales_details  CRM销售订单明细
ods.erp_cust_az12      ERP客户信息
ods.erp_loc_a101       ERP客户地区信息
ods.erp_px_cat_g1v2    ERP产品品类维护信息
*/
USE master;
GO
CREATE DATABASE NewDataWareHouse;
GO
USE NewDataWareHouse;
GO
CREATE SCHEMA ods;
GO
IF OBJECT_ID('ods.crm_cust_info','U') IS NULL
BEGIN
CREATE TABLE ods.crm_cust_info(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE,
    load_datetime DATETIME NULL,
	source_file NVARCHAR(500) NULL,
	load_batch_id BIGINT NULL
);
END
IF OBJECT_ID('ods.crm_prd_info','U') IS NULL
BEGIN
CREATE TABLE ods.crm_prd_info(
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    load_datetime DATETIME NULL,
	source_file NVARCHAR(500) NULL,
	load_batch_id BIGINT NULL
);
END
IF OBJECT_ID('ods.crm_sales_details','U') IS NULL
BEGIN
CREATE TABLE ods.crm_sales_details(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt NVARCHAR(10),
    sls_ship_dt NVARCHAR(10),
    sls_due_dt NVARCHAR(10),
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    load_datetime DATETIME NULL,
	source_file NVARCHAR(500) NULL,
	load_batch_id BIGINT NULL
);
END
IF OBJECT_ID('ods.erp_cust_az12','U') IS NULL
BEGIN
CREATE TABLE ods.erp_cust_az12(
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(10),
    load_datetime DATETIME NULL,
	source_file NVARCHAR(500) NULL,
	load_batch_id BIGINT NULL
);
END
IF OBJECT_ID('ods.erp_loc_a101','U') IS NULL
BEGIN
CREATE TABLE ods.erp_loc_a101(
    cid NVARCHAR(50),
    cntry NVARCHAR(50),
    load_datetime DATETIME NULL,
	source_file NVARCHAR(500) NULL,
	load_batch_id BIGINT NULL
);
END
IF OBJECT_ID('ods.erp_px_cat_g1v2','U') IS NULL
BEGIN
CREATE TABLE ods.erp_px_cat_g1v2(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(10),
    load_datetime DATETIME NULL,
	source_file NVARCHAR(500) NULL,
	load_batch_id BIGINT NULL
);
END
GO
