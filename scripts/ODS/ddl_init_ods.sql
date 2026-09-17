/*
脚本功能：搭建数仓ODS原始数据层
说明：
1.本脚本用于创建数据仓库数据库、stg 暂存模式与 ods 原始数据模式，并完成 STG 暂存表和 ODS 原始数据表的建表工作。
2.STG 层表结构与 CSV 源文件保持一致，仅存放原始业务数据；
3.ODS 层在业务字段基础上增加加载时间、源文件路径、批次号三个审计字段，用于记录 ETL 加载信息，为后续 DWD 层数据清洗提供基础数据源。
*/
USE master;
GO
CREATE DATABASE NewDataWareHouse;
GO
USE NewDataWareHouse;
GO
CREATE SCHEMA ods;
GO
--STG 暂存表（纯业务字段，和CSV对齐，一次性建好）
IF OBJECT_ID('stg.crm_cust_info','U') IS NULL
BEGIN
CREATE TABLE stg.crm_cust_info(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date NVARCHAR(10)
);
END
GO
IF OBJECT_ID('stg.crm_prd_info','U') IS NULL
BEGIN
CREATE TABLE stg.crm_prd_info(
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt NVARCHAR(10),
    prd_end_dt NVARCHAR(10)
);
END
GO
IF OBJECT_ID('stg.crm_sales_details','U') IS NULL
BEGIN
CREATE TABLE stg.crm_sales_details(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt NVARCHAR(10),
    sls_ship_dt NVARCHAR(10),
    sls_due_dt NVARCHAR(10),
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);
END
GO
IF OBJECT_ID('stg.erp_cust_az12','U') IS NULL
BEGIN
CREATE TABLE stg.erp_cust_az12(
    cid NVARCHAR(50),
    bdate NVARCHAR(10),
    gen NVARCHAR(10)
);
END
GO
IF OBJECT_ID('stg.erp_loc_a101','U') IS NULL
BEGIN
CREATE TABLE stg.erp_loc_a101(
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);
END
GO
IF OBJECT_ID('stg.erp_px_cat_g1v2','U') IS NULL
BEGIN
CREATE TABLE stg.erp_px_cat_g1v2(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(10)
);
END
GO
--ODS 基表（业务字段 + 3个审计字段，后续DWD清洗来源）
IF OBJECT_ID('ods.crm_cust_info','U') IS NULL
BEGIN
CREATE TABLE ods.crm_cust_info(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date NVARCHAR(10),
    load_datetime DATETIME NULL,
    source_file NVARCHAR(500) NULL,
    load_batch_id BIGINT NULL
);
END
GO
IF OBJECT_ID('ods.crm_prd_info','U') IS NULL
BEGIN
CREATE TABLE ods.crm_prd_info(
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt NVARCHAR(10),
    prd_end_dt NVARCHAR(10),
    load_datetime DATETIME NULL,
    source_file NVARCHAR(500) NULL,
    load_batch_id BIGINT NULL
);
END
GO
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
GO
IF OBJECT_ID('ods.erp_cust_az12','U') IS NULL
BEGIN
CREATE TABLE ods.erp_cust_az12(
    cid NVARCHAR(50),
    bdate NVARCHAR(10),
    gen NVARCHAR(10),
    load_datetime DATETIME NULL,
    source_file NVARCHAR(500) NULL,
    load_batch_id BIGINT NULL
);
END
GO
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
GO
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
