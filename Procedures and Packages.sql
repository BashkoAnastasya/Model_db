CREATE OR REPLACE NONEDITIONABLE PROCEDURE Change_sale_rep(p_id_ware NUMBER,
                                                           p_date    DATE) IS
  t_id_ware    NUMBER;
  t_inp_qty    NUMBER(6);
  t_inp_sum    NUMBER(8, 2);
  t_supple_qty NUMBER(6);
  t_supple_sum NUMBER(8, 2);
  t_sale_qty   NUMBER(6);
  t_sale_sum   NUMBER(8, 2);
  t_out_qty    NUMBER(6);
  t_out_sum    NUMBER(8, 2);
  v_count      NUMBER;
BEGIN
  SELECT t.id_ware,
         DECODE(SUM(t2.in_qty), NULL, 0, SUM(t2.in_qty)),
         DECODE(SUM(t2.in_sum), NULL, 0, SUM(t2.in_sum)),
         DECODE(SUM(tsu.qty), NULL, 0, SUM(tsu.qty)),
         DECODE(SUM(tsu.summa), NULL, 0, SUM(tsu.summa)),
         DECODE(SUM(tsa.qty), NULL, 0, SUM(tsa.qty)),
         DECODE(SUM(tsa.summa), NULL, 0, SUM(tsa.summa)),
         DECODE(SUM(t2.in_qty), NULL, 0, SUM(t2.in_qty)) +
         DECODE(SUM(tsu.qty), NULL, 0, SUM(tsu.qty)) -
         DECODE(SUM(tsa.qty), NULL, 0, SUM(tsa.qty)) out_qty,
         CASE WHEN (DECODE(SUM(t2.in_qty), NULL, 0, SUM(t2.in_qty)) -
         DECODE(SUM(tsu.qty), NULL, 0, SUM(tsu.qty)))=0 THEN 0 ELSE
         (DECODE(SUM(t2.in_sum), NULL, 0, SUM(t2.in_sum)) +
         DECODE(SUM(tsu.summa), NULL, 0, SUM(tsu.summa))) *
         (1 - DECODE(SUM(tsa.qty), NULL, 0, SUM(tsa.qty))) /
         (DECODE(SUM(t2.in_qty), NULL, 0, SUM(t2.in_qty)) +
         DECODE(SUM(tsu.qty), NULL, 0, SUM(tsu.qty))) END
    INTO t_id_ware,
         t_inp_qty,
         t_inp_sum,
         t_supple_qty,
         t_supple_sum,
         t_sale_qty,
         t_sale_sum,
         t_out_qty,
         t_out_sum
    FROM (SELECT TRUNC(p_date, 'mm') dt, p_id_ware id_ware FROM dual) t
    LEFT OUTER JOIN (SELECT max(TRUNC(p_date, 'mm')) dt2,
                            tsr.out_qty in_qty,
                            tsr.out_sum in_sum ,
                            tsr.id_ware
                       FROM t_sale_rep tsr
                      WHERE tsr.month < TRUNC(p_date,'mm')
                      GROUP BY tsr.out_qty, tsr.out_sum, tsr.id_ware) t2
      ON t.id_ware = t2.id_ware
    LEFT OUTER JOIN (SELECT tss.*, ts.dt
                       FROM t_supply_str tss
                       JOIN t_supply ts
                         ON tss.id_supply = ts.id_supply
                      WHERE ts.id_state = 2) tsu
      ON t.id_ware = tsu.id_ware
     AND TRUNC(t.dt, 'mm') = TRUNC(tsu.dt, 'mm')
    LEFT OUTER JOIN (SELECT tsls.*, tsl.dt
                       FROM t_sale_str tsls
                       JOIN t_sale tsl
                         ON tsls.id_sale = tsl.id_sale
                      WHERE tsl.id_state = 2) tsa
      ON t.id_ware = tsa.id_ware
     AND TRUNC(t.dt, 'mm') = TRUNC(tsa.dt, 'mm')
   GROUP BY t.id_ware;
  SELECT COUNT(t.id_ware)
    INTO v_count
    FROM t_sale_rep t
   WHERE t.month = TRUNC(p_date, 'mm')
     AND t.id_ware = p_id_ware;
  IF v_count > 0 THEN
    UPDATE t_sale_rep t
       SET t.id_ware    = t_id_ware,
           t.month      = TRUNC(p_date, 'mm'),
           t.inp_qty    = t_inp_qty,
           t.inp_sum    = t_inp_sum,
           t.supple_qty = t_supple_qty,
           t.supple_sum = t_supple_sum,
           t.sale_qty   = t_sale_qty,
           t.sale_sum   = t_sale_sum,
           t.out_qty    = t_out_qty,
           t.out_sum    = t_out_sum
     WHERE t.id_ware = p_id_ware
       and t.month = TRUNC(p_date, 'mm');
  ELSE
    INSERT INTO t_sale_rep
      (id_ware,
       month,
       inp_qty,
       inp_sum,
       supple_qty,
       supple_sum,
       sale_qty,
       sale_sum,
       out_qty,
       out_sum)
    VALUES
      (t_id_ware,
       TRUNC(p_date, 'mm'),
       t_inp_qty,
       t_inp_sum,
       t_supple_qty,
       t_supple_sum,
       t_sale_qty,
       t_sale_sum,
       t_out_qty,
       t_out_sum);
  END IF;
