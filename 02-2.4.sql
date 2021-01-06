create schema dw;

-- ************************************** shipping
-- creating a table

drop table shipping cascade ;
CREATE TABLE shipping
(
 ship_id   int NOT NULL,
 Ship_Mode varchar(14) NOT NULL,
 CONSTRAINT PK_shipping PRIMARY KEY ( ship_id )
);

--deleting rows
truncate table shipping;

--generating ship_id and inserting ship_mode from orders
insert into shipping 
select 100+row_number() over(), Ship_Mode from (select distinct Ship_Mode from orders ) a;
--checking
select * from shipping sd; 







-- ************************************** customer
drop table customer cascade ;
CREATE TABLE customer
(
 customer_id   int  NOT NULL,
 Customer_Name varchar(30) NOT NULL,
 CONSTRAINT PK_customer PRIMARY KEY ( customer_id )
);

--deleting rows
truncate table customer;
--inserting
insert into customer 
select 100+row_number() over(), customer_id, Customer_Name from (select distinct customer_id, Customer_Name from orders ) a;

--checking
select * from customer cd;  


-- ************************************** geography

drop table geography cascade;
CREATE TABLE geography
(
 geo_id      int NOT NULL,
 Country     varchar(13) NOT NULL,
 City        varchar(17) NOT NULL,
 State       varchar(20) NOT NULL,
 Postal_Code varchar(50),
 Region      varchar(15) NOT NULL,
 CONSTRAINT PK_geography PRIMARY KEY ( geo_id )
);

--deleting rows
truncate table geography;
--generating geo_id and inserting rows from orders
insert into geography 
select 100+row_number() over(), Country, City, State, Postal_Code, Region from (select distinct Country, City, State, Postal_Code, Region from orders ) a;


--data quality check
select distinct Country, City, State, Postal_Code from geography
where Country is null or City is null or Postal_Code is null;

-- City Burlington, Vermont doesn't have postal code
update geography
set postal_code = '05401'
where city = 'Burlington'  and postal_code is null;

--also update source file
update orders
set postal_code = '05401'
where city = 'Burlington'  and postal_code is null;


select * from geography
where city = 'Burlington'


-- ************************************** product
drop table product cascade;
CREATE TABLE product
(
 product_id   varchar(127) NOT NULL,  --exist in ORDERS table
 Category     varchar(127) NOT NULL,
 Sub_Category varchar(127) NOT NULL,
 Segment      varchar(127) NOT NULL,
 product_name varchar(127) NULL,
 CONSTRAINT PK_product PRIMARY KEY ( product_id )
);

--deleting rows
truncate table product;
--
insert into product
select 100+row_number() over () as product_id, Product_Name, category, segment from (select distinct product_id, Product_Name, category, segment from orders ) a;

--checking
select * from product; 



-- ************************************** calendar

--CALENDAR use function instead 
-- examplehttps://tapoueh.org/blog/2017/06/postgresql-and-the-calendar/

--creating a table
drop table calendar cascade ;
CREATE TABLE calendar
(
dateid serial  NOT NULL,
year        int NOT NULL,
quarter     int NOT NULL,
month       int NOT NULL,
week        int NOT NULL,
date        date NOT NULL,
week_day    varchar(20) NOT NULL,
leap  varchar(20) NOT NULL,
CONSTRAINT PK_calendar PRIMARY KEY ( dateid )
);

--deleting rows
truncate table calendar;
--
insert into calendar 
select 
to_char(date,'yyyymmdd')::int as date_id,  
       extract('year' from date)::int as year,
       extract('quarter' from date)::int as quarter,
       extract('month' from date)::int as month,
       extract('week' from date)::int as week,
       date::date,
       to_char(date, 'dy') as week_day,
       extract('day' from
               (date + interval '2 month - 1 day')
              ) = 29
       as leap
  from generate_series(date '2000-01-01',
                       date '2030-01-01',
                       interval '1 day')
       as t(date);
--checking
select * from calendar; 



-- ************************************** sales
drop table sales cascade;
CREATE TABLE sales
(
 row_id      int4range NOT NULL,
 order_id    varchar(14) NOT NULL,
 sales       numeric(9,4) NOT NULL,
 quantity    int4range NOT NULL,
 discount    numeric(4,2) NOT NULL,
 profit      numeric(21,16) NOT NULL,
 geo_id    int NOT NULL,
 ship_date   date NOT NULL,
 product_id  varchar(127) NOT NULL,
 ship_id     int NOT NULL,
 customer_id int NOT NULL,
 CONSTRAINT PK_sales PRIMARY KEY ( row_id ),
 CONSTRAINT FK_129 FOREIGN KEY ( geo_id ) REFERENCES geography ( geo_id ),
 CONSTRAINT FK_139 FOREIGN KEY ( product_id ) REFERENCES product ( product_id ),
 CONSTRAINT FK_142 FOREIGN KEY ( ship_id ) REFERENCES shipping ( ship_id ),
 CONSTRAINT FK_145 FOREIGN KEY ( customer_id ) REFERENCES customer ( customer_id )
);

CREATE INDEX fkIdx_130 ON sales
(
 geo_id
);

CREATE INDEX fkIdx_140 ON sales
(
 product_id
);

CREATE INDEX fkIdx_143 ON sales
(
 ship_id
);

CREATE INDEX fkIdx_146 ON sales
(
 customer_id
);


