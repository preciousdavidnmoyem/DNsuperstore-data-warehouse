/*
===================================================================
Stored Procedure to load data into bronze layer 
===================================================================
Script Purpose:
This script eecutes full load into the bronze layer, by;
- Truncating the tables 
and 
- Inserting values using "BULK INSERT" to the tables

This procedure does not accept parameters or return any value

The stored procedure script is:
exec bronze.load_bronze;
*/


create or alter procedure bronze.load_bronze as
begin
declare @bronze_start_time datetime, @bronze_end_time datetime;
set @bronze_start_time = getdate()
	declare @start_time datetime, @end_time datetime;
	begin try
		print'============================================';
		print'loading bronze layer';
		print'============================================';

		set @start_time= getdate()
		print'>> truncating bronze.crm_cust_info';
		truncate table bronze.crm_cust_info

		print'>>inserting data into bronze.crm_cust_info';
		bulk insert bronze.crm_cust_info
		from 'C:\databases\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with(
			firstrow = 2,
			fieldterminator = ',',
			tablock
		);
		set @end_time = getdate()
		print'>> load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
		print'-------------';



		set @start_time = getdate()

		print'>> truncating bronze.crm_prd_info';
		truncate table bronze.crm_prd_info

		print'>> inserting data into bronze.crm_prd_info';
		bulk insert bronze.crm_prd_info
		from 'C:\databases\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with(
			firstrow = 2,
			fieldterminator = ',',
			tablock
		)
		set @end_time =getdate()
		print'>> load duration ' + cast(datediff(second,@start_time, @end_time) as nvarchar) + ' seconds';
		print'------------';


		set @start_time =GETDATE()
		
		print'>> truncating bronze.crm_sales_details';
		truncate table bronze.crm_sales_details

		
		print'>> inserting data into bronze.crm_sales_details';
		bulk insert bronze.crm_sales_details
		from 'C:\databases\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with(
			firstrow = 2,
			fieldterminator = ',',
			tablock
		)
		set @end_time = GETDATE()
		print'>> load time ' + cast(datediff(second,@start_time, @end_time) as nvarchar) +' seconds';
		print'--------------';


		set @start_time= getdate()

		print'>> truncating bronze.erp_cust_az12';
		truncate table bronze.erp_cust_az12

		print'>> inserting data into bronze.erp_cust_az12';
		bulk insert bronze.erp_cust_az12
		from 'C:\databases\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with(
			firstrow =2,
			fieldterminator = ',',
			tablock
		)
		set @end_time = GETDATE()
		print'>> load time ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
		print'--------------';



		set @start_time = getdate()

		print'>> truncating bronze.erp_loc_a101';
		truncate table bronze.erp_loc_a101

		print'>> inserting data into bronze.erp_loc_a101';
		bulk insert bronze.erp_loc_a101
		from 'C:\databases\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		with(
			firstrow = 2,
			fieldterminator = ',',
			tablock
		)
		set @end_time = getdate()
		print'>> load time ' + cast(datediff(second, @start_time,@end_time) as nvarchar) + ' seconds';
		print'-------------------';



		set @start_time = getdate()

		print'>> truncating bronze.erp_px_cat_g1v2';
		truncate table bronze.erp_px_cat_g1v2

		print'>>inserting data into bronze.erp_px_cat_g1v2';
		bulk insert bronze.erp_px_cat_g1v2
		from 'C:\databases\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with(
			firstrow = 2,
			fieldterminator = ',',
			tablock
		)
		set @end_time = getdate()
		print'>> load time ' + cast(datediff(second, @start_time, @end_time) as nvarchar) +' seconds';
		print'-------------';
	set @bronze_end_time = getdate()
	print'=============================================================';
	print'>> bronze load time ' + cast(datediff(second, @bronze_start_time, @bronze_end_time) as nvarchar) + ' seconds';
	print'=============================================================';
	end try
	begin catch
	print'=================================='
	print'error occured during loading bronze layer'
	print'error message: ' + error_message();
	print'error number: ' + cast(error_number() as nvarchar);
	print'error state: ' + cast(error_state() as nvarchar);
	end catch
end
