/*
===================================================================
Quality Checks 
===================================================================
Script Purpose:
This script performs various checks on the data once it is loaded to ensure data consistency, accuracy, and standardization
across the silver layer

it checks for
-- Nulls or duplicate primary keys
-- Unwanted spaces
-- Data standardization
-- Invalid date ranges
-- Data consistency between fields

run these checks after loading data into Silver Layer
*/

--=================================
-- checking for silver.crm_cust_info
--=================================

--check for nulls in primary key (cust_id)
select 
	cst_id,
	count (*)
from silver.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null


-- deleting duplicates
select *
from(

	select 
		*,
		ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_no
	from bronze.crm_cust_info
	)t 
where flag_no = 1


--check for unwanted spaces
select 
	cst_lastname
from silver.crm_cust_info
where cst_lastname != trim(cst_lastname)

--standardidation
select distinct cst_gndr
from silver.crm_cust_info


select count (*)
from silver.crm_cust_info





--=================================
-- checking for silver.crm_cust_info
--=================================

--check for nulls in primary key (prd_id)
select 
	prd_id,
	count (*)
from silver.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null

--check for nulls or negative numbers in prd_cost
select
	prd_cost,
	count (*)
from silver.crm_prd_info
group by prd_cost
having prd_cost <0 or prd_cost is null

-- deleting duplicates
select *
from(

	select 
		*,
		ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_no
	from bronze.crm_cust_info
	)t 
where flag_no = 1


--check for unwanted spaces
select 
	prd_nm
from silver.crm_prd_info
where prd_nm != trim(prd_nm)

--standardidation
select distinct prd_line
from silver.crm_prd_info


select *
from silver.crm_prd_info



--=================================
-- checking for crm_sales_details
--=================================
select 
nullif(sls_due_dt,0) 
from silver.crm_sales_details
where sls_due_dt is null 
or len(sls_due_dt) != 8
or sls_due_dt >'2050-01-01'
or sls_due_dt < '1900-01-01'

--check for invalid date orders
select *
from silver.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

--applying business rules
select distinct
	sls_sales,
	sls_quantity,
	sls_price as old_sls_price,
	case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * abs(sls_price)
			then sls_quantity * abs(sls_price)
	else sls_sales
	end  as "sls_sales",
	case when sls_price is null or sls_price <= 0
			then sls_sales/ nullif(sls_quantity, 0)
	else sls_price 
	end as "sls_price"
from silver.crm_sales_details






--=================================
-- checking for erp_cust_az12
--=================================

--extracting the id
select
	CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))
		ELSE CID
	END AS "CID"
from silver.erp_cust_az12
	
--identify out of range
select
	bdate
from silver.erp_cust_az12
where bdate < '1924-01-01' or bdate > getdate()

--check distinct values in gender
select distinct
gen,
case
	when  upper(trim(gen)) in ('M','Male') then 'Male'
	when  upper(trim(gen)) in ('F', 'Female') then 'Female'
	else 'N/A'
end as "gen"
from silver.erp_cust_az12





--=================================
-- checking for erp_loc_a101
--=================================

--replace - with nothing
select 
	cid,
	replace( cid, '-','') as "cid"
from bronze.erp_loc_a101 
where replace( cid, '-','') not in (select cst_key from silver.crm_cust_info)

--standardization
select distinct
CNTRY,
case	
	when trim(cntry) = 'DE' then 'Germany'
	when trim(cntry) in ('US' , 'USA') then 'United States'
	when trim(cntry) = '' or trim(cntry) is null then 'N/A'
	else trim(cntry)
end as "cntry"
from bronze.erp_loc_a101 





--=================================
-- checking for erp_px_cat_g1v2
--=================================
-- checking for unwanted spaces
select * from bronze.erp_px_cat_g1v2
where cat != trim(cat) or SUBCAT != trim(SUBCAT) or maintenance != trim(maintenance)

--data standardization
select distinct
cat
from bronze.erp_px_cat_g1v2
