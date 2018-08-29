CREATE OR REPLACE NONEDITIONABLE TRIGGER t_summa_t_supply_str_before
  BEFORE UPDATE OR DELETE OR INSERT  ON  t_supply_str
  FOR EACH ROW
DECLARE
  t_id_ware NUMBER;
BEGIN

  pkg_around_mutation.bUpdPainters := TRUE;

  IF (inserting or updating) THEN
    :new.summa                      := :new.price * :new.qty;
    :new.nds                        := :new.price * :new.qty * 18 / 118;
    pkg_around_mutation.t_id_supply := :new.id_supply;
  ELSE
    pkg_around_mutation.t_id_supply := :old.id_supply;
  END IF;
 --  change_rest_table(:new.id_ware, :new.qty,:old.id_ware,:old.qty); 

END;
/
CREATE OR REPLACE NONEDITIONABLE TRIGGER t_summa_t_supply_str_after
AFTER UPDATE OR DELETE OR INSERT
ON t_supply_str
BEGIN
  pkg_around_mutation.p_summa_t_supply;
END t_summa_t_supply;
/
CREATE OR REPLACE NONEDITIONABLE TRIGGER t_summa_sale_str_before
  BEFORE UPDATE OR INSERT OF price, qty, id_ware, id_sale OR DELETE ON t_sale_str
  FOR EACH ROW
DECLARE
  no_changes EXCEPTION;
  t_discount t_sale.discount%TYPE;
  t_price    t_sale_str.price%TYPE;
BEGIN
 
  -- Check the status of the document
  IF ((updating OR inserting) and state_document(:new.id_sale) = 1) OR
     (deleting AND state_document(:old.id_sale) = 1) THEN
    --When the goods change, we change the cost
    IF (updating OR inserting) THEN  
     BEGIN
     IF :new.id_ware <> :old.id_ware  OR :old.id_ware IS NULL  THEN
        SELECT tpw.price, ts.discount
          INTO t_price, t_discount
          FROM t_price_ware tpw, t_sale ts
         WHERE tpw.id_ware = :new.id_ware
           AND ts.id_sale = :new.id_sale
           AND ts.dt >= tpw.dt_beg
           AND (ts.dt < tpw.dt_end OR tpw.dt_end IS NULL);
        :new.price := t_price * (100 - t_discount) / 100;
      END IF;
    --Control price
    EXCEPTION
      WHEN no_data_found THEN
        :new.price:=0;
        dbms_output.put_line('Pice not found%');
    END;
   
    :new.disc_price                   := :new.price -
                                         (:new.price * :new.discount / 100);
    :new.summa                        := (:new.price -
                                         (:new.price * :new.discount / 100)) *
                                         :new.qty;
    :new.nds                          := (:new.price -
                                         (:new.price * :new.discount / 100)) *
                                         :new.qty * 18 / 118;
             
    END IF;                            
    pkg_around_mutation.bUpdPainters  := TRUE;
    pkg_around_mutation.t_id_ware     := :new.id_ware;
    pkg_around_mutation.t_id_sale_str := :new.id_sale_str;
    pkg_around_mutation.t_id_sale     := :new.id_sale;
  ELSE
    RAISE no_changes;
  END IF;
  
   
    
EXCEPTION
  WHEN no_changes THEN
    raise_application_error(-20002, 'No changes actual documets%');
END;
/
CREATE OR REPLACE NONEDITIONABLE TRIGGER t_summa_sale_str_after
  AFTER UPDATE OR INSERT  OF price, qty, id_ware OR DELETE ON t_sale_str 
BEGIN
 -- pkg_around_mutation.p_price_t_sale_str;
  pkg_around_mutation.p_summa_t_sale;
END;
/
CREATE OR REPLACE NONEDITIONABLE TRIGGER t_summa_sale_before
  BEFORE UPDATE OR INSERT OF discount, dt ON t_sale
  FOR EACH ROW
DECLARE
  t_is_vip t_client.is_vip%TYPE;
  no_sales   EXCEPTION;
  no_changes EXCEPTION;

