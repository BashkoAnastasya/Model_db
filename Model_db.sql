/*  drop table t_ware;
  drop table t_price_ware;
  drop table t_supplier;
  drop table t_supply;
  drop table t_supply_str;
  drop table t_model;
  drop table t_prace_model;
  drop table t_ctl_node;*/
  
  --поставщик
  CREATE TABLE t_supplier 
  (
  id_supplier   number not null,
  moniker varchar2(254),
  name varchar2(254)
  );
  create index IXPK_id_supplier on t_supplier(id_supplier) ;      
  alter table t_supplier
  add constraint PK_id_supplier primary key (id_supplier) using index IXPK_id_supplier;      
  alter table t_supplier
  add constraint t_supplier_unique UNIQUE (moniker);
      
  --поставка
  CREATE TABLE t_supply
  (
  id_supply   number not null,
  code varchar2(30),
  num varchar2(30),
  dt date,
  id_supplier  number not null,
  --e_state  enum,
  summa number(14,2),
  nds number(14,2)
  );     
  create index IXPK_id_supply on t_supply(id_supply) ;   
  alter table t_supply
  add constraint PK_id_supply primary key (id_supply) using index IXPK_id_supply
  add constraint  FK_id_supplier foreign key (id_supplier) references  t_supplier(id_supplier);
    
  --узел каталога
  CREATE TABLE t_ctl_node
  (
  id_ctl_node   number not null,
  id_parent number not null,
  code varchar2(12),
  tree_code varchar2(240),
  name varchar2(254)
  );
  create index IXPK_id_ctl_node on t_ctl_node(id_ctl_node);
  alter table t_ctl_node
  add constraint PK_id_ctl_node primary key (id_ctl_node) using index IXPK_id_ctl_node;
      
  --модель 
  CREATE TABLE t_model
  (
  id_model   number not null,
  moniker varchar2(12),
  name varchar2(254),
  id_ctl_node   number not null,
  grp varchar2(254),
  subgrp varchar2(254),
  label varchar2(254),
  price number(8,2)    
  );
  create index IXPK_id_model on t_model(id_model);
  alter table t_model
  add constraint PK_id_model primary key (id_model) using index IXPK_id_model
  add constraint FK_id_ctl_node foreign key(id_ctl_node)  references t_ctl_node (id_ctl_node);
         
  -- цена модели
  CREATE TABLE t_prace_model
  (
  id_prace_model number not null,
  id_model   number not null,
  dt_beg date,
  dt_end date,
  price  number(8,2)   
  );
  create index IX_id_prace_model on t_prace_model(id_prace_model);
  alter table t_prace_model 
  add constraint FK_id_model foreign key (id_model) references t_model(id_model);
   
  --товар
  CREATE TABLE t_ware
  (
  id_ware number not null,
  moniker varchar2(12),
  name varchar2 (254),
  id_model number not null,
  sz_orig varchar2(30),
  sz_rus varchar2(30),
  price number(8,2)
  );
  create index IXPK_id_ware on t_ware(id_ware);
  alter table t_ware
  add constraint PK_id_ware primary key (id_ware) using index IXPK_id_ware
  add constraint FK_id_model_ware foreign key (id_model) references t_model(id_model);
    
  --цена товара
  CREATE TABLE t_price_ware
  (
  id_price_ware number not null,
  id_ware   number not null,
  dt_beg date not null,
  dt_end date,
  price number(8,2)
  );
  create index IX_id_price_ware on t_price_ware(id_price_ware);
  alter table t_price_ware
  add constraint FK_id_ware foreign key (id_ware) references t_ware(id_ware);
  
   --строка поставки
  CREATE TABLE t_supply_str
  (
  id_supply_str   number not null,
  id_supply number not null,
  numa number(6),
  id_ware number not null,
  qty number(6),  
  summa number(14,2),
  nds number(14,2)
  );
  create index IXPK_id_supply_str on t_supply_str(id_supply_str);
  alter table t_supply_str
  add constraint PK_id_supply_str primary key (id_supply_str) using index IXPK_id_supply_str
  add constraint FK_id_supply foreign key (id_supply) references  t_supply(id_supply)
  add constraint FK_id_ware_str foreign key (id_ware) references t_ware(id_ware) ;
      
      
      
      
      
      
      
