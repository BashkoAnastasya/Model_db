CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY test IS
-- i?ioao?a aey caiieiaiey oanoiauie aaiiuie 
 PROCEDURE add_test_data AS
 BEGIN
   INSERT INTO t_supplier VALUES (9, 'IP Frilov26', 'Frilov26 I I');   
 END;
 
 PROCEDURE delete_test_data AS
 BEGIN
   DELETE FROM t_sale_str t WHERE t.id_sale_str in (95,96,99); 
   DELETE FROM t_sale t WHERE t.id_sale in (95,96,99); 
   DELETE FROM t_supply_str t WHERE t.id_supply IN (101);
   DELETE FROM t_supply t WHERE t.id_supply IN (101);
   DELETE FROM t_price_ware t WHERE t.id_price_ware in (95,96,99);
   DELETE FROM t_supplier t  WHERE t.id_supplier IN (8,9); 
   DELETE FROM t_client t WHERE t.id_client in (46);  
 END;

-- TASK_1.1
  FUNCTION f_test_supply_str_summa_nds(p_id_supply t_supply.id_supply%TYPE ,
                                   p_code t_supply.code%TYPE,
                                   p_dt t_supply.dt%TYPE,
                                   p_id_supplier t_supply.id_supplier%TYPE,                             
                                   p_id_supply_str t_supply_str.id_supply_str%TYPE,                                
                                   p_num t_supply_str.num%TYPE,
                                   p_id_ware t_supply_str.id_ware%TYPE,
                                   p_qty t_supply_str.qty%TYPE,
                                   p_price t_supply_str.price%TYPE) RETURN INTEGER IS
    v_result INTEGER;
    v_summa  t_supply.summa%TYPE;
    v_nds    t_supply.nds%TYPE;
  BEGIN
    v_result := 0;
    INSERT INTO t_supply
      (id_supply, code, dt, id_supplier, id_state)
    VALUES
      (p_id_supply, p_code, p_dt, p_id_supplier, 1);
    INSERT INTO t_supply_str
      (id_supply_str, id_supply, num, id_ware, qty, price)
    VALUES
      (p_id_supply_str, p_id_supply, p_num, p_id_ware, p_qty, p_price);
    SELECT summa, nds
      INTO v_summa, v_nds
      FROM t_supply_str
     WHERE id_supply_str = p_id_supply_str;
    IF NVL(v_summa, 0) <> p_price*p_qty  OR NVL(v_nds, 0) <> ROUND(p_qty*p_price* 18 / 118, 2) THEN
            v_result := 1;            
    END IF;
    SELECT summa, nds
      INTO v_summa, v_nds
      FROM t_supply
     WHERE id_supply = p_id_supply;
    IF NVL(v_summa, 0) <> p_price*p_qty OR NVL(v_nds, 0) <> ROUND(p_price*p_qty* 18 / 118, 2) THEN
      v_result := 1;
    END IF;
    RETURN v_result;
  END; 
  
   -- TASK_1.2
  FUNCTION f_test_supply_summa_nds(p_id_supply t_supply.id_supply%TYPE) RETURN INTEGER IS
    v_result INTEGER;
    v_summa  t_supply.summa%TYPE;
    v_nds    t_supply.nds%TYPE;
    v_summa_str  t_supply_str.summa%TYPE;
    v_nds_str    t_supply_str.nds%TYPE;
  BEGIN
    v_result := 0; 
    SELECT SUM(summa), SUM(nds)
      INTO v_summa_str, v_nds_str
      FROM t_supply_str t
     WHERE t.id_supply = p_id_supply;
    SELECT summa, nds
      INTO v_summa, v_nds
      FROM t_supply
     WHERE id_supply = p_id_supply;
    IF NVL(v_summa, 0) <> v_summa_str OR NVL(v_nds, 0) <> v_nds_str THEN
      v_result := 1;
    END IF;
    RETURN v_result;
  END;  
    