END Change_sale_rep;
/
CREATE OR REPLACE NONEDITIONABLE PROCEDURE Change_rest_table(p_id_ware NUMBER,
                                                             p_qty     NUMBER) IS

  t_id_ware NUMBER;
  t_qty     NUMBER(6,2);
BEGIN

  BEGIN
  SELECT t_rest.id_ware, t_rest.qty
    INTO t_id_ware, t_qty
    FROM t_rest
   WHERE t_rest.id_ware = p_id_ware;
  IF t_qty + p_qty < 0 THEN
    BEGIN
      raise_application_error(-20001,'Îòìåíà ïîñòàâêè: òîâàðà íà ñêëàäå íåò');
    END;
  ELSE
    UPDATE t_rest t SET t.qty = t.qty + p_qty WHERE t.id_ware = p_id_ware;
  END IF;
  EXCEPTION WHEN no_data_found THEN INSERT INTO t_rest(id_ware, qty) VALUES(p_id_ware, p_qty); END;

END Change_rest_table;
/
CREATE OR REPLACE NONEDITIONABLE PROCEDURE Change_rest_hist_table_supply (p_id_ware NUMBER,
                                                                  p_qty     NUMBER,
                                                                  p_date    DATE) IS

  t_id_ware NUMBER;
  t_dt_beg  DATE;
  t_qty t_supply_str.qty%TYPE;
BEGIN

  BEGIN
    
    SELECT t.id_ware, min(t.dt_beg) dt_beg, count(t.qty) qty
      INTO t_id_ware, t_dt_beg,t_qty
      FROM t_rest_hist t
     WHERE t.id_ware = p_id_ware AND t.dt_beg>=p_date
     GROUP BY t.id_ware;
  
    IF t_dt_beg = p_date THEN
      UPDATE t_rest_hist t
         SET t.qty = t.qty + p_qty
       WHERE t.id_ware = p_id_ware;
    ELSE 
      --change date_end in old rew, and add new row
  /*    UPDATE t_rest_hist t
         SET t.dt_end = p_date
       WHERE t.id_ware = p_id_ware
         and t.dt_beg = t_dt_beg;*/
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

END Change_rest_hist_table_supply;
/
CREATE OR REPLACE NONEDITIONABLE PROCEDURE Change_rest_hist_table_sale(p_id_ware NUMBER,
                                                                  p_qty     NUMBER,
                                                                  p_date    DATE) IS

  t_id_ware NUMBER;
  t_dt_end  DATE;
  t_dt_beg DATE;  
  t_qty t_supply_str.qty%TYPE;
BEGIN

  BEGIN
    SELECT t.id_ware, MAX(t.dt_end) dt_end, SUM(t.qty) qty,MAX(t.dt_beg) dt_beg
      INTO t_id_ware, t_dt_end,t_qty,t_dt_beg
      FROM t_rest_hist t      
     WHERE t.id_ware = p_id_ware
     AND t.dt_end<=p_date
     AND ROWNUM = 1
     GROUP BY t.id_ware ORDER BY 2,1;
  
    IF t_dt_end = p_date THEN
      UPDATE t_rest_hist t
         SET t.qty = t.qty + p_qty
       WHERE t.id_ware = p_id_ware AND t.dt_beg>=t_dt_beg AND  t.dt_end = t_dt_end ;
    ELSE 
      --change date_end in old rew, and add new row
      UPDATE t_rest_hist t
         SET t.dt_end = p_date
       WHERE t.id_ware = p_id_ware
         AND t.dt_beg>=t_dt_beg
         AND t.dt_end = t_dt_end;
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

END Change_rest_hist_table_sale;
/
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
/
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
/
CREATE OR REPLACE NONEDITIONABLE FUNCTION state_supply(p_id_sale  IN NUMBER) RETURN NUMBER is
  v_id_state NUMBER ;
BEGIN
    SELECT ts.id_state
      INTO v_id_state
      FROM t_supply ts
     WHERE ts.id_supply = p_id_sale;  
  RETURN v_id_state;
END state_supply;
/
CREATE OR REPLACE NONEDITIONABLE FUNCTION state_document(p_id_sale  NUMBER) RETURN NUMBER is
  v_id_state NUMBER ;
BEGIN
    SELECT t.id_state
    INTO v_id_state
    FROM t_sale t
   WHERE t.id_sale = p_id_sale;
  RETURN v_id_state ;
END state_document;

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
        change_rest_hist_table_supply(cur.id_ware, cur.qty, cur.dt);
        change_sale_rep(cur.id_ware, cur.dt);
      ELSE
        change_rest_table(cur.id_ware, cur.qty * (-1));
        change_rest_hist_table_supply(cur.id_ware, cur.qty * (-1), cur.dt);
        change_sale_rep(cur.id_ware, cur.dt);
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
        change_rest_hist_table_sale(cur.id_ware, cur.qty*(-1), cur.dt);
        change_sale_rep(cur.id_ware, cur.dt);
      ELSE
        change_rest_table(cur.id_ware, cur.qty );       
        change_rest_hist_table_sale(cur.id_ware, cur.qty , cur.dt); 
        change_sale_rep(cur.id_ware, cur.dt);
      END IF;
    END LOOP;
  END;
END pkg_around_mutation;
/
