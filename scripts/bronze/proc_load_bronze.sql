/*
=========================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=========================================================================================
Script Purpose:
	This stored procedure loads data into 'bronze' schema from external csv files.
	It performs the following actions:
	 - Uses the 'BULK INSERT'  command to load the data from csv files to bronze tables.

Paarameters:
	None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
	EXEC bronze.load_bronze;
=========================================================================================
*/



CREATE OR ALTER PROCEDURE bronze.load_bronze AS
	BEGIN
		DECLARE @start_time DATETIME ,@end_time DATETIME;
		DECLARE @batch_start_time DATETIME,@batch_end_time DATETIME;
			BEGIN TRY
				SET @batch_start_time=GETDATE();
				PRINT'==============================================================';
				PRINT'Laoding Bronze Layer';
				PRINT'==============================================================';

				PRINT'--------------------------------------------------------------';
				SET @start_time=GETDATE();
				PRINT'Loading CRM Tables';
				PRINT'--------------------------------------------------------------';
				
				SET @start_time=GETDATE();
				PRINT'>> Truncating Table: bronze.crm_cust_info';
				TRUNCATE TABLE  bronze.crm_cust_info;
				PRINT'Inserting Data Into : bronze.crm_cust_info';
				BULK INSERT bronze.crm_cust_info FROM 'C:\Users\Bikash chetry\OneDrive\Desktop\ALL Sql files\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
				WITH (
					FIRSTROW=2,
					FIELDTERMINATOR=',',
					TABLOCK
				);
				SET @end_time=GETDATE();
				PRINT'>>Load duration :'+CAST(DATEDIFF(second,@start_time,@end_time ) AS VARCHAR)+ 'seconds';


				SET @start_time=GETDATE();	
				PRINT'>> Truncating Table: bronze.crm_prd_info';
				TRUNCATE TABLE  bronze.crm_prd_info;
				PRINT'Inserting Data Into : bronze.crm_prd_info';
				BULK INSERT bronze.crm_prd_info FROM 'C:\Users\Bikash chetry\OneDrive\Desktop\ALL Sql files\sql-data-warehouse-project\datasets\source_crm\prd_info.CSV'
				WITH (
					FIRSTROW=2,
					FIELDTERMINATOR=',',
					TABLOCK
				);
				SET @end_time=GETDATE();
				PRINT'>>Load duration :'+CAST(DATEDIFF(second,@start_time,@end_time ) AS VARCHAR)+ 'seconds';


				SET @start_time=GETDATE();
				PRINT'>> Truncating Table: bronze.crm_sales_details';
				TRUNCATE TABLE  bronze.crm_sales_details;
				PRINT'Inserting Data Into : bronze.crm_sales_details';
				BULK INSERT bronze.crm_sales_details FROM'C:\Users\Bikash chetry\OneDrive\Desktop\ALL Sql files\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
				WITH(
					FIRSTROW=2,
					FIELDTERMINATOR=',',
					TABLOCK
				);
				SET @end_time=GETDATE();
				PRINT'>>Load duration :'+CAST(DATEDIFF(second,@start_time,@end_time ) AS VARCHAR)+ 'seconds';


				PRINT'>>------------------------------------------;'
				PRINT'--------------------------------------------------------------';
				PRINT'Loading ERP Tables';
				PRINT'--------------------------------------------------------------';


				
				SET @start_time=GETDATE();
				PRINT'>> Truncating Table: bronze.erp_cust_az12';
				TRUNCATE TABLE  bronze.erp_cust_az12;
				PRINT'Inserting Data Into : bronze.erp_cust_az12';
				BULK INSERT bronze.erp_cust_az12 FROM 'C:\Users\Bikash chetry\OneDrive\Desktop\ALL Sql files\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv' 
				WITH
				(
					FIRSTROW=2,
					FIELDTERMINATOR=',',
					TABLOCK
				);
				SET @end_time=GETDATE();
				PRINT'>>Load duration :'+CAST(DATEDIFF(second,@start_time,@end_time ) AS VARCHAR)+ 'seconds';


				SET @start_time=GETDATE();
				PRINT'>> Truncating Table: bronze.erp_loc_a101';
				TRUNCATE TABLE  bronze.erp_loc_a101;
				PRINT'Inserting Data Into : bronze.erp_loc_a101';
				BULK INSERT bronze.erp_loc_a101 FROM 'C:\Users\Bikash chetry\OneDrive\Desktop\ALL Sql files\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
				WITH
				(
					FIRSTROW=2,
					FIELDTERMINATOR=',',
					TABLOCK
				);
				SET @end_time=GETDATE();
				PRINT'>>Load duration :'+CAST(DATEDIFF(second,@start_time,@end_time ) AS VARCHAR)+ 'seconds';


				SET @start_time=GETDATE();
				PRINT'>> Truncating Table: bronze.erp_px_cat_g1v2';
				TRUNCATE TABLE  bronze.erp_px_cat_g1v2;
				PRINT'Inserting Data Into : bronze.erp_px_cat_g1v2';
				BULK INSERT bronze.erp_px_cat_g1v2 FROM 'C:\Users\Bikash chetry\OneDrive\Desktop\ALL Sql files\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
				WITH
				(
					FIRSTROW=2,
					FIELDTERMINATOR=',',
					TABLOCK
				);
				SET @end_time=GETDATE();
				PRINT'>>Load duration :'+CAST(DATEDIFF(second,@start_time,@end_time ) AS VARCHAR)+ 'seconds';

				SET @batch_end_time=GETDATE();
				PRINT'-------------------------------------------------------------------';
				PRINT'Loading Bronze Layer is completed';
				PRINT'-Total Load Duration:' + CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS VARCHAR) + 'seconds';
				PRINT'-------------------------------------------------------------------';
			END TRY

			BEGIN CATCH
				PRINT'=========================================================';
				PRINT'Error Occured During Loading Bronze Layer';
				PRINT'=========================================================';
				PRINT'Error Message'+ERROR_MESSAGE();
				PRINT'Error Message'+CAST(ERROR_NUMBER () AS VARCHAR);
				PRINT'Error Message'+CAST(ERROR_STATE() AS VARCHAR);
			END CATCH
	END



EXECUTE bronze.load_bronze;