--TASK_2
  FUNCTION f_test_client_discount_nv(p_id_client t_client.id_client%TYPE,
                                     p_id_dept   t_client.id_dept%TYPE,
                                     p_moniker   t_client.moniker%TYPE,
                                     p_name      t_client.name%TYPE,
                                     p_is_vip    t_client.is_vip%TYPE,
                                     p_id_sale   t_sale.id_sale%TYPE,
                                     p_num       t_sale.num%TYPE,
                                     p_dt        t_sale.dt%TYPE,                                    
                                     p_discount  t_sale.discount%TYPE)
    RETURN INTEGER IS
    v_result INTEGER;
  BEGIN
    v_result := 0;
    INSERT INTO t_client
      (id_client, id_dept, moniker, name, is_vip)
    VALUES
      (p_id_client, p_id_dept, p_moniker, p_name, p_is_vip);
    INSERT INTO t_sale
      (id_sale, num, dt, id_client, id_state, discount)
    VALUES
      (p_id_sale, p_num, p_dt, p_id_client, 1, p_discount);
    IF p_is_vip = 'N' and p_discount > 20 THEN
      v_result := 1;
    END IF;
      DELETE FROM t_sale t WHERE t.id_sale=p_id_sale;
      DELETE FROM t_client t WHERE t.id_client=p_id_client; 
      RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      DELETE FROM t_client t WHERE t.id_client in (p_id_client);
      IF SUBSTR(dbms_utility.format_error_stack, 1, 9) <> 'ORA-20001' THEN
        v_result := 1;
      END IF;
      RETURN v_result;      
  END;
  
  --TASK_3
  FUNCTION f_test_price(p_id_sale      t_sale.id_sale%TYPE,
                        p_dt            t_sale.dt%TYPE,
                        p_discount      t_sale.discount%TYPE,
                        p_id_price_ware t_price_ware.id_price_ware%TYPE,                    
                        p_dt_beg        t_price_ware.dt_beg%TYPE,
                        p_dt_end        t_price_ware.dt_end%TYPE,
                        p_price         t_price_ware.price%TYPE,
                        p_id_sale_str   t_sale_str.id_sale_str%TYPE,                       
                        p_id_ware       t_sale_str.id_ware%TYPE,
                        p_qty           t_sale_str.qty%TYPE,
                        pp_discount      t_sale_str.discount%TYPE)
  RETURN INTEGER IS
   v_result INTEGER; 
   v_price t_price_ware.price%TYPE;
    BEGIN 
      v_result:=0;     
    INSERT INTO t_sale
      (id_sale,id_client, dt, id_state, discount)
    VALUES
      (p_id_sale,1, p_dt,1, p_discount);
    INSERT INTO t_price_ware
      (id_price_ware, id_ware, dt_beg, dt_end, price)
    VALUES
      (p_id_price_ware, p_id_ware, p_dt_beg, p_dt_end, p_price);
    INSERT INTO t_sale_str
      (id_sale_str, id_sale, id_ware, qty, discount)
    VALUES
      (p_id_sale_str, p_id_sale, p_id_ware, p_qty, pp_discount);
    SELECT t_sale_str.price INTO v_price FROM t_sale_str,t_sale WHERE t_sale_str.id_sale=t_sale.id_sale and t_sale_str.id_sale=p_id_sale;
    IF v_price <> p_price*(100-p_discount)/100 OR  v_price IS NULL THEN
      v_result:=1; 
    END IF; 
    RETURN  v_result;
    EXCEPTION 
      WHEN OTHERS THEN   
      v_result:=1;  
      dbms_output.put_line(dbms_utility.format_error_stack);          
      RETURN  v_result;
  END; 
  
  --TASK_4.1
  FUNCTION f_test_summa_str(p_id_sale_str t_sale_str.id_sale_str%TYPE)
    RETURN INTEGER IS
    v_result INTEGER;
    v_summa  t_sale_str.summa%TYPE;
    v_pdq    t_sale_str.summa%TYPE;
    v_nds    t_sale_str.nds%TYPE;
    v_pdqn   t_sale_str.nds%TYPE;
  BEGIN
    v_result := 0;
    SELECT t.price * (100 - t.discount) / 100 * t.qty,
           ROUND(t.price * (100 - t.discount) / 100 * t.qty*18/118,2),
           NVL(t.summa, 0),
           NVL(t.nds, 0)
      INTO v_pdq, v_pdqn, v_summa, v_nds
      FROM t_sale_str t
     WHERE t.id_sale_str = p_id_sale_str;
    IF v_summa <> v_pdq OR v_nds<>v_pdqn THEN
      v_result := 1;
    END IF;
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(dbms_utility.format_error_stack);
      v_result := 1;
      RETURN v_result;
  END;
  
  --TASK_4.2
  FUNCTION f_test_change_qty(
                        p_id_sale_str   t_sale_str.id_sale_str%TYPE,
                        p_qty           t_sale_str.qty%TYPE            
                        )
    RETURN INTEGER IS
    v_result INTEGER;
    v_summa  t_sale_str.summa%TYPE;
    v_pdq    t_sale_str.summa%TYPE;
    v_nds    t_sale_str.nds%TYPE;
    v_pdqn   t_sale_str.nds%TYPE;
  BEGIN
    v_result:=0;  
    UPDATE t_sale_str t SET t.qty=p_qty WHERE t.id_sale_str=p_id_sale_str;          
   SELECT t.price * (100 - t.discount) / 100 * t.qty,
           ROUND(t.price * (100 - t.discount) / 100 * t.qty*18/118,2),
           NVL(t.summa, 0),
           NVL(t.nds, 0)
      INTO v_pdq, v_pdqn, v_summa, v_nds
      FROM t_sale_str t
     WHERE t.id_sale_str = p_id_sale_str;
   IF v_summa <> v_pdq OR v_nds<>v_pdqn  THEN      
      v_result:=1; 
    END IF; 
    RETURN  v_result;
    EXCEPTION 
      WHEN OTHERS THEN   
      dbms_output.put_line(dbms_utility.format_error_stack);
       v_result:=1;      
      RETURN  v_result; 
  END; 
    
  --TASK_4.3
  FUNCTION f_test_change_discount(
                        p_id_sale            t_sale.id_sale%TYPE,
                        p_discount           t_sale.discount%TYPE            
                        )
    RETURN INTEGER IS
    v_result INTEGER;    
    v_summa  t_sale_str.summa%TYPE;   
    v_nds    t_sale_str.nds%TYPE; 
    v_summa_str    t_sale_str.summa%TYPE;
    v_nds_str   t_sale_str.nds%TYPE;
  BEGIN
    v_result:=0; 
    UPDATE t_sale t SET t.discount=p_discount WHERE t.id_sale=p_id_sale;       
    SELECT t.summa, t.nds
      INTO v_summa, v_nds
      FROM t_sale t
     WHERE t.id_sale = p_id_sale; 
    SELECT SUM(t.summa), SUM(t.nds)
      INTO v_summa_str, v_nds_str
      FROM t_sale_str t
     WHERE t.id_sale = p_id_sale;
     IF v_summa<>v_summa_str OR v_nds<>v_nds_str THEN 
       v_result:=1;
       END IF; 
    RETURN  v_result;
    EXCEPTION 
      WHEN OTHERS THEN   
      dbms_output.put_line(dbms_utility.format_error_stack);
       v_result:=1;      
      RETURN  v_result; 
  END;
  
  --TASK_5
  FUNCTION f_test_add_price(p_id_sale_str       t_sale_str.id_sale_str%TYPE,                          
                            p_id_price_ware t_price_ware.id_price_ware%TYPE,
                            p_price t_price_ware.price%TYPE
                            )
    RETURN INTEGER IS
    v_result INTEGER;
    v_price  t_price_ware.price%TYPE;
    v_id_sale t_sale.id_sale%TYPE;
  BEGIN
    v_result:=0; 
    UPDATE  t_price_ware t SET t.price=p_price WHERE t.id_price_ware=p_id_price_ware;
    SELECT t_sale_str.price/(100 -t_sale.discount)*100,t_sale.id_sale
      INTO v_price,v_id_sale
      FROM t_sale_str, t_sale
     WHERE t_sale_str.id_sale = t_sale.id_sale
       AND t_sale_str.id_sale_str = p_id_sale_str;
    IF v_price <> p_price OR v_price IS NULL THEN
      v_result := 1;
    END IF;  
    RETURN  v_result;
  END;
    
    FUNCTION f_test_t_rest(p_id_supply t_supply.id_supply%TYPE,p_state_id t_state.id_state%TYPE)
      RETURN INTEGER IS
      v_result INTEGER;
      TYPE Rest_T IS TABLE OF VARCHAR2(5000);
      TV Rest_T;
      TR Rest_T;
    BEGIN
      v_result := 0;
      SELECT *
        BULK COLLECT
        INTO TV
        FROM (SELECT t.id_ware || ' ' || (t.qty + SIGN(p_state_id-1.5)*ts.qty)
                FROM t_rest t, t_supply_str ts
               WHERE ts.id_supply = p_id_supply
                 AND t.id_ware = ts.id_ware);
      UPDATE t_supply t SET t.id_state = p_state_id WHERE t.id_supply = p_id_supply;
      SELECT *
        BULK COLLECT
        INTO TR
        FROM (SELECT t.id_ware || ' ' || t.qty
                FROM t_rest t
               WHERE t.id_ware IN
                     (SELECT t.id_ware
                        FROM t_supply_str t
                       WHERE t.id_supply = p_id_supply));
      IF TV <> TR  OR TV IS EMPTY OR  TR IS EMPTY THEN
        v_result := 1;
      END IF;
      UPDATE t_supply t SET t.id_state = 1 WHERE t.id_supply = p_id_supply;
      RETURN v_result;
    END;
  
    FUNCTION f_test_t_rest_sale (p_id_sale t_sale.id_sale%TYPE,p_state_id t_sale.id_state%TYPE)
      RETURN INTEGER IS
      v_result INTEGER;
      TYPE Rest_T IS TABLE OF VARCHAR2(5000);
      TV Rest_T;
      TR Rest_T;    
    BEGIN
      v_result:=0; 
      SELECT *
        BULK COLLECT
        INTO TV
        FROM (SELECT t.id_ware || ' ' || (t.qty - SIGN(p_state_id-1.5)*ts.qty)
                FROM t_rest t, t_sale_str ts
               WHERE ts.id_sale = p_id_sale
                 AND t.id_ware = ts.id_ware);    
      UPDATE t_sale t SET t.id_state = p_state_id WHERE t.id_sale = p_id_sale;    
      SELECT *
        BULK COLLECT
        INTO TR
        FROM (SELECT t.id_ware || ' ' || t.qty
                FROM t_rest t
               WHERE t.id_ware IN
                     (SELECT t2.id_ware
                        FROM t_sale_str t2
                       WHERE t2.id_sale = p_id_sale));
      IF TV <> TR  OR TV IS EMPTY OR  TR IS EMPTY THEN
        v_result := 1;
      END IF;   
      UPDATE t_sale t SET t.id_state = 1 WHERE t.id_sale = p_id_sale;    
      RETURN v_result;      
    END;    
  
  PROCEDURE testrun AS
  BEGIN 
     delete_test_data;
     add_test_data; 
     dbms_output.put_line('TASK_1.1 ' || f_test_supply_str_summa_nds(101, 'Test-1', DATE '2018-09-01',1,101, 1, 1, 2, 20)); 
     dbms_output.put_line('TASK_1.2 ' || f_test_supply_summa_nds(101));     
     dbms_output.put_line('TASK_2.1 ' || f_test_client_discount_nv(46, 1, 'Ivanov SS', 'Ivan', 'N',82, 82, DATE '2018-08-08',  21));
     dbms_output.put_line('TASK_2.2 ' || f_test_client_discount_nv(46, 1, 'Ivanov SS', 'Ivan', 'Y',82, 82, DATE '2018-08-08',  21));
     dbms_output.put_line('TASK_3. '  || f_test_price(99,DATE '2018-09-01',10,96,DATE '2018-09-01',DATE '2018-09-29',10,95,1,10,2));     
     dbms_output.put_line('TASK_4.1 ' || f_test_summa_str(95)); 
     dbms_output.put_line('TASK_4.2 ' || f_test_change_qty(95,15)); 
     dbms_output.put_line('TASK_4.3 ' || f_test_change_discount(99,15));     
     dbms_output.put_line('TASK_5. '  || f_test_add_price(95,96,16));
     dbms_output.put_line('TASK_6. '  || f_test_t_rest(101,2)); 
     dbms_output.put_line('TASK_6.1 ' || f_test_t_rest_sale(99,2));
     COMMIT;     
  END;    
END test;
