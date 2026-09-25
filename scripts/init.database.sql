/*
creating databases and schema

this script is to create a database called DNSuperstore nd it adds 3 schemas within the database called "gold", "silver", and "bronze"

*/



-- creating DN Superstore Data Warehouse

use master;
go

--creating database
create database DNSuperstore;

use DNSuperstore;

--creating schemas
create schema bronze;
go
create schema silver;
go
create schema gold;
go
