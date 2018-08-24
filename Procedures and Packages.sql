CREATE OR REPLACE NONEDITIONABLE FUNCTION state_supply(p_id_sale  IN NUMBER) RETURN NUMBER is
  v_id_state NUMBER ;
BEGIN
    SELECT ts.id_state
      INTO v_id_state
      FROM t_supply ts
     WHERE ts.id_supply = p_id_sale;  
  RETURN v_id_state;
END state_supply;

CREATE OR REPLACE NONEDITIONABLE FUNCTION state_document(p_id_sale  NUMBER) RETURN NUMBER is
  v_id_state NUMBER ;
BEGIN
    SELECT t.id_state
    INTO v_id_state
    FROM t_sale t
   WHERE t.id_sale = p_id_sale;
  RETURN v_id_state ;
END state_document;

CREATE OR REPLACE NONEDITIONABLE PROCEDURE add_t_price(p_id_ware t_price_ware.id_ware%TYPE,
                                                       p_dt_beg  t_price_ware.dt_beg%TYPE,
                                                       p_dt_end  t_price_ware.dt_end%TYPE,
                                                       p_price   t_price_ware.price%TYPE) IS
  p_id_sale_str NUMBER;
  v_count       NUMBER;

BEGIN 
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
                 WHERE ts.id_state = 1
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


CREATE OR REPLACE NONEDITIONABLE PROCEDURE Change_rest_hist_table(p_id_ware NUMBER,
                                                                  p_qty     NUMBER,
                                                                  p_date    DATE) IS

  t_id_ware NUMBER;
  t_dt_beg  DATE;
  t_qty t_supply_str.qty%TYPE;
BEGIN

  BEGIN
    SELECT t.id_ware, max(t.dt_beg) dt_beg, count(t.qty) qty
      INTO t_id_ware, t_dt_beg,t_qty
      FROM t_rest_hist t
     WHERE t.id_ware = p_id_ware
     GROUP BY t.id_ware;
  
    IF t_dt_beg = p_date THEN
      UPDATE t_rest_hist t
         SET t.qty = t.qty + p_qty
       WHERE t.id_ware = p_id_ware;
    ELSE 
      --change date_end in old rew, and add new row
      UPDATE t_rest_hist t
         SET t.dt_end = p_date
       WHERE t.id_ware = p_id_ware
         and t.dt_beg = t_dt_beg;
      INSERT INTO t_rest_hist
        (id_ware, qty, dt_beg, dt_end)
      VALUES
        (p_id_ware,t_qty+p_qty, p_date, p_date);
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      INSERT INTO t_rest_hist
        (id_ware, qty, dt_beg, dt_end)
      VALUES
        (p_id_ware, p_qty, p_date, p_date);
  END;

END Change_rest_hist_table;

CREATE OR REPLACE NONEDITIONABLE PROCEDURE Change_rest_table(p_id_ware NUMBER,
                                                             p_qty     NUMBER) IS

  t_id_ware NUMBER;
BEGIN

  BEGIN
    SELECT t_rest.id_ware
      INTO t_id_ware
      FROM t_rest
     WHERE t_rest.id_ware = p_id_ware;
    UPDATE t_rest t
       SET t.qty = t.qty + p_qty
     WHERE t.id_ware = p_id_ware;
  EXCEPTION
    WHEN no_data_found THEN
      INSERT INTO t_rest (id_ware, qty) VALUES (p_id_ware, p_qty);
  END;

END Change_rest_table;

CREATE OR REPLACE NONEDITIONABLE PACKAGE pkg_around_mutation
IS
  bUpdPainters BOOLEAN;
  t_id_supply NUMBER;
  t_id_sale NUMBER;
  t_id_ware NUMBER;
  t_id_sale_str NUMBER;
  t_discount t_sale.discount%Type;
  t_dt DATE;
  t_id_state NUMBER;
  PROCEDURE p_summa_t_supply;
  PROCEDURE p_summa_t_sale;  
  PROCEDURE p_price_t_sale_str;
  PROCEDURE p_t_rest_table_sale;
  PROCEDURE p_t_rest_table_supply;
END pkg_around_mutation;

CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY pkg_around_mutation is
  --Calculation summa in table t_supply
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
  --Calculation summa in table t_sale
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
  --Recalculation of the price when the discount is changed in t_sale
  PROCEDURE p_price_t_sale_str IS
    t_price    t_sale_str.price%Type;
    t_id_state t_sale.id_state%Type;
  BEGIN
    IF bUpdPainters THEN
      bUpdPainters := FALSE;
      SELECT t.id_state
        INTO t_id_state
        FROM t_sale t
       WHERE t.id_sale = t_id_sale;
      IF t_id_state = 1 THEN
        FOR cur IN (SELECT tpw.price, ts.id_sale_str
                      FROM t_price_ware tpw, t_sale_str ts
                     WHERE tpw.id_ware = ts.id_ware
                       and ts.id_sale = t_id_sale
                       and t_dt >= tpw.dt_beg
                       and (t_dt < tpw.dt_END)) LOOP
          UPDATE t_sale_str t
             SET t.price = cur.price * (100 - t_discount) / 100
           WHERE t.id_sale_str = cur.id_sale_str;
          t_price := cur.price * (100 - t_discount) / 100;
        END LOOP;
      END IF;
    END IF;
  END;
  --TASK_6-7
  PROCEDURE p_t_rest_table_supply IS
  BEGIN
    FOR cur IN (SELECT tss.id_ware, tss.qty qty, tss.id_supply_str, ts.dt
                  FROM t_supply_str tss, t_supply ts
                 WHERE tss.id_supply = t_id_supply
                   AND ts.id_supply = tss.id_supply) LOOP
      IF t_id_state = 2 THEN
        change_rest_table(cur.id_ware, cur.qty);
        change_rest_hist_table(cur.id_ware, cur.qty, cur.dt);
      ELSE
        change_rest_table(cur.id_ware, cur.qty * (-1));
        change_rest_hist_table(cur.id_ware, cur.qty * (-1), cur.dt);
      END IF;
    END LOOP;
  END;


  PROCEDURE p_t_rest_table_sale IS
  BEGIN
    FOR cur IN (SELECT tss.id_ware, tss.qty qty, tss.id_sale, ts.dt
                  FROM t_sale_str tss, t_sale ts
                 WHERE tss.id_sale = t_id_sale
                   AND ts.id_sale = tss.id_sale) LOOP
      IF t_id_state = 2 THEN
        change_rest_table(cur.id_ware, cur.qty*(-1));
        change_rest_hist_table(cur.id_ware, cur.qty*(-1), cur.dt);
      ELSE
        change_rest_table(cur.id_ware, cur.qty );
        change_rest_hist_table(cur.id_ware, cur.qty , cur.dt);
      END IF;
    END LOOP;
  END;
END pkg_around_mutation;












