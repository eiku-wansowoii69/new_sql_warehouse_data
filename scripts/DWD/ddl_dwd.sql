/*
脚本名称：DWD 层建表脚本
功能：创建数据仓库明细层（dwd schema），采用星型模型构建电商数据集的事实表和维度表，
      用于存储经过清洗、类型转换和标准化后的明细数据。
说明：脚本使用 IF OBJECT_ID 判等判断，表已存在时跳过，可重复运行；
      共 3 张表，分为 1 张事实表（fact_sales）和 2 张维度表（dim_customers、dim_products）；
      每张表末尾均附加 load_batch_id 字段，记录数据来自哪一批 raw 数据，实现全仓库数据可追溯；
      事实表存储订单明细，维度表存储客户、商品信息，便于后续多维度关联分析。
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
    customer_key INT,              
    product_key INT,                
    customer_id INT,                 
    product_number NVARCHAR(50),      
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