BEGIN

  --Control size discount TASK-02
  IF :old.id_state = 1 OR :old.id_state IS NULL THEN
  
    SELECT t_client.is_vip
      INTO t_is_vip
      FROM t_client
     WHERE t_client.id_client = :new.id_client;
  
    IF :new.discount > 20 AND t_is_vip = 'N' THEN
      RAISE no_sales;
    END IF;
  ELSE
    RAISE no_changes;
  END IF;

  -- Change price in table t_sale_str
  IF updating OR inserting THEN
    pkg_around_mutation.bUpdPainters := TRUE;
    pkg_around_mutation.t_discount   := :new.discount;
    pkg_around_mutation.t_dt         := :new.dt;
    pkg_around_mutation.t_id_sale    := :new.id_sale;
  END IF;
EXCEPTION
  WHEN no_sales THEN
    raise_application_error(-20001, 'Sale no more 20%');
  WHEN no_changes THEN
    raise_application_error(-20002, 'No changes actual documets%');
END;
/
CREATE OR REPLACE NONEDITIONABLE TRIGGER t_summa_sale_after
AFTER UPDATE  OF dt, discount 
ON t_sale
BEGIN
  pkg_around_mutation.p_price_t_sale_str; 
END;
/
CREATE OR REPLACE NONEDITIONABLE TRIGGER change_t_rest_supply_before
  BEFORE UPDATE OF id_state ON t_supply
  FOR EACH ROW

BEGIN
    pkg_around_mutation.bUpdPainters := TRUE;
    pkg_around_mutation.t_id_supply  := :new.id_supply;
    pkg_around_mutation.t_id_state:=:new.id_state; 
END;
/
CREATE OR REPLACE NONEDITIONABLE TRIGGER change_t_rest_supply_after
  AFTER UPDATE OF id_state ON t_supply

BEGIN
  --ADD/DELETE table t_rest TASK-06
  --when you change the document state, change the remainders
 pkg_around_mutation.p_t_rest_table_supply;
END change_t_rest;
/
CREATE OR REPLACE NONEDITIONABLE TRIGGER change_t_rest_sale_before
  BEFORE UPDATE OF id_state ON t_sale
  FOR EACH ROW

BEGIN
    pkg_around_mutation.bUpdPainters := TRUE;
    pkg_around_mutation.t_id_sale  := :new.id_sale;
    pkg_around_mutation.t_id_state:=:new.id_state; 
END;
/
CREATE OR REPLACE NONEDITIONABLE TRIGGER change_t_rest_sale_after
  AFTER UPDATE OF id_state ON t_sale

BEGIN
  --ADD/DELETE table t_rest TASK-06
  --when you change the document state, change the remainders
 pkg_around_mutation.p_t_rest_table_sale;
END change_t_rest;
/
CREATE OR REPLACE NONEDITIONABLE TRIGGER change_t_price_ware
  BEFORE UPDATE OR DELETE  OR INSERT ON  t_price_ware
  FOR EACH ROW
DECLARE   
    PROCEDURE change_price_sale_str(p_id_ware NUMBER,
                                  p_dt_deg  DATE,
                                  p_dt_end  DATE,
                                  p_price   NUMBER) IS                                  
  BEGIN
    FOR cur IN (SELECT tss.id_sale_str, ts.discount
                  FROM t_sale_str tss, t_sale ts
                 WHERE ts.id_state = 1
                   AND tss.id_ware = p_id_ware
                   AND ts.dt >= p_dt_deg
                   AND ts.dt < p_dt_end) LOOP
      UPDATE t_sale_str t
         SET t.price = p_price * (100 - cur.discount) / 100
       WHERE t.id_sale_str = cur.id_sale_str;
    END LOOP;
  END; 
  
BEGIN   
   
  IF inserting  THEN 
    add_t_price (:new.id_ware,:new.dt_beg,:new.dt_end,:new.price);  
  ELSIF updating THEN
    change_price_sale_str(:new.id_ware,:new.dt_beg,:new.dt_end,:new.price);      
  ELSIF deleting THEN 
    change_price_sale_str(:old.id_ware,:old.dt_beg,:old.dt_end,Null);    
  END IF;  

END;
/

