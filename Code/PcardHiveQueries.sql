*******************************************************************************************************************************************************************
FRADULENT TEST CASES

Table Creation
DROP TABLE IF EXISTS pcard;
CREATE EXTERNAL TABLE pcard(year_month STRING,
agency_number STRING,
agency_name STRING,
latitude FLOAT,
longitude FLOAT,
cardholder_last_name STRING,
cardholder_first_initial STRING,
description STRING,
amount FLOAT,
vendor STRING,
transaction_full_date STRING,
transaction_month STRING,
transaction_day STRING,
transaction_date INT,
tansaction_year INT,
posted_date_full STRING,
posted_day STRING,
posted_month STRING,
posted_date INT,
posted_year INT,
merchant_category_code STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
STORED AS TEXTFILE LOCATION 'wasb://alishapaul-4@alishapaul.blob.core.windows.net/DATA/';

Duplicate Entries Query
DROP TABLE IF EXISTS DuplicateEnties;
CREATE TABLE IF NOT EXISTS DuplicateEnties(Fullname STRING, amount FLOAT, transaction_full_date Date,vendor STRING, vendorcnt INT );
INSERT OVERWRITE TABLE DuplicateEnties
SELECT CONCAT_WS(", ", cardholder_first_initial, cardholder_last_name) as Fullname, amount,transaction_full_date, vendor,count(vendor) as vendorcnt
FROM pcard where amount is not null and cardholder_last_name is not null and vendor is not null and transaction_full_date is not null
GROUP BY CONCAT_WS(", ", cardholder_first_initial, cardholder_last_name),vendor,amount,transaction_full_date having vendorcnt>1 order by vendorcnt desc LIMIT 50;

NO Description 
SELECT agency_name FROM pcard where description is null

Round amount Transactions:
DROP TABLE IF EXISTS roundTransactions;
CREATE TABLE IF NOT EXISTS roundTransactions(Fullname STRING, amount FLOAT, transaction_full_date Date,vendor STRING, vendorcnt INT );
INSERT OVERWRITE TABLE roundTransactions
select agency_name,CONCAT_WS(", ", cardholder_first_initial, cardholder_last_name) as Fullname,description,amount,vendor,transaction_full_date,merchant_category_code from pcard where amount=round(amount,0) and agency_name is not null and cardholder_last_name is not null and cardholder_first_initial is not null and description is not null and amount is not null and vendor is not null and transaction_full_date is not null and merchant_category_code is not null ORDER BY amount desc LIMIT 50;

Weekend Transactions by Vendor and AMount
DROP TABLE IF EXISTS weekendtransactions;
CREATE TABLE IF NOT EXISTS weekendtransactions(vendor STRING, amount FLOAT,vendorcnt INT);
INSERT OVERWRITE TABLE weekendtransactions
select vendor,amount,count(vendor) as vendorcnt from pcard where transaction_day in ('Saturday','Sunday') GROUP by vendor,amount having vendorcnt>1 order by amount desc

By Vendor By amount Count on Public holiday
DROP TABLE IF EXISTS publicHolidaytrans;
CREATE TABLE IF NOT EXISTS publicHolidaytrans(vendor STRING, amount FLOAT,vendorcnt INT,transaction_full_date DATE);
INSERT OVERWRITE TABLE publicHolidaytrans
select vendor,amount,count(vendor) as vendorcnt,transaction_full_date from pcard where transaction_full_date in ('2015-01-01','2015-01-19','2015-02-16','2015-04-03','2015-05-25','2015-07-03','2015-07-04','2015-09-07','2015-10-12','2015-11-11','2015-11-26','2015-12-25','2014-01-01','2014-01-20','2014-02-17','2014-04-18','2014-05-26','2014-07-04','2014-09-01','2014-10-13','2014-11-11','2014-11-27','2014-12-25') GROUP by vendor,amount,transaction_full_date having vendorcnt>1 order by vendorcnt desc

Monthly Transaction by Vendor
DROP TABLE IF EXISTS monthlytrans;
CREATE TABLE IF NOT EXISTS monthlytrans(vendor STRING, amount FLOAT,vendorcnt INT,transaction_full_date DATE);
INSERT OVERWRITE TABLE monthlytrans
select agency_name,vendor,tansaction_year,transaction_month,count(amount) as TranCount from pcard group by agency_name,vendor,tansaction_year,transaction_month having TranCount>1 ORDER BY TranCount desc;


top targetted agencies for fraud
DROP TABLE IF EXISTS agencyamt;
CREATE TABLE IF NOT EXISTS agencyamt(agency_name STRING, amount FLOAT);
INSERT OVERWRITE TABLE agencyamt
SELECT agency_name, sum(amount)
FROM pcard
GROUP BY agency_name;

top targetted vendors for fraud
DROP TABLE IF EXISTS vendoramt;
CREATE TABLE IF NOT EXISTS vendoramt(vendor STRING, amount FLOAT);
INSERT OVERWRITE TABLE vendoramt
SELECT vendor, sum(amount)
FROM pcard
GROUP BY vendor;

Top 25 Spenders Category wise during Month-End Audit Hit List
DROP TABLE IF EXISTS monthendTrans;
CREATE TABLE IF NOT EXISTS monthendTrans(vendor STRING, amount FLOAT);
INSERT OVERWRITE TABLE monthendTrans
select sum(amount) as TOTAL,merchant_category_code,CONCAT_WS(", ", cardholder_first_initial, cardholder_last_name) as Fullname from pcard where transaction_date>27 and amount is not NULL group by merchant_category_code,cardholder_last_name,cardholder_first_initial ORDER BY TOTAL desc LIMIT 25;

*****************************************************************************************************************************************************************