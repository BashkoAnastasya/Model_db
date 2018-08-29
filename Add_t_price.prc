CREATE OR REPLACE NONEDITIONABLE PROCEDURE add_t_price(p_id_ware t_price_ware.id_ware%TYPE,
                                                       p_dt_beg  t_price_ware.dt_beg%TYPE,
                                                       p_dt_end  t_price_ware.dt_end%TYPE,
                                                       p_price   t_price_ware.price%TYPE) IS
  p_id_sale_str NUMBER;
  v_int         NUMBER;

BEGIN
  --проверяем утсановлена для данного товара цена 
  SELECT tw.id_ware
    INTO v_int
    FROM (SELECT * FROM t_ware tw2 WHERE tw2.id_ware = p_id_ware) tw
   WHERE NOT EXISTS (SELECT t.id_ware
            FROM t_price_ware t
           WHERE t.dt_end >= p_dt_beg
             AND tw.id_ware = t.id_ware);

  INSERT INTO t_price_ware
    (id_price_ware, id_ware, dt_beg, dt_end, price)
  VALUES
    (sec_t_price_ware.nextval, p_id_ware, p_dt_beg, p_dt_end, p_price);
  BEGIN
  --изменяем цены в таблице продаж 
    FOR cur IN (SELECT tss.id_sale_str,ts.discount                 
                  FROM t_sale_str tss, t_sale ts
                 WHERE ts.id_state != 1
                   AND tss.id_ware = p_id_ware
                   AND ts.dt >= p_dt_beg
                   AND ts.dt < p_dt_end) LOOP
      UPDATE t_sale_str t
         SET t.price = p_price*(100-cur.discount)/100
       WHERE t.id_sale_str = cur.id_sale_str;
    END LOOP;
  EXCEPTION
    WHEN no_data_found THEN
      p_id_sale_str := 1;
  END;

EXCEPTION
  WHEN no_data_found THEN
    p_id_sale_str := 1;
END add_t_price;
/
