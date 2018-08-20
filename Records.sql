insert into t_supplier VALUES (1,'IP Frilov','Frilov I I');
insert into t_supplier VALUES (2,'IP Popov','Popov I I ');
insert into t_supplier VALUES (3,'IP Berilov','Berilov I I');

insert into t_state VALUES (1,'Draft');
insert into t_state values  (2,'Fulfilled');

insert into t_supply (id_supply, code, dt, id_supplier,id_state) values  (1,'DB17',DATE'2018-08-14',1,2);
insert into t_supply (id_supply, code, dt, id_supplier,id_state) values  (2,'DB18',DATE'2018-08-15',2,1);
insert into t_supply (id_supply, code, dt, id_supplier,id_state) values  (3,'DB19',DATE'2018-08-16',3,1);

insert into t_ctl_node values (1,'','78ds','45','Baths');
insert into t_ctl_node values (2,1,'sdf5','12','Acrylic Baths');
insert into t_ctl_node values (3,1,'sdf5','14','Steel Baths');
insert into t_ctl_node values (4,1,'sdf5','16','Bath screens');

insert into t_model (id_model,moniker,name,id_ctl_node,grp,subgrp,label,price) values (1,'GDj458','Cerazit',2,'Cerazit 258','Cerazit','fd',1);
insert into t_model (id_model,moniker,name,id_ctl_node,grp,subgrp,label,price) values (2,'JFDJ','Armaruta',3,'Armaruta 258','Armaruta','rt',2);
insert into t_model (id_model,moniker,name,id_ctl_node,grp,subgrp,label,price) values (3,'REFDS','Braun',4,'Braun 258','Braun','eret',3);

insert into t_price_model (id_price_model,id_model,dt_beg,dt_end,price) values (1,1,DATE'2017-08-14',DATE'2019-08-14',10);
insert into t_price_model (id_price_model,id_model,dt_beg,dt_end,price) values (2,2,DATE'2016-05-14',DATE'2019-05-14',888);
insert into t_price_model (id_price_model,id_model,dt_beg,dt_end,price) values (3,3,DATE'2015-03-14',DATE'2019-05-14',1212);

insert into t_ware (id_ware,moniker,name,id_model,sz_orig,sz_rus) values (1,'Armaruta25','Armaruta25',2,'dfsd','fasf');
insert into t_ware (id_ware,moniker,name,id_model,sz_orig,sz_rus) values (2,'Armaruta26','Armaruta26',2,'sfsd','sdfas');
insert into t_ware (id_ware,moniker,name,id_model,sz_orig,sz_rus) values (3,'Steel','Steel1',3,'gfsdfg','df');

insert into t_supply_str (id_supply_str, id_supply, num, id_ware, qty, price) values  (1, 1, 1, 1, 2, 20);
insert into t_supply_str (id_supply_str, id_supply, num, id_ware, qty, price) values  (2, 1, 2, 2, 4, 5);
insert into t_supply_str (id_supply_str, id_supply, num, id_ware, qty, price) values  (3, 1, 3, 3, 10, 6);

insert into t_dept (id_dept,name,id_parent) values (1,'Global',Null);
insert into t_dept (id_dept,name,id_parent) values (2,'Vip',1);
insert into t_dept (id_dept,name,id_parent) values (3,'MNDfn',1);

insert into t_client (id_client,id_dept,moniker,name,is_vip,town) values(1,2,'Ivanov','Ivanov i i', 'Y', 'Grodno');
insert into t_client (id_client,id_dept,moniker,name,is_vip,town) values(2,3,'Sidorov','Sidorov i i', 'N', 'Grodno');
insert into t_client (id_client,id_dept,moniker,name,is_vip,town) values(3,3,'Petrov','Petrov i i', 'N', 'Grodno');


insert into t_sale (id_sale,num,dt,id_client,id_state,discount) values (1,1,DATE'2018-08-18',1,1,10);
insert into t_sale (id_sale,num,dt,id_client,id_state,discount) values (2,2,DATE'2018-08-19',2,1,10);
insert into t_sale (id_sale,num,dt,id_client,id_state,discount) values (3,1,DATE'2018-08-20',3,2,10);

insert into t_sale_str (id_sale_str,id_sale,num,id_ware,qty,discount) values(1,1,1,1,10,2);
insert into t_sale_str (id_sale_str,id_sale,num,id_ware,qty,discount) values(2,1,2,2,5,2);
insert into t_sale_str (id_sale_str,id_sale,num,id_ware,qty,discount) values(3,1,3,3,5,2);
insert into t_sale_str (id_sale_str,id_sale,num,id_ware,qty,discount) values(4,3,4,3,5,2);



















