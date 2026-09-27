USE NewDataWareHouse;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ads')
    EXEC('CREATE SCHEMA ads');
GO

CREATE OR ALTER VIEW ads.v_sales_flat
AS
SELECT
    -- 事实表
    f.order_number,
    f.customer_id,
    f.order_date,
    f.sales,
    f.quantity,
    f.price,

    -- 客户维度
    c.first_name,
    c.last_name,
    c.gender,
    c.country,

    -- 产品维度
    p.cat,
    p.subcat, 
    p.line,
    p.cost

FROM dwd.fact_sales f
LEFT JOIN dwd.dim_customers c ON f.customer_key = c.customer_key
LEFT JOIN dwd.dim_products  p ON f.product_key  = p.product_key;
GO