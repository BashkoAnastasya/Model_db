INSERT INTO t_supplier VALUES (1,'IP Frilov','Frilov I I');
INSERT INTO t_supplier VALUES (2,'IP Popov','Popov I I ');
INSERT INTO t_supplier VALUES (3,'IP Berilov','Berilov I I');

INSERT INTO t_state VALUES (1,'Draft');
INSERT INTO t_state VALUES  (2,'Fulfilled');

INSERT INTO t_supply (id_supply, code, dt, id_supplier,id_state) VALUES  (1,'DB17',DATE'2018-08-14',1,1);
INSERT INTO t_supply (id_supply, code, dt, id_supplier,id_state) VALUES  (2,'DB18',DATE'2018-08-15',2,1);
INSERT INTO t_supply (id_supply, code, dt, id_supplier,id_state) VALUES  (3,'DB19',DATE'2018-08-16',3,1);

INSERT INTO t_ctl_node VALUES (1,'','78ds','45','Baths');
INSERT INTO t_ctl_node VALUES (2,1,'sdf5','12','Acrylic Baths');
INSERT INTO t_ctl_node VALUES (3,1,'sdf5','14','Steel Baths');
INSERT INTO t_ctl_node VALUES (4,1,'sdf5','16','Bath screens');

INSERT INTO t_model (id_model,moniker,name,id_ctl_node,grp,subgrp,label,price) VALUES (1,'GDj458','Cerazit',2,'Cerazit 258','Cerazit','fd',1);
INSERT INTO t_model (id_model,moniker,name,id_ctl_node,grp,subgrp,label,price) VALUES (2,'JFDJ','Armaruta',3,'Armaruta 258','Armaruta','rt',2);
INSERT INTO t_model (id_model,moniker,name,id_ctl_node,grp,subgrp,label,price) VALUES (3,'REFDS','Braun',4,'Braun 258','Braun','eret',3);

INSERT INTO t_price_model (id_price_model,id_model,dt_beg,dt_end,price) VALUES (1,1,DATE'2017-08-14',DATE'2019-08-14',10);
INSERT INTO t_price_model (id_price_model,id_model,dt_beg,dt_end,price) VALUES (2,2,DATE'2016-05-14',DATE'2019-05-14',888);
INSERT INTO t_price_model (id_price_model,id_model,dt_beg,dt_end,price) VALUES (3,3,DATE'2015-03-14',DATE'2019-05-14',1212);

INSERT INTO t_ware (id_ware,moniker,name,id_model,sz_orig,sz_rus) VALUES (1,'Bath Armaruta25','Armaruta25',2,'dfsd','fasf');
INSERT INTO t_ware (id_ware,moniker,name,id_model,sz_orig,sz_rus) VALUES (2,'Bath Armaruta26','Armaruta26',2,'sfsd','sdfas');
INSERT INTO t_ware (id_ware,moniker,name,id_model,sz_orig,sz_rus) VALUES (3,'Bath Steel','Steel1',3,'gfsdfg','df');

INSERT INTO t_price_ware (id_price_ware,id_ware,dt_beg,dt_end,price) VALUES (sec_t_price_ware.nextval,1,DATE'2018-08-15',NULL,18);
INSERT INTO t_price_ware (id_price_ware,id_ware,dt_beg,dt_end,price) VALUES (sec_t_price_ware.nextval,2,DATE'2018-08-15',NULL,15);
INSERT INTO t_price_ware (id_price_ware,id_ware,dt_beg,dt_end,price) VALUES (sec_t_price_ware.nextval,3,DATE'2018-08-15',NULL,7);

INSERT INTO t_supply_str (id_supply_str, id_supply, num, id_ware, qty, price) VALUES  (1, 1, 1, 1, 2, 20);
INSERT INTO t_supply_str (id_supply_str, id_supply, num, id_ware, qty, price) VALUES  (2, 1, 2, 2, 4, 5);
INSERT INTO t_supply_str (id_supply_str, id_supply, num, id_ware, qty, price) VALUES  (3, 1, 3, 3, 10, 6);

INSERT INTO t_dept (id_dept,name,id_parent) VALUES (1,'Global',NULL);
INSERT INTO t_dept (id_dept,name,id_parent) VALUES (2,'Vip',1);
INSERT INTO t_dept (id_dept,name,id_parent) VALUES (3,'MNDfn',1);

INSERT INTO t_client (id_client,id_dept,moniker,name,is_vip,town) VALUES(1,2,'Ivanov','Ivanov i i', 'Y', 'Grodno');
INSERT INTO t_client (id_client,id_dept,moniker,name,is_vip,town) VALUES(2,3,'Sidorov','Sidorov i i', 'N', 'Grodno');
INSERT INTO t_client (id_client,id_dept,moniker,name,is_vip,town) VALUES(3,3,'Petrov','Petrov i i', 'N', 'Grodno');


INSERT INTO t_sale (id_sale,num,dt,id_client,id_state,discount) VALUES (1,1,DATE'2018-08-18',1,1,10);
INSERT INTO t_sale (id_sale,num,dt,id_client,id_state,discount) VALUES (2,2,DATE'2018-08-19',2,1,10);
INSERT INTO t_sale (id_sale,num,dt,id_client,id_state,discount) VALUES (3,1,DATE'2018-08-20',3,1,10);

INSERT INTO t_sale_str (id_sale_str,id_sale,num,id_ware,qty,discount) VALUES(1,1,1,1,1,2);
INSERT INTO t_sale_str (id_sale_str,id_sale,num,id_ware,qty,discount) VALUES(2,1,2,2,2,2);
INSERT INTO t_sale_str (id_sale_str,id_sale,num,id_ware,qty,discount) VALUES(3,1,3,3,3,2);
INSERT INTO t_sale_str (id_sale_str,id_sale,num,id_ware,qty,discount) VALUES(4,3,4,3,1,2);



















