
--QUERY-01
SELECT tw.id_ware, tw.name, tw.price, tm.name, tpm.id_price_model
  FROM t_ware tw
  JOIN t_model tm
    ON tw.id_model = tm.id_model
  JOIN t_price_model tpm
    ON tm.id_model = tpm.id_model
 WHERE tpm.price <> tw.price;

--QUERY-02 
SELECT tss.*
  FROM t_sale_str tss, t_sale ts, t_price_ware tpw
 WHERE tss.id_sale = ts.id_sale
   AND tss.id_ware = tpw.id_ware
   AND ts.dt >= tpw.dt_beg
   AND ts.dt < tpw.dt_end
   AND ts.discount = 0
   AND tss.price <> tpw.price;

--QUERY3
SELECT LPAD(' ', 3 * t.id_parent) || t.name || ' (' || t.kol || ')'
  FROM (SELECT t.*, t2.kol, t.rowid
          FROM t_ctl_node t,
               (SELECT tcn.id_parent, COUNT(tcn.id_parent) kol
                  FROM t_ctl_node tcn
                 GROUP BY tcn.id_parent order by 1) t2
         WHERE t.id_ctl_node = t2.id_parent(+) order by t.id_parent) t
 START WITH id_parent IS NULL
CONNECT BY PRIOR id_ctl_node = id_parent
 ORDER SIBLINGS BY id_parent;

--QUERY4
SELECT LPAD(' ', 3 * LEVEL) || t.name AS Tree
  FROM t_dept t
 START WITH t.id_parent IS NULL
CONNECT BY PRIOR t.id_dept = t.id_parent
 ORDER SIBLINGS BY t.name;

-- QUERY7 
SELECT tc.moniker "Name client",
       COUNT(ts.id_sale) "Count_sale",
       SUM(ts.summa) "Summa",
       SUM(ts.summa) / COUNT(ts.id_sale) "Aug summma",
       MAX(ts.discount) "Max discount",
       MIN(ts.discount) "Min discount"
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

--QUERY-10
SELECT tss.discount + ts.discount,
       COUNT(tss.id_sale_str),
       COUNT(tss.id_ware),
       COUNT(tm.id_model),
       SUM(tss.qty),
       SUM(tss.summa)
  FROM t_sale_str tss, t_sale ts, t_ware tw, t_model tm
 WHERE tss.id_sale = ts.id_sale
   AND tss.id_ware = tw.id_ware
   AND tw.id_model = tm.id_model
 GROUP BY tss.discount, ts.discount;

--QUERY-11   

SELECT tm.moniker,
       SUM(tss.discount + ts.discount),
       COUNT(tss.id_sale_str),
       COUNT(tss.id_ware),
       SUM(tss.qty),
       SUM(tss.summa)
  FROM t_sale_str tss, t_sale ts, t_ware tw, t_model tm
 WHERE tss.id_sale = ts.id_sale
   AND tss.id_ware = tw.id_ware
   AND tw.id_model = tm.id_model HAVING
 AVG(tss.discount + ts.discount) < SUM(tss.discount + ts.discount)
 GROUP BY tm.moniker;



--QUERY-12
SELECT tw.id_ware
  FROM t_ware tw
  LEFT OUTER JOIN (SELECT trh.id_ware, trh.qty, COUNT(1)
                     FROM t_rest_hist trh
                    GROUP BY trh.id_ware, trh.qty
                   HAVING MAX(trh.dt_beg) <= :p_beg) tr_beg
    ON tr_beg.id_ware = tw.id_ware
  LEFT OUTER JOIN (SELECT tss.id_ware, SUM(tss.qty)
                     FROM t_supply_str tss
                     JOIN t_supply ts
                       ON tss.id_supply = ts.id_supply
                    WHERE ts.id_state = 2
                      AND ts.dt >= :p_beg
                      AND ts.dt <= :p_end
                    GROUP BY tss.id_ware) tsus
    ON tsus.id_ware = tw.id_ware
  LEFT OUTER JOIN (SELECT tss.id_ware, SUM(tss.qty)
                     FROM t_sale_str tss
                     JOIN t_sale ts
                       ON tss.id_sale = ts.id_sale
                    WHERE ts.id_state = 2
                      AND ts.dt >= :p_beg
                      AND ts.dt <= :p_end
                    GROUP BY tss.id_ware) tsas
    ON tsas.id_ware = tw.id_ware
  LEFT OUTER JOIN (SELECT trh.id_ware, trh.qty, COUNT(1)
                     FROM t_rest_hist trh
                    GROUP BY trh.id_ware, trh.qty
                   HAVING MIN(trh.dt_end) <= :p_end) tr_end
    ON tr_end.id_ware = tw.id_ware;
    
    
    
    
                                        
                    
                    
                    

