/*  drop table t_ware;  
  drop table t_supply;
  drop table t_supply_str;
  drop table t_model;
  drop table t_price_model;
  drop table t_ctl_node;
  drop table t_supplier; 
  drop table t_price_ware;
  drop table  t_dept;
  drop table t_client;
  drop table t_sale;
  drop table t_state;*/
  

  CREATE TABLE t_supplier 
  (
  id_supplier  number not null,
  moniker varchar2(254),
  name varchar2(254),
  constraint pk_id_supplier PRIMARY KEY (id_supplier),
  constraint t_supplier_unique UNIQUE (moniker)
  );
  

  CREATE TABLE t_state
  (
  id_state number not null,
  name_state varchar2(40),
  constraint pk_id_state primary key (id_state)
  );
  

  CREATE TABLE t_supply
  (
  id_supply   number not null,
  code varchar2(30),
  num varchar2(30),
  dt date,
  id_supplier  number not null,
  id_state  number not null,
  summa number(14,2),
  nds number(14,2),
  constraint PK_id_supply primary key (id_supply),
  constraint FK_id_supplier foreign key (id_supplier) references  t_supplier(id_supplier),
  constraint FK_id_state foreign key (id_state) references t_state(id_state)
  );     
       

  CREATE TABLE t_ctl_node
  (
  id_ctl_node  number not null,
  id_parent number,
  code varchar2(12),
  tree_code varchar2(240),
  name varchar2(254),
  constraint PK_id_ctl_node primary key (id_ctl_node),
  constraint FK_id_parent foreign key (id_parent) references t_ctl_node(id_ctl_node)   
  );
      

  CREATE TABLE t_model
  (
  id_model   number not null,
  moniker varchar2(12),
  name varchar2(254),
  id_ctl_node   number not null,
  grp varchar2(254),
  subgrp varchar2(254),
  label varchar2(254),
  price number(8,2),    
  constraint PK_id_model primary key (id_model),
  constraint FK_id_ctl_node foreign key(id_ctl_node)  references t_ctl_node (id_ctl_node)
  );
    

  CREATE TABLE t_price_model
  (
  id_price_model number not null,
  id_model   number not null,
  dt_beg date,
  dt_end date,
  price  number(8,2),
  constraint FK_id_model foreign key (id_model)references t_model(id_model)  
  );
  create index IX_id_price_model on t_price_model(id_price_model);
    

  CREATE TABLE t_ware
  (
  id_ware number not null,
  moniker varchar2(12),
  name varchar2 (254),
  id_model number not null,
  sz_orig varchar2(30),
  sz_rus varchar2(30),
  price number(8,2),
  constraint PK_id_ware primary key (id_ware),
  constraint FK_id_model_ware foreign key (id_model) references t_model(id_model)
  );
    

  CREATE TABLE t_price_ware
  (
  id_price_ware number not null,
  id_ware   number not null,
  dt_beg date not null,
  dt_end date,
  price number(8,2),
  constraint FK_id_ware foreign key (id_ware) references t_ware(id_ware)
  );
  create index IX_id_price_ware on t_price_ware(id_price_ware);



  CREATE TABLE t_supply_str
  (
  id_supply_str   number not null,
  id_supply number not null,
  num number(6),
  id_ware number not null,
  qty number(6),  
  price number (8,2),
  summa number(14,2),
  nds number(14,2),
  constraint PK_id_supply_str primary key (id_supply_str),
  constraint FK_id_supply foreign key (id_supply) references  t_supply(id_supply),
  constraint FK_id_ware_str foreign key (id_ware) references t_ware(id_ware)
  );
  
 
  create table t_dept
  (
  id_dept number  not null,
  name  varchar2(254),
  id_parent number, 
  constraint PK_id_dept primary key (id_dept), 
  constraint FK_id_parent_dept foreign key (id_parent) references t_dept (id_dept)
  );
  
  
  create table t_client
  (
  id_client number  not null,
  id_dept number  not null,
  moniker varchar2(254),
  name varchar2(254),
  is_vip char(1) check (is_vip in ('Y','N')),
  town varchar2(254),
  constraint PK_id_client primary key (id_client),
  constraint FK_id_dept_client foreign key (id_dept) references t_dept (id_dept),
  constraint t_client_unique UNIQUE (moniker)
  );
  
 
  create table t_sale
  (
  id_sale number  not null,
  num varchar2(30),
  dt date,
  id_client number  not null, 
  id_state number  not null,
  discount number (8,6),
  summa number(14,2),
  nds number (14,2),
  constraint PK_id_sale primary key (id_sale),
  constraint FK_id_client foreign key (id_client) references t_client(id_client),
  constraint FK_id_state_sale foreign key (id_state) references t_state(id_state)
  );
  
 
  create table t_sale_str
  (
  id_sale_str number  not null,
  id_sale number  not null,
  num number(6),
  id_ware number  not null,
  qty number(6),
  price number(8,2), 
  discount number (8,6), 
  disc_price number (8,2),
  summa number (14,2), 
  nds number (14,2),
  constraint PK_id_sale_str primary key (id_sale_str),
  constraint FK_id_sale foreign key (id_sale) references t_sale(id_sale),
  constraint FK_id_ware_sale foreign key (id_ware) references t_ware(id_ware)  
  );
  
  create table t_rest
  (
  id_t_rest number is not null
  id_ware number is not null,
  qty number(6)    
  );
  

  
  
  

 
      
      
      
      
      
      
      
