CREATE OR REPLACE NONEDITIONABLE PACKAGE BODY test IS
-- TASK_1
  FUNCTION f_test_supply_summa_nds(p_id_supply t_supply.id_supply%TYPE ,
                                   p_code t_supply.code%TYPE,
                                   p_dt t_supply.dt%TYPE,
                                   p_id_supplier t_supply.id_supplier%TYPE,                             
                                   p_id_supply_str t_supply_str.id_supply_str%TYPE,                                
                                   p_num t_supply_str.num%TYPE,
                                   p_id_ware t_supply_str.id_ware%TYPE,
                                   p_qty t_supply_str.qty%TYPE,
                                   p_price t_supply_str.price%TYPE) RETURN INTEGER IS
    v_result INTEGER;
    l_summa  t_supply.summa%TYPE;
    l_nds    t_supply.nds%TYPE;
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
      INTO l_summa, l_nds
      FROM t_supply_str
     WHERE id_supply_str = p_id_supply_str;
    IF NVL(l_summa, 0) <> p_price*p_qty  OR NVL(l_nds, 0) <> ROUND(p_qty*p_price* 18 / 118, 2) THEN
      v_result := 1;            
    END IF;    
    SELECT summa, nds
      INTO l_summa, l_nds
      FROM t_supply
     WHERE id_supply = 101;
    IF NVL(l_summa, 0) <> p_price*p_qty OR NVL(l_nds, 0) <> ROUND(p_price*p_qty* 18 / 118, 2) THEN
      v_result := 1;
    END IF;
    DELETE FROM t_supply_str t WHERE t.id_supply_str in (101);
    DELETE FROM t_supply t WHERE t.id_supply in (101);
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
  
  --TASK_4
  FUNCTION t_test_discount_sale(p_id_sale      t_sale.id_sale%TYPE,
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
    v_summa t_sale_str.summa%TYPE;
    v_price t_sale_str.price%TYPE;     
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
    UPDATE t_sale_str  t set t.qty=78787 where t.id_sale_str=p_id_sale_str;
    
    SELECT t_sale_str.summa, t_sale_str.price INTO v_summa, v_price FROM t_sale_str WHERE t_sale_str.id_sale_str=p_id_sale_str;
    IF v_summa <> v_price*(100-pp_discount)/100*78787 OR  v_summa IS NULL THEN      
      v_result:=1; 
    END IF;  
  DELETE FROM t_sale_str t WHERE t.id_sale_str=p_id_sale_str;
  DELETE FROM t_sale t WHERE t.id_sale=p_id_sale;
  DELETE FROM t_price_ware t WHERE t.id_price_ware=p_id_price_ware;
    RETURN  v_result;
    EXCEPTION 
      WHEN OTHERS THEN   
      dbms_output.put_line(dbms_utility.format_error_stack);
       v_result:=1;      
      RETURN  v_result; 
  END;
  
 --TASK_3
  FUNCTION t_test_price(p_id_sale      t_sale.id_sale%TYPE,
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
  DELETE FROM t_sale_str t WHERE t.id_sale_str=p_id_sale_str;
  DELETE FROM t_sale t WHERE t.id_sale=p_id_sale;
  DELETE FROM t_price_ware t WHERE t.id_price_ware=p_id_price_ware;   
    RETURN  v_result;
    EXCEPTION 
      WHEN OTHERS THEN   
      v_result:=1;  
      dbms_output.put_line(dbms_utility.format_error_stack);          
      RETURN  v_result;
  END; 
  
  PROCEDURE testrun AS
  BEGIN    
     dbms_output.put_line('TASK_1. ' || f_test_supply_summa_nds(101, 'Test-1', DATE '2018-09-01',1,101, 1, 1, 2, 20)); 
     dbms_output.put_line('TASK_2.Test discount >20 for not vip '|| f_test_client_discount_nv(46, 1, 'Ivanov SS', 'Ivan', 'N',82, 82, DATE '2018-08-08',  21));
     dbms_output.put_line('TASK_2.Test discount >20 for vip '||f_test_client_discount_nv(46, 1, 'Ivanov SS', 'Ivan', 'Y',82, 82, DATE '2018-08-08',  21));
     dbms_output.put_line('TASK_3. ' || t_test_price(99,DATE '2018-09-01',10,96,DATE '2018-09-01',DATE '2018-09-29',10,95,1,10,2));
     dbms_output.put_line('TASK_4. ' || t_test_discount_sale(99,DATE '2018-09-01',10,96,DATE '2018-09-01',DATE '2018-09-29',10,95,1,10,2));
  END;  
END test;
