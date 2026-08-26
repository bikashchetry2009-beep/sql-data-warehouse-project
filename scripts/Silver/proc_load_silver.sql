/*
=========================================================================================
Stored Procedure: Load Silver Layer (Source -> Silver)
=========================================================================================
Script Purpose:
	This stored procedure performs the ETL(Extract,Transform,Load) process to populate the 'silver' schema tables from the 'bronze' schema.
	Actions performed:
	 - Truncate silbver tables.
   - Insert transformed and cleansed data from bronze into silver tables. 

Paarameters:
	None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
	EXEC bronze.load_bronze;
=========================================================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	BEGIN TRY
		DECLARE @start_time DATETIME,@end_time DATETIME;
		DECLARE @batch_start_time DATETIME,@batch_end_time DATETIME;
		SET @batch_start_time=GETDATE();
		PRINT'========================================================================';
		PRINT'Loading Silver Layer';
		IF OBJECT_ID('silver.crm_cust_info','U') IS NOT NULL
		DROP TABLE silver.crm_cust_info ;
		PRINT'=========================================================================';
		PRINT'-------------------------------------------------------------------------';
		PRINT'Loading CRM Tables';
		PRINT'-------------------------------------------------------------------------';
		PRINT'==========================================================================';
		SET @start_time=GETDATE();
	
		CREATE TABLE silver.crm_cust_info 
		(
		cst_id INT,
		cst_key VARCHAR(50),
		cst_firstname VARCHAR(50),
		cst_lastname VARCHAR(50),
		cst_marital_status VARCHAR(50),
		cst_gndr VARCHAR(50),
		cst_create_date DATE,
		dwh_create_date DATETIME2 DEFAULT GETDATE()
		);
		SET @end_time=GETDATE();
		PRINT'Table (silver.crm_cust_info) creating duration:'+CAST(DATEDIFF(SECOND,@end_time,@start_time) AS VARCHAR)+'seconds';
		SET @start_time=GETDATE();
		PRINT'>>Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info; 
		INSERT INTO silver.crm_cust_info 
		(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date
		)

		SELECT 
				cst_id,
				cst_key,
				TRIM(cst_firstname) AS cst_firstname,
				TRIM(cst_lastname) AS cst_lastname,
				CASE
					WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
					WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
					ELSE 'Uknown'
				END
				AS cst_marital_status,
		
				CASE
					WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
					WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
					ELSE 'Unknown'	
				END AS cst_gndr,
				cst_create_date

		FROM
			(
			SELECT *, 
				ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			)t 
			WHERE flag_last=1 ;
			SET @end_time=GETDATE();
			PRINT'Inserting Into (silver.crm_cust_info) Duration:'+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR)+'seconds';
			PRINT'====================================================================';	
		IF OBJECT_ID ('silver.crm_prd_info','U') IS NOT NULL
		DROP TABLE silver.crm_prd_info;
	
		SET @start_time=GETDATE();
		CREATE TABLE silver.crm_prd_info
		(
		prd_id INT,
		cat_id VARCHAR(50),
		prd_key VARCHAR(50),
		prd_nm VARCHAR(50),
		prd_cost INT,
		prd_line VARCHAR(50),
		prd_start_dt DATE,
		prd_end_dt DATE,
		dwh_create_date DATETIME2 DEFAULT GETDATE()
		);
		SET @end_time=GETDATE();
		PRINT'Table (silver.crm_prd_info) creating duration :'+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR)+'seconds';
	
		SET @start_time=GETDATE();
		PRINT'>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		INSERT INTO silver.crm_prd_info
		(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)
		SELECT
				prd_id,
				REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
				SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
				TRIM(prd_nm) AS prd_nm,
				ISNULL(prd_cost,0) AS prd_cost,
				CASE
					WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
					WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
					WHEN UPPER(TRIM(prd_line))='S' THEN 'Other sales'
					WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
					ELSE 'Unknown'
				END AS prd_line,
				CAST(prd_start_dt AS DATE) AS prd_start_dt,
				CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt )-1 AS DATE)  AS prd_end_dt


		FROM
			bronze.crm_prd_info;

		SET @end_time=GETDATE();
	
		PRINT'Inserting Into (silver.crm_prd_info) Duration:'+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR)+'seconds';
		PRINT'============================================================================';
		IF OBJECT_ID('silver.crm_sales_details','U') IS NOT NULL
		DROP TABLE silver.crm_sales_details;
		SET @start_time=GETDATE();
		CREATE TABLE silver.crm_sales_details
		(
		sls_ord_num VARCHAR(50),
		sls_prd_key VARCHAR(50),
		sls_cust_id INT,
		sls_order_dt  DATE,
		sls_ship_dt DATE,
		sls_due_dt DATE,
		sls_quantity INT,
		sls_sales INT,
		sls_price INT,
		dwh_create_date DATETIME2 DEFAULT GETDATE() 
		);
		SET @end_time=GETDATE();
		PRINT'Table silver.crm_sales_details creating duration:'+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR)+'seconds';
	
		SET @start_time=GETDATE();
		PRINT'>>Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details; 

		INSERT INTO silver.crm_sales_details
		(
		sls_ord_num ,
		sls_prd_key ,
		sls_cust_id ,
		sls_order_dt  ,
		sls_ship_dt ,
		sls_due_dt ,
		sls_quantity ,
		sls_sales ,
		sls_price 
		)
		SELECT
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				CASE 
					WHEN sls_order_dt=0 OR  LEN(sls_order_dt)!=8 THEN NULL
					ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)

				END AS sls_order_dt,
				CASE 
					WHEN sls_order_dt=0 OR  LEN(sls_order_dt)!=8 THEN NULL
					ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)

				END AS sls_ship_dt,
				CASE 
					WHEN sls_order_dt=0 OR  LEN(sls_order_dt)!=8 THEN NULL
					ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)

				END AS sls_due_dt,
		
				sls_quantity,

				CASE
					WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales!=sls_quantity*ABS(sls_price)
						THEN sls_quantity*ABS(sls_price)
					ELSE sls_sales
				END sls_sales,
				CASE
					WHEN sls_price IS NULL OR sls_price<=0 
					THEN sls_sales/NULLIF(sls_quantity,0)
					ELSE sls_price
				END AS sls_price
		
		FROM bronze.crm_sales_details
		;
		SET @end_time=GETDATE();
			PRINT'Inserting Into (silver.crm_sales_details) duration:'+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR)+'seconds';

		PRINT'==========================================================================';
		PRINT'--------------------------------------------------------------------------';
		PRINT'Loding ERP Tables';
		PRINT'--------------------------------------------------------------------------';
		PRINT'==========================================================================';
	
	
		SET @start_time=GETDATE();
		PRINT'>>Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		INSERT INTO silver.erp_cust_az12
		(
		cid,
		bdate,
		gen
		)
		SELECT  
				CASE
					WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
					ELSE cid
				END AS cid,
				CASE 
					WHEN bdate > GETDATE() THEN NULL
					ELSE bdate
				END AS bdate,
				CASE 
					WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
					WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
					ELSE 'Unknown'
				END AS gen
		FROM
		bronze.erp_cust_az12;
		SET @end_time=GETDATE();
		PRINT'Inserting Into (silver.erp_cust_az12) Duration:'+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR)+'seconds';
		PRINT'===========================================================================';
	
	
		SET @start_time=GETDATE();
		PRINT'>>Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		INSERT INTO silver.erp_loc_a101
		(
		cid,
		cntry
		)

		SELECT 
			REPLACE(cid,'-','') AS cid,
			CASE
				WHEN TRIM(cntry) IN ('US','USA','UNITED STATES') 
				THEN 'United States'
				WHEN TRIM(cntry)='DE' THEN 'Germany' 
				WHEN TRIM(cntry) = '' OR UPPER(TRIM(cntry)) IS NULL THEN 'Unknown' 
				ELSE TRIM(cntry)
			END AS cntry
		 FROM bronze.erp_loc_a101
		 ;
		 SET @end_time=GETDATE();
		 PRINT'Insering Into (silver.erp_loc_a101) Duration:'+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR)+'seconds';
		 PRINT'=========================================================================='; 

		 SET @start_time=GETDATE();
		 PRINT'>>Truncating Table: silver.erp_px_cat_g1v2';
		 TRUNCATE TABLE silver.erp_px_cat_g1v2;
		 INSERT INTO silver.erp_px_cat_g1v2
		(
		id,
		cat,
		subcat,
		maintenance
		)

		SELECT 
				id,
				cat,
				subcat,
				maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time=GETDATE();
		PRINT'Inserting Into (silver.erp_px_cat_g1v2) Duration:'+CAST(DATEDIFF(SECOND,@start_time,@end_time) AS VARCHAR)+'seconds';
		PRINT'===========================================================================';

		SET @batch_end_time=GETDATE();
		PRINT'Loading Silver Layer is completed';
		PRINT'Batch running duration:'+CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS VARCHAR)+'seconds';
		PRINT'============================================================================';

	END TRY
	BEGIN CATCH
		PRINT'==================================================================';
		PRINT'ERROR OCCURED DURING BRONZE LAYER';
		PRINT'Error Message'+ERROR_MESSAGE();
		PRINT'Error Message'+CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT'Error Message'+CAST(ERROR_STATE() AS NVARCHAR);
	END CATCH
END;

EXECUTE silver.load_silver;





