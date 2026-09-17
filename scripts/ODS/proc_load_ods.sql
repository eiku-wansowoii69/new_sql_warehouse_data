/*
项目说明：
本存储过程为本地演示版本。
BULK INSERT FROM子句为硬编码文件路径，搭配@current_file变量记录当前加载文件，用于日志打印、审计字段写入以及异常定位。

生产环境说明:
真实企业场景不会在T-SQL内硬编码文件路径。
主流方案：使用SSIS/ADF完成源文件读取与批量入库，数据库存储过程仅负责ODS层审计字段填充、数据质量校验，文件IO逻辑和数据库逻辑解耦。
*/
--EXEC ods.load_ods @batch_id = 2026091701;
USE NewDataWareHouse;
GO
CREATE OR ALTER PROCEDURE ods.load_ods(
	@batch_id BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @start_time DATETIME,@end_time DATETIME;
	DECLARE @current_file NVARCHAR(500); --仅用于日志和审计字段，不用于BULK INSERT FROM
	BEGIN TRY
	    --开始
		PRINT '====================================';
		PRINT 'ODS Layer ETL Start, BatchID: ' + CAST(@batch_id AS NVARCHAR);
		PRINT '====================================';
		PRINT '------------------------------------';
		PRINT 'Loading CSV into STG then to ODS';
		PRINT '------------------------------------';

		--1.加载 stg.crm_cust_info → ods.crm_cust_info
		SET @current_file = 'D:\31418\new_sql_warehouse_data\datasets\source_crm\cust_info.csv';
		PRINT '>> Start loading file: ' + @current_file;
		SET @start_time = GETDATE();
		BEGIN TRANSACTION;
			TRUNCATE TABLE stg.crm_cust_info;
			BULK INSERT stg.crm_cust_info
			FROM 'D:\31418\new_sql_warehouse_data\datasets\source_crm\cust_info.csv'
			WITH (
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				ROWTERMINATOR='\n',
				TABLOCK
			);
			TRUNCATE TABLE ods.crm_cust_info;
			INSERT INTO ods.crm_cust_info(cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date,load_datetime,source_file,load_batch_id)
			SELECT *, GETDATE(), @current_file, @batch_id FROM stg.crm_cust_info;
		COMMIT TRANSACTION;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> --------------';

		--2.加载 stg.crm_prd_info → ods.crm_prd_info
		SET @current_file = 'D:\31418\new_sql_warehouse_data\datasets\source_crm\prd_info.csv';
		PRINT '>> Start loading file: ' + @current_file;
		SET @start_time = GETDATE();
		BEGIN TRANSACTION;
			TRUNCATE TABLE stg.crm_prd_info;
			BULK INSERT stg.crm_prd_info
			FROM 'D:\31418\new_sql_warehouse_data\datasets\source_crm\prd_info.csv'
			WITH (
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				ROWTERMINATOR='\n',
				TABLOCK
			);
			TRUNCATE TABLE ods.crm_prd_info;
			INSERT INTO ods.crm_prd_info(prd_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt,load_datetime,source_file,load_batch_id)
			SELECT *, GETDATE(), @current_file, @batch_id FROM stg.crm_prd_info;
		COMMIT TRANSACTION;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> --------------';

		--3.加载 stg.crm_sales_details → ods.crm_sales_details
		SET @current_file = 'D:\31418\new_sql_warehouse_data\datasets\source_crm\sales_details.csv';
		PRINT '>> Start loading file: ' + @current_file;
		SET @start_time = GETDATE();
		BEGIN TRANSACTION;
			TRUNCATE TABLE stg.crm_sales_details;
			BULK INSERT stg.crm_sales_details
			FROM 'D:\31418\new_sql_warehouse_data\datasets\source_crm\sales_details.csv'
			WITH (
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				ROWTERMINATOR='\n',
				TABLOCK
			);
			TRUNCATE TABLE ods.crm_sales_details;
			INSERT INTO ods.crm_sales_details(sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price,load_datetime,source_file,load_batch_id)
			SELECT *, GETDATE(), @current_file, @batch_id FROM stg.crm_sales_details;
		COMMIT TRANSACTION;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> --------------';

        --4.加载 stg.erp_cust_az12 → ods.erp_cust_az12
		SET @current_file = 'D:\31418\new_sql_warehouse_data\datasets\source_erp\cust_az12.csv';
		PRINT '>> Start loading file: ' + @current_file;
		SET @start_time = GETDATE();
		BEGIN TRANSACTION;
			TRUNCATE TABLE stg.erp_cust_az12;
			BULK INSERT stg.erp_cust_az12
			FROM 'D:\31418\new_sql_warehouse_data\datasets\source_erp\cust_az12.csv'
			WITH (
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				ROWTERMINATOR='\n',
				TABLOCK
			);
			TRUNCATE TABLE ods.erp_cust_az12;
			INSERT INTO ods.erp_cust_az12(cid,bdate,gen,load_datetime,source_file,load_batch_id)
			SELECT *, GETDATE(), @current_file, @batch_id FROM stg.erp_cust_az12;
		COMMIT TRANSACTION;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> --------------';

        --5.加载 stg.erp_loc_a101 → ods.erp_loc_a101
		SET @current_file = 'D:\31418\new_sql_warehouse_data\datasets\source_erp\loc_a101.csv';
		PRINT '>> Start loading file: ' + @current_file;
		SET @start_time = GETDATE();
		BEGIN TRANSACTION;
			TRUNCATE TABLE stg.erp_loc_a101;
			BULK INSERT stg.erp_loc_a101
			FROM 'D:\31418\new_sql_warehouse_data\datasets\source_erp\loc_a101.csv'
			WITH (
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				ROWTERMINATOR='\n',
				TABLOCK
			);
			TRUNCATE TABLE ods.erp_loc_a101;
			INSERT INTO ods.erp_loc_a101(cid,cntry,load_datetime,source_file,load_batch_id)
			SELECT *, GETDATE(), @current_file, @batch_id FROM stg.erp_loc_a101;
		COMMIT TRANSACTION;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> --------------';

        --6.加载 stg.erp_px_cat_g1v2 → ods.erp_px_cat_g1v2
		SET @current_file = 'D:\31418\new_sql_warehouse_data\datasets\source_erp\px_cat_g1v2.csv';
		PRINT '>> Start loading file: ' + @current_file;
		SET @start_time = GETDATE();
		BEGIN TRANSACTION;
			TRUNCATE TABLE stg.erp_px_cat_g1v2;
			BULK INSERT stg.erp_px_cat_g1v2
			FROM 'D:\31418\new_sql_warehouse_data\datasets\source_erp\px_cat_g1v2.csv'
			WITH (
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				ROWTERMINATOR='\n',
				TABLOCK
			);
			TRUNCATE TABLE ods.erp_px_cat_g1v2;
			INSERT INTO ods.erp_px_cat_g1v2(id,cat,subcat,maintenance,load_datetime,source_file,load_batch_id)
			SELECT *, GETDATE(), @current_file, @batch_id FROM stg.erp_px_cat_g1v2;
		COMMIT TRANSACTION;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> --------------';

		--结束
		PRINT '====================================';
		PRINT 'ODS Layer ETL Completed Successfully, BatchID: ' + CAST(@batch_id AS NVARCHAR);
		PRINT '====================================';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		PRINT '====================================';
		PRINT 'ERROR OCCURRED DURING ODS LOAD';
		PRINT 'Failed when loading file: ' + @current_file; 
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '====================================';
		THROW;
	END CATCH
END
GO
