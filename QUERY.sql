--QUERY-01
SELECT tw.id_ware, tw.name, tw.price, tm.name, tpm.id_price_model
  FROM t_ware tw, t_model tm, t_price_model tpm
 WHERE tw.id_model = tm.id_model
   AND tm.id_model = tpm.id_model
   AND tpm.price <> tw.price;

--QUERY3
SELECT IPAD(' ', 3 * t.id_parent) || t.name || ' (' || t.kol || ')'
  FROM (SELECT t.*, t2.kol, t.rowid
          FROM t_ctl_node t,
               (SELECT tcn.id_parent, COUNT(tcn.id_parent) kol
                  FROM t_ctl_node tcn
                 GROUP BY tcn.id_parent) t2
         WHERE t.id_ctl_node = t2.id_parent(+)) t
 START WITH id_parent IS NULL
CONNECT BY PRIOR id_ctl_node = id_parent
 ORDER SIBLINGS BY name;

--QUERY4
SELECT IPAD(' ', 3 * LEVEL) || t.name AS Tree
  FROM t_dept t
 START WITH t.id_parent IS NULL
CONNECT BY PRIOR t.id_dept = t.id_parent
 ORDER SIBLINGS BY t.name;

-- QUERY7 
SELECT 
       tc.moniker "Name client",
       COUNT(ts.id_sale) "Count_sale",
       SUM(ts.summa) "Summa",
       SUM(ts.summa) / COUNT(ts.id_sale) "Aug summma",
       MAX(ts.discount) "Max discount",
       MIN(ts.discount)  "Min discount"
  FROM t_client tc, t_sale ts
 WHERE tc.id_client = ts.id_sale
   AND ts.discount > 25
 GROUP BY tc.moniker;

-- QUERY-08 
SELECT tm.label "Label",
       COUNT(tss.id_sale_str) "Count str sale",
       SUM(tss.qty) "Count",
       SUM(tss.summa) / COUNT(tss.id_sale_str) "Aug summma",
       MIN(tss.discount) "Max discount",
       MAX(tss.discount) "Min discount"
  FROM t_model tm, t_sale_str tss, t_ware tw
 WHERE tm.id_model = tw.id_model
   AND tw.id_ware = tss.id_sale_str
 GROUP BY tm.label;
 
 
 
 
