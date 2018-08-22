CREATE OR REPLACE NONEDITIONABLE PACKAGE pkg_around_mutation
IS
  bUpdPainters BOOLEAN;
  t_id_supply NUMBER;
  t_id_sale NUMBER;
  t_id_ware NUMBER;
  t_id_sale_str NUMBER;
  t_discount t_sale.discount%Type;
  t_dt DATE;
  PROCEDURE p_summa_t_supply;
  PROCEDURE p_summa_t_sale;
  PROCEDURE p_price_t_sale_str;
END pkg_around_mutation;

CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY pkg_around_mutation is
  PROCEDURE p_summa_t_supply IS
    t_summa t_supply.summa%TYPE;
    t_nds   t_supply.nds%type;
  
  BEGIN
    IF bUpdPainters THEN
      bUpdPainters := FALSE;
    
      SELECT SUM(summa), SUM(nds)
        INTO t_summa, t_nds
        FROM t_supply_str z
       WHERE z.id_supply = t_id_supply;
    
      UPDATE t_supply ts
         SET ts.summa = t_summa, ts.nds = t_nds
       WHERE ts.id_supply = t_id_supply;
    END IF;
  END;

  PROCEDURE p_summa_t_sale IS
    t_summa_sale t_sale.summa%TYPE;
    t_nds_sale   t_sale.nds%type;
  
  BEGIN
    IF bUpdPainters THEN
      bUpdPainters := FALSE;
    
      SELECT SUM(summa), SUM(nds)
        INTO t_summa_sale, t_nds_sale
        FROM t_sale_str z
       WHERE z.id_sale = t_id_sale;
    
      UPDATE t_sale ts
         SET ts.summa = t_summa_sale, ts.nds = t_nds_sale
       WHERE ts.id_sale = t_id_sale;
    END IF;
  END;

  PROCEDURE p_price_t_sale_str IS
    t_price        t_sale_str.price%Type;
    t_id_state     t_sale.id_state%Type;
    tt_id_sale_str NUMBER;
  
  BEGIN
    IF bUpdPainters THEN
      bUpdPainters := FALSE;
      SELECT t.id_state
        INTO t_id_state
        FROM t_sale t
       WHERE t.id_sale = t_id_sale;
    
      IF t_id_state = 1 THEN
      
        FOR cur IN (SELECT tpw.price, ts.id_sale_str
                      INTO t_price, tt_id_sale_str
                      FROM t_price_ware tpw, t_sale_str ts
                     WHERE tpw.id_ware = ts.id_ware
                       and ts.id_sale = t_id_sale
                       and t_dt >= tpw.dt_beg
                       and (t_dt < tpw.dt_END)) LOOP
                       
          UPDATE t_sale_str t
             SET t.price = t_price * t_discount
           WHERE t.id_sale_str = tt_id_sale_str; 
          dbms_output.put_line('Test update line');         
         
        END LOOP;
     --   raise_application_error(-20002, 'No changes actual documets    ' || t_id_sale  || t_dt ); 
      END IF;
     
    END IF; 
    
  END;

END pkg_around_mutation;

CREATE OR REPLACE NONEDITIONABLE PROCEDURE add_t_price(p_id_ware t_price_ware.id_ware%TYPE,
                                                       p_dt_beg  t_price_ware.dt_beg%TYPE,
                                                       p_dt_end  t_price_ware.dt_end%TYPE,
                                                       p_price   t_price_ware.price%TYPE) IS
  p_id_sale_str NUMBER;
  v_count       NUMBER;

BEGIN
  --TASK_5 
  SELECT tw.id_ware
    INTO v_count
    FROM (SELECT * FROM t_ware tw2 WHERE tw2.id_ware = p_id_ware) tw
   WHERE NOT EXISTS (SELECT t.id_ware
            FROM t_price_ware t
           WHERE t.dt_end >= p_dt_beg
             AND tw.id_ware = t.id_ware);
  BEGIN
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
      raise_application_error(-20022, 'Can not change sale_str');
  END;

EXCEPTION
  WHEN no_data_found THEN
      raise_application_error(-20001, 'Price already set');
END add_t_price;

CREATE OR REPLACE NONEDITIONABLE PROCEDURE Change_rest_table (p_id_ware_new NUMBER,p_qty_new NUMBER ,p_id_ware_old NUMBER , p_qty_old NUMBER) IS

t_id_ware NUMBER;
BEGIN
  IF p_id_ware_new IS NOT NULL THEN
  BEGIN
      SELECT t_rest.id_ware
        INTO t_id_ware
        FROM t_rest
       WHERE t_rest.id_ware = p_id_ware_new;
      UPDATE t_rest t
         SET t.qty = t.qty + p_qty_new
       WHERE t.id_ware = p_id_ware_new;
     EXCEPTION
      WHEN no_data_found THEN
        INSERT INTO  t_rest
          (id_ware, qty)
        VALUES
          (p_id_ware_new, p_qty_new);
    END;
    UPDATE t_rest t SET t.qty = t.qty+p_qty_new WHERE t.id_ware = p_id_ware_new;
  END IF;

  UPDATE t_rest t SET t.qty = t.qty-p_qty_old WHERE t.id_ware = p_id_ware_old;

END Change_rest_table;













