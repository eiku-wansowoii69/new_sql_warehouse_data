/*
1.存储过程 dwd.load_dwd，实现 ODS 到 DWD 层全量 ETL。接收 @batch_id 批次参数，写入 load_batch_id 用于数据追溯。
2.采用 TRUNCATE 全量覆盖，单表独立事务；TRY/CATCH 捕获并输出错误日志。
3.使用 CTE 完成数据清洗、多表关联整合，分别构建客户维度、产品维度、销售明细事实表，自动生成代理键，标准化字段并修正业务异常数据。
4.调用前需先执行 ODS 层 ETL。
*/

--EXEC ods.load_ods @batch_id = 2026091801;
--GO
--EXEC dwd.load_dwd @batch_id = 2026091801;
--GO

USE NewDataWareHouse;
GO

CREATE OR ALTER PROCEDURE dwd.load_dwd(
    @batch_id BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE
        @start_time DATETIME,
        @end_time DATETIME,
        @current_table NVARCHAR(200); -- 标记当前加载哪张表，用于报错日志
    BEGIN TRY
        PRINT '=============================================';
        PRINT 'DWD Layer ETL Start, BatchID: ' + CAST(@batch_id AS NVARCHAR);
        PRINT '=============================================';
        PRINT 'Loading ODS cleaned data to DWD dimension & fact tables';
        PRINT '---------------------------------------------';

        --1.加载dim_customers客户维度表
        SET @current_table = 'dwd.dim_customers';
        PRINT '>> Start loading table: ' + @current_table;
        SET @start_time = GETDATE();

        BEGIN TRANSACTION;-- 先清空目标DWD表
            TRUNCATE TABLE dwd.dim_customers;

            WITH clean_cust_info AS(
	            SELECT cst_id,--清洗id(不为空且大于0）
	            cst_key,--清洗字段（没有空格）
	            TRIM(cst_firstname) AS cst_firstname,
                TRIM(cst_lastname) AS cst_lastname,
                CASE WHEN cst_marital_status='S' THEN 'Single'
                     WHEN cst_marital_status='M' THEN 'Married'
                     ELSE 'n/a'
                END AS cst_marital_status,--查看分类
                CASE WHEN cst_gndr='F' THEN 'Female'
                     WHEN cst_gndr='M' THEN 'Male'
                     ELSE 'n/a'
                END AS cst_gndr,
                TRY_CONVERT(DATE,cst_create_date,111) AS cst_create_date --转格式
                FROM(
                    SELECT *,
                    ROW_NUMBER()OVER(PARTITION BY cst_id ORDER BY TRY_CONVERT(DATE,cst_create_date,111) DESC)AS rk
                    FROM ods.crm_cust_info
                    WHERE cst_id IS NOT NULL AND cst_id>0
                )t
                WHERE rk=1
            ),
            clean_cust_az AS(
                SELECT
                CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
                     ELSE cid
                END AS cid,
                TRY_CONVERT(DATE,bdate,111) AS bdate,
                CASE WHEN UPPER(gen) IN ('F','FEMALE') THEN 'Female'
                     WHEN UPPER(gen) IN ('M','MALE') THEN 'Male'
                     ELSE 'n/a'
                END AS gen
                FROM ods.erp_cust_az12
            ),
            clean_loc_a AS(
                SELECT
                REPLACE(cid,'-','') as cid,
                CASE WHEN cntry='DE' THEN 'Germany'
                     WHEN cntry IN ('US','USA') THEN 'United States'
                     WHEN cntry IS NULL OR cntry='' THEN 'n/a'
                     ELSE cntry 
                END AS cntry
                FROM ods.erp_loc_a101
            )
            INSERT INTO dwd.dim_customers (
                customer_key,
                customer_id,
                customer_number,
                first_name,
                last_name,
                marital_status,
                gender,
                create_date,
                birthdate,
                country,
                load_batch_id
            )
            SELECT ROW_NUMBER()OVER(ORDER BY ci.cst_id) AS customer_key,
                ci.cst_id AS customer_id,
                ci.cst_key AS customer_number,
                ci.cst_firstname AS first_name,
                ci.cst_lastname AS last_name,
                ci.cst_marital_status AS marital_status,
                CASE WHEN ci.cst_gndr!='n/a' THEN ci.cst_gndr
                     ELSE COALESCE(ca.gen,'n/a')
                END AS gender,
                ci.cst_create_date AS create_date,
                ca.bdate AS birthdate,
                la.cntry AS country,
                @batch_id AS load_batch_id
            FROM clean_cust_info ci
            LEFT JOIN clean_cust_az ca ON ci.cst_key = ca.cid
            LEFT JOIN clean_loc_a la ON ci.cst_key = la.cid

        COMMIT TRANSACTION;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------------------------------------';


        --2.加载dim_products产品维度表
        SET @current_table = 'dwd.dim_products';
        PRINT '>> Start loading table: ' + @current_table;
        SET @start_time = GETDATE();

        BEGIN TRANSACTION;
            TRUNCATE TABLE dwd.dim_products;

            WITH clean_prd_info AS(
                SELECT prd_id,
                REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
                SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
                prd_nm,
                ISNULL(prd_cost,0) AS prd_cost,--成本不能为空值（如果不为空值返回表达式本身，为空值就换成0）
                CASE prd_line
	                WHEN 'M' THEN 'Mountain'
	                WHEN 'R' THEN 'Road'
	                WHEN 'S' THEN 'Other Sales'
	                WHEN 'T' THEN 'Touring'
	                ELSE 'n/a'
	            END AS prd_line,
                CAST(prd_start_dt AS DATE) AS prd_start_dt,
                DATEADD(DAY,-1,CAST(LEAD(prd_start_dt)OVER(PARTITION BY prd_key ORDER BY CAST(prd_start_dt AS DATE))AS DATE)) AS prd_end_dt
                FROM ods.crm_prd_info
            ),
            clean_px_cat AS(
                SELECT id,
                cat,
                subcat,
                maintenance
                FROM ods.erp_px_cat_g1v2
            )
            INSERT INTO dwd.dim_products (
                product_key,
                product_id,
                product_number,
                product_name,
                cat_id,
                cat,
                subcat,
                cost,
                line,
                start_date,
                end_date,
                maintenance,
                load_batch_id
            )
            SELECT ROW_NUMBER()OVER(ORDER BY pn.prd_id) AS product_key,
            pn.prd_id AS product_id,
            pn.prd_key AS product_number,
            pn.prd_nm AS product_name,
            pn.cat_id,
            pc.cat,
            pc.subcat,
            pn.prd_cost AS cost,
            pn.prd_line AS line,
            pn.prd_start_dt AS start_date,
            pn.prd_end_dt AS end_date,
            pc.maintenance,
            @batch_id AS load_batch_id
            FROM clean_prd_info pn
            LEFT JOIN clean_px_cat pc ON pn.cat_id=pc.id

        COMMIT TRANSACTION;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------------------------------------';


        --3.加载fact_sales销售事实表
        SET @current_table = 'dwd.fact_sales';
        PRINT '>> Start loading table: ' + @current_table;
        SET @start_time = GETDATE();

        BEGIN TRANSACTION;
            TRUNCATE TABLE dwd.fact_sales;

            INSERT INTO dwd.fact_sales (
                order_number,
                product_number,
                customer_id,
                order_date,
                ship_date,
                due_date,
                sales,
                quantity,
                price,
                load_batch_id
            )
            SELECT sls_ord_num AS order_number,
            sls_prd_key AS product_number,
            sls_cust_id AS customer_id,
            CASE WHEN sls_order_dt= '0' OR LEN(TRIM(sls_order_dt))!= 8 THEN NULL --如果源表里存的是varchar类型就这样转
                 ELSE TRY_CONVERT(DATE,TRIM(sls_order_dt),112) --112的类型就是这种8位数字的日期
            END AS order_date,
            CASE WHEN sls_ship_dt= '0' OR LEN(TRIM(sls_ship_dt))!= 8 THEN NULL 
                 ELSE TRY_CONVERT(DATE,TRIM(sls_ship_dt),112)
            END AS ship_date,
            CASE WHEN sls_due_dt= '0' OR LEN(TRIM(sls_due_dt))!= 8 THEN NULL 
                 ELSE TRY_CONVERT(DATE,TRIM(sls_due_dt),112)
            END AS due_date,
            CASE WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales!=sls_quantity*ABS(sls_price) 
                   THEN sls_quantity*ABS(sls_price) 
                 ELSE sls_sales
            END AS sales,
            sls_quantity AS quantity,
            CASE WHEN sls_price IS NULL OR sls_price<=0 
                   THEN sls_sales/NULLIF(sls_quantity,0)--如果表达式1=表达式2→返回NULL 否则返回表达式1
                 ELSE sls_price
            END AS price,
            @batch_id AS load_batch_id
            from ods.crm_sales_details

        COMMIT TRANSACTION;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------------------------------------';


        -- DWD整体完成日志
        PRINT '=============================================';
        PRINT 'DWD Layer ETL Completed Successfully, BatchID: ' + CAST(@batch_id AS NVARCHAR);
        PRINT '=============================================';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT '=============================================';
        PRINT 'ERROR OCCURRED DURING DWD LOAD';
        PRINT 'Failed when loading table: ' + @current_table;
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=============================================';
        THROW;
    END CATCH
END
GO





