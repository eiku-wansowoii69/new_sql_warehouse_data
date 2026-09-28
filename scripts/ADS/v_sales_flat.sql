/*
脚本名称：ADS 层销售宽表视图脚本
功能：创建数据仓库应用层（ads schema），构建销售明细宽表视图（v_sales_flat），
      将 DWD 层的销售事实表与客户、产品维度表进行关联，用于支持下游 BI 报表和多维分析。
说明：脚本使用 IF NOT EXISTS 判断 schema 是否存在，表已存在时跳过，可重复运行；
      视图整合了订单、客户、产品三个维度的核心字段，屏蔽了底层物理表的复杂关联；
      所有关联均采用 LEFT JOIN，确保事实表数据不丢失。
*/
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
