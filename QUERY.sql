--QUERY-01
select tw.id_ware, tw.name, tw.price, tm.name, tpm.id_price_model
  from t_ware tw, t_model tm, t_price_model tpm
 where tw.id_model = tm.id_model
   and tm.id_model = tpm.id_model
   and tpm.price <> tw.price;

--QUERY3
select lpad(' ', 3 * t.id_parent) || t.name || ' (' || t.kol || ')'
  from (select t.*, t2.kol, t.rowid
          from T_CTL_NODE t,
               (select tcn.id_parent, count(tcn.id_parent) kol
                  from T_CTL_NODE tcn
                 group by tcn.id_parent) t2
         where t.id_ctl_node = t2.id_parent(+)) t
 START WITH id_parent is null
CONNECT BY PRIOR id_ctl_node = id_parent
 ORDER SIBLINGS BY name;

--QUERY4
SELECT lpad(' ', 3 * level) || t.name as Tree
  FROM t_dept t
 START WITH t.id_parent is null
CONNECT BY PRIOR t.id_dept = t.id_parent
 ORDER SIBLINGS BY t.name;

-- QUERY7 
select 
       tc.moniker "Name client",
       count(ts.id_sale) "Count_sale",
       sum(ts.summa) "Summa",
       sum(ts.summa) / count(ts.id_sale) "Aug summma",
       max(ts.discount) "Max discount",
       min(ts.discount)  "Min discount"
  from t_client tc, t_sale ts
 where tc.id_client = ts.id_sale
   and ts.discount > 25
 group by tc.moniker;

-- QUERY-08 
select tm.label "Label",
       count(tss.id_sale_str) "Count str sale",
       sum(tss.qty) "Count",
       sum(tss.summa) / count(tss.id_sale_str) "Aug summma",
       min(tss.discount) "Max discount",
       max(tss.discount) "Min discount"
  from t_model tm, t_sale_str tss, t_ware tw
 where tm.id_model = tw.id_model
   and tw.id_ware = tss.id_sale_str
 group by tm.label;
 
 
 
 
