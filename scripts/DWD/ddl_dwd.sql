/*
脚本功能：DWD明细层建表脚本
采用幂等判断 IF OBJECT_ID，表不存在时才创建，可重复运行。
构建星型模型：客户维度dim_customers、产品维度dim_products、销售事实fact_sales。
维度表设置代理主键保证数据唯一；所有表增加load_batch_id，记录ETL批次号，实现全链路数据追溯。
dim_customers：整合CRM客户与ERP生日、国家信息；
dim_products：整合CRM产品与ERP产品分类信息；
fact_sales：存储订单明细，保存销售度量指标，用于多维统计分析。
*/
USE NewDataWareHouse;
GO
--CREATE SCHEMA dwd;
--GO

--DWD 客户维度表 dim_customers：crm客户 + ERP生日 + ERP国家
IF OBJECT_ID('dwd.dim_customers','U') IS NULL
BEGIN
CREATE TABLE dwd.dim_customers(
    customer_key INT PRIMARY KEY,
    customer_id INT,
    customer_number NVARCHAR(50),
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    marital_status NVARCHAR(50),
    gender NVARCHAR(50),
    create_date DATE,
    birthdate DATE,
    country NVARCHAR(50),
    load_batch_id BIGINT NULL
);
END
GO

--DWD 产品维度表 dim_products：crm产品 + ERP产品分类信息
IF OBJECT_ID('dwd.dim_products','U') IS NULL
BEGIN
CREATE TABLE dwd.dim_products(
    product_key INT PRIMARY KEY,
    product_id INT,
    product_number NVARCHAR(50),
    product_name NVARCHAR(50),
    cat_id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    cost INT,
    line NVARCHAR(50),
    start_date DATE,
    maintenance NVARCHAR(10),
    load_batch_id BIGINT NULL
);
END
GO

--DWD 销售事实表 fact_sales：每一笔订单明细
IF OBJECT_ID('dwd.fact_sales','U') IS NULL
BEGIN
CREATE TABLE dwd.fact_sales(
    order_number NVARCHAR(50),
    product_number NVARCHAR(50),
    customer_id INT,
    order_date DATE,
    ship_date DATE,
    due_date DATE,
    sales INT,
    quantity INT,
    price INT,
    load_batch_id BIGINT NULL
);
END
GO
