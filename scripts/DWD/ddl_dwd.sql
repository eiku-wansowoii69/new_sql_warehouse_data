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