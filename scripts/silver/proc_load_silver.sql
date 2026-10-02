/*
===================================================================
Stored Procedure to load data from the bronze layer into silver layer 
===================================================================
Script Purpose:
This script performs the ETL(Extract, Transform, and Load) process to populate the silver table
It truncates the tables then inserts cleaned data from the bronze layer to the silver layer

This procedure does not accept parameters or return any value

The stored procedure script is:
exec silver.load_silver;
*/


create or alter procedure silver.load_silver as
begin 
declare @silver_start_time datetime, @silver_end_time datetime;
set @silver_start_time = getdate()
		
		declare @start_time datetime, @end_time datetime;
		begin try
		print'============================================';
		print'loading silver layer';
		print'============================================';

		
			print'---------------------------------------';
			print'loading CRM Tables';
			print'---------------------------------------';

			--loading silver.crm_cust_info
			set @start_time= getdate()
			print'>>> Truncating table: silver.crm_cust_info';
			truncate table silver.crm_cust_info;
			print'>>> inserting data into silver.crm_cust_info';
			INSERT INTO silver.crm_cust_info (
				cst_id,
				cst_key,
				cst_firstname,
				cst_lastname,
				cst_marital_status,
				cst_gndr,
				cst_create_date
				)

			select
				cst_id,
				cst_key,
				trim(cst_firstname) as "cst_firstname",            --trimming names to remove excess spaces
				trim(cst_lastname) as "cst_lastname", 
				case when upper(trim(cst_marital_status)) = 'S' then 'Single'
					 when upper(trim(cst_marital_status)) = 'M' then 'Married'           --Data normalization
					 else 'unknown'
				end as "cst_marital_status",
				case when upper(trim(cst_gndr)) = 'F' then 'Female'
					 when upper(trim(cst_gndr)) = 'M' then 'Male'                   --Data Normalization
					 else 'unknown'
				end as "cst_gndr",
				cst_create_date
			from(
				select 
					*,
					ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_no
				from bronze.crm_cust_info
				where cst_id is not null
				)t																	-- select most recent record and removed duplicates
			where flag_no = 1
			set @end_time = getdate()
				print'>> load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
				print'-------------';


			--loading silver.crm_prd_info
			set @start_time = getdate()

			print'>>> Truncating table: silver.crm_prd_info';
			truncate table silver.crm_prd_info;
			print'>>inserting data into silver.crm_prd_info';
			insert into silver.crm_prd_info(

				   [prd_id]
				  ,[cat_id]
				  ,[prd_key]
				  ,[prd_nm]
				  ,[prd_cost]
				  ,[prd_line]
				  ,[prd_start_dt]
				  ,[prd_end_dt]
				  )
			SELECT prd_id
				  ,replace(substring(prd_key, 1, 5), '-', '_') as "cat_id"  --extract category id
				  ,substring(prd_key, 7,len(prd_key)) as prd_key --extract product key
				  ,prd_nm
				  ,isnull(prd_cost, 0) as "prd_cost" --changed null values to 0
				  ,case upper(trim(prd_line))
					   when 'M' then 'Mountain'
					   when 'R' then 'Road'                              -- data Naturalization
					   when 'S' then 'Other Sales'
					   when 'T' then 'Touring'
					   else 'n/a'
				  end as prd_line
				  ,cast(prd_start_dt as date)
				  ,dateadd(day, -1, cast(lead(prd_start_dt) over(partition by prd_key order by prd_start_dt) as date)) as "prd_end_dt"  --derived clean end date
			  FROM bronze.crm_prd_info
			  set @end_time = getdate()
				print'>> load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
				print'-------------';



			--loading silver.crm_sales_details
			set @start_time= getdate()
			print'>>> Truncating table: silver.crm_sales_details'
			truncate table silver.crm_sales_details;
			print'>>inserting data into silver.crm_sales_details';
			insert into silver.crm_sales_details (   
				   sls_ord_num
				  ,sls_prd_key
				  ,sls_cust_id
				  ,sls_order_dt
				  ,sls_ship_dt
				  ,sls_due_dt
				  ,sls_sales
				  ,sls_quantity
				  ,sls_price
			)

			SELECT 
				   sls_ord_num
				  ,sls_prd_key
				  ,sls_cust_id
				  ,case when sls_order_dt = 0 or LEN(sls_order_dt) != 8 then null        --handling invalid data with CAST
				   else cast(cast(sls_order_dt as nvarchar)as date) 
				   end as "sls_order_dt"
				  ,case when sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 then null
				   else cast(cast(sls_ship_dt as nvarchar)as date) 
				   end as "sls_ship_dt"
				  ,case when sls_due_dt = 0 or LEN(sls_due_dt) != 8 then null
				   else cast(cast(sls_due_dt as nvarchar)as date) 
				   end as "sls_due_dt"
				  ,case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price)
						then sls_quantity * abs(sls_price)
				   else sls_sales                                                   --handling invalid data
				   end  as "sls_sales",
				   sls_quantity,
				   case when sls_price is null or sls_price <= 0
						then sls_sales/ nullif(sls_quantity, 0)
				   else sls_price 
				   end as "sls_price"

			  FROM bronze.crm_sales_details
			  set @end_time = getdate()
				print'>> load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
				print'-------------';

  




			print'---------------------------------------';
			print'loading ERP Tables';
			print'---------------------------------------';

			--loading silver.erp_cust_az12
			set @start_time= getdate()
			print'>>> Truncating table: silver.erp_cust_az12'
			truncate table silver.erp_cust_az12;
			print'>>inserting data into silver.erp_cust_az12';
			insert into silver.erp_cust_az12(
				cid,
				bdate,
				gen
			)
			select 
				CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))
					ELSE CID                                                     --extracting the id by removing 'NAS"
				END AS "CID",
				CASE WHEN BDATE> GETDATE() THEN NULL
				ELSE BDATE                                                ----identify out of range
				END AS "BDATE",
				case
				when  upper(trim(gen)) in ('M','Male') then 'Male'
				when  upper(trim(gen)) in ('F', 'Female') then 'Female'                   -- Data generalization and handling missing values
				else 'N/A'
			end as "gen"
			from bronze.erp_cust_az12
			set @end_time = getdate()
				print'>> load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
				print'-------------';




			--loading silver.erp_loc_a101
			set @start_time= getdate()
			print'>>> Truncating table: silver.erp_loc_a101'
			truncate table silver.erp_loc_a101;
			print'>>inserting data into silver.erp_loc_a101';
			insert into silver.erp_loc_a101(
				cid,
				cntry
			)
			select 
				replace( cid, '-','') as "cid",  --Handled invalid values
				case	
				when trim(cntry) = 'DE' then 'Germany'
				when trim(cntry) in ('US' , 'USA') then 'United States'
				when trim(cntry) = '' or trim(cntry) is null then 'N/A'
				else trim(cntry)
			end as "cntry"                           --data generalisation, removed unwanted spaces
			from bronze.erp_loc_a101
			set @end_time = getdate()
				print'>> load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
				print'-------------';


			--loading silver.erp_px_cat_g1v2
			set @start_time= getdate()
			print'>>> Truncating table: silver.erp_px_cat_g1v2'
			truncate table silver.erp_px_cat_g1v2;
			print'>>inserting data into silver.erp_px_cat_g1v2';
			insert into silver.erp_px_cat_g1v2(
				id,
				cat,
				subcat,
				maintenance
				)

			select 
			id,
			cat,
			subcat,
			maintenance
			from bronze.erp_px_cat_g1v2
			set @end_time = getdate()
				print'>> load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
				print'-------------';

set @silver_end_time = getdate()
	print'=============================================================';
	print'>> silver load time ' + cast(datediff(second, @silver_start_time, @silver_end_time) as nvarchar) + ' seconds';
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
