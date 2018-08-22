/*  DROP TABLE t_supply_str;
  DROP TABLE t_sale_str;
  DROP TABLE t_price_ware;
  DROP TABLE t_price_model;  
  DROP TABLE t_rest;
  DROP TABLE t_ware;  
  DROP TABLE t_supply;  
  DROP TABLE t_supplier; 
  DROP TABLE t_model;
  DROP TABLE t_sale; 
  DROP TABLE t_client;
  DROP TABLE t_ctl_node;
  DROP TABLE t_dept;
  DROP TABLE t_state;
  DROP PROCEDURE add_t_price;
  DROP PROCEDURE change_rest_table;
  DROP PROCEDURE test_supply_summa;
  DROP TRIGGER change_t_price_ware;
  DROP TRIGGER change_t_rest_sale;
  DROP TRIGGER change_t_rest_supply;
  DROP TRIGGER t_summa_sale_after;
  DROP TRIGGER t_summa_sale_before;
  DROP TRIGGER t_summa_sale_str_after;
  DROP TRIGGER t_summa_sale_str_before;
  DROP TRIGGER t_summa_t_supply;
  DROP TRIGGER t_summa_t_supply_str;
  DROP PACKAGE pkg_around_mutation;*/
  
  CREATE TABLE t_supplier 
  (
  id_supplier  NUMBER NOT NULL,
  moniker VARCHAR2(254),
  name VARCHAR2(254),
  CONSTRAINT pk_id_supplier PRIMARY KEY (id_supplier),
  CONSTRAINT t_supplier_unique UNIQUE (moniker)
  );
  

  CREATE TABLE t_state
  (
  id_state NUMBER NOT NULL,
  name_state VARCHAR2(40),
  CONSTRAINT pk_id_state PRIMARY KEY (id_state)
  );
  

  CREATE TABLE t_supply
  (
  id_supply   NUMBER NOT NULL,
  code VARCHAR2(30),
  num VARCHAR2(30),
  dt DATE,
  id_supplier  NUMBER NOT NULL,
  id_state  NUMBER NOT NULL,
  summa NUMBER (14,2),
  nds NUMBER (14,2),
  CONSTRAINT pk_id_supply PRIMARY KEY (id_supply),
  CONSTRAINT fk_id_supplier FOREIGN KEY (id_supplier) REFERENCES  t_supplier(id_supplier),
  CONSTRAINT fk_id_state FOREIGN KEY (id_state) REFERENCES t_state(id_state)
  );     
       

  CREATE TABLE t_ctl_node
  (
  id_ctl_node  NUMBER NOT NULL,
  id_parent NUMBER,
  code VARCHAR2(12),
  tree_code VARCHAR2(240),
  name VARCHAR2(254),
  CONSTRAINT pk_id_ctl_node PRIMARY KEY (id_ctl_node),
  CONSTRAINT fk_id_parent FOREIGN KEY (id_parent) REFERENCES t_ctl_node(id_ctl_node)   
  );
      

  CREATE TABLE t_model
  (
  id_model   NUMBER NOT NULL,
  moniker VARCHAR2(12),
  name VARCHAR2(254),
  id_ctl_node   NUMBER NOT NULL,
  grp VARCHAR2(254),
  subgrp VARCHAR2(254),
  label VARCHAR2(254),
  price NUMBER(8,2),    
  CONSTRAINT pk_id_model PRIMARY KEY (id_model),
  CONSTRAINT fk_id_ctl_node FOREIGN KEY(id_ctl_node)  REFERENCES t_ctl_node (id_ctl_node)
  );
    

  CREATE TABLE t_price_model
  (
  id_price_model NUMBER NOT NULL,
  id_model   NUMBER NOT NULL,
  dt_beg DATE,
  dt_end DATE,
  price  NUMBER(8,2),
  CONSTRAINT fk_id_model FOREIGN KEY (id_model)REFERENCES t_model(id_model)  
  );
  CREATE INDEX ix_id_price_model on t_price_model(id_price_model);
    

  CREATE TABLE t_ware
  (
  id_ware NUMBER NOT NULL,
  moniker VARCHAR2(12),
  name VARCHAR2 (254),
  id_model NUMBER NOT NULL,
  sz_orig VARCHAR2(30),
  sz_rus VARCHAR2(30),
  price NUMBER(8,2),
  CONSTRAINT pk_id_ware PRIMARY KEY (id_ware),
  CONSTRAINT fk_id_model_ware FOREIGN KEY (id_model) REFERENCES t_model(id_model)
  );
    

  CREATE TABLE t_price_ware
  (
  id_price_ware NUMBER NOT NULL,
  id_ware   NUMBER NOT NULL,
  dt_beg DATE NOT NULL,
  dt_end DATE,
  price NUMBER(8,2),
  CONSTRAINT fk_id_ware FOREIGN KEY (id_ware) REFERENCES t_ware(id_ware)
  );
  CREATE INDEX ix_id_price_ware on t_price_ware(id_price_ware);



  CREATE TABLE t_supply_str
  (
  id_supply_str   NUMBER NOT NULL,
  id_supply NUMBER NOT NULL,
  num NUMBER(6),
  id_ware NUMBER NOT NULL,
  qty NUMBER(6),  
  price NUMBER (8,2),
  summa NUMBER (14,2),
  nds NUMBER(14,2),
  CONSTRAINT pk_id_supply_str PRIMARY KEY (id_supply_str),
  CONSTRAINT fk_id_supply FOREIGN KEY (id_supply) REFERENCES  t_supply(id_supply),
  CONSTRAINT fk_id_ware_str FOREIGN KEY (id_ware) REFERENCES t_ware(id_ware)
  );
  
 
  CREATE TABLE t_dept
  (
  id_dept NUMBER NOT NULL,
  name  VARCHAR2(254),
  id_parent NUMBER, 
  CONSTRAINT pk_id_dept PRIMARY KEY (id_dept), 
  CONSTRAINT fk_id_parent_dept FOREIGN KEY (id_parent) REFERENCES t_dept (id_dept)
  );
  
  
  CREATE TABLE t_client
  (
  id_client NUMBER NOT NULL,
  id_dept NUMBER NOT NULL,
  moniker VARCHAR2(254),
  name VARCHAR2(254),
  is_vip CHAR(1) CHECK (is_vip in ('Y','N')),
  town VARCHAR2(254),
  CONSTRAINT pk_id_client PRIMARY KEY (id_client),
  CONSTRAINT fk_id_dept_client FOREIGN KEY (id_dept) REFERENCES t_dept (id_dept),
  CONSTRAINT t_client_unique UNIQUE (moniker)
  );
  
 
  CREATE TABLE t_sale
  (
  id_sale NUMBER NOT NULL,
  num VARCHAR2(30),
  dt DATE,
  id_client NUMBER NOT NULL, 
  id_state NUMBER NOT NULL,
  discount NUMBER (8,6),
  summa NUMBER(14,2),
  nds NUMBER (14,2),
  CONSTRAINT pk_id_sale PRIMARY KEY (id_sale),
  CONSTRAINT fk_id_client FOREIGN KEY (id_client) REFERENCES t_client(id_client),
  CONSTRAINT fk_id_state_sale FOREIGN KEY (id_state) REFERENCES t_state(id_state)
  );
  
 
  CREATE TABLE t_sale_str
  (
  id_sale_str NUMBER NOT NULL,
  id_sale NUMBER NOT NULL,
  num NUMBER(6),
  id_ware NUMBER NOT NULL,
  qty NUMBER(6),
  price NUMBER(8,2), 
  discount NUMBER (8,6), 
  disc_price NUMBER (8,2),
  summa NUMBER (14,2), 
  nds NUMBER (14,2),
  CONSTRAINT pk_id_sale_str PRIMARY KEY (id_sale_str),
  CONSTRAINT fk_id_sale FOREIGN KEY (id_sale) REFERENCES t_sale(id_sale),
  CONSTRAINT fk_id_ware_sale FOREIGN KEY (id_ware) REFERENCES t_ware(id_ware)  
  );
  
  CREATE TABLE t_rest
  (
  id_ware NUMBER NOT NULL,
  qty NUMBER(6),
  CONSTRAINT fk_id_ware_rest FOREIGN KEY (id_ware) REFERENCES t_ware(id_ware)    
  );
  

  
  
  

 
      
      
      
      
      
      
      
