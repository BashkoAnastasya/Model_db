
--триггер для расчета суммы и ндс в таблице t_supply_str
create or replace noneditionable trigger Tsumma_t_supply
before update or delete or insert on t_supply_str
for each row
begin
   :new.summa   := :new.price * :new.qty;
   :new.nds     := :new.price * :new.qty*18/118;
    pkg_around_mutation.bUpdPainters := true; 
        
 if (inserting or updating) then
    pkg_around_mutation.id_supply:=:new.id_supply; 
 else
     pkg_around_mutation.id_supply:=:old.id_supply; 
 end if;    
end Tsumma_t_supply;

--триггер для расчета суммы в таблице t_supply
create or replace noneditionable trigger tr_turtles_bu
after update or delete or insert
on t_supply_str
begin
  pkg_around_mutation.update_painters;
end tr_turtles_bu;

-- пакет для обхода мутации таблицы
create or replace noneditionable package pkg_around_mutation
is
  bUpdPainters boolean;
  id_supply number;
  procedure update_painters;
end pkg_around_mutation;

--процедура для обхода мутации таблиц
create or replace noneditionable package body pkg_around_mutation
is
  procedure update_painters
  is
  summa t_supply.summa%TYPE;
  begin
    if bUpdPainters then
       bUpdPainters := false;

      select sum(t.summa)
        into summa
        from t_supply_str t
       where t.id_supply = 1;

      update t_supply ts
         set ts.summa = summa
      where ts.id_supply = 1;
    end if;
  end;
end pkg_around_mutation;


--TASK-02
CREATE OR REPLACE NONEDITIONABLE TRIGGER changes_discount
  before update or delete or insert on t_sale
  for each row
    
declare
  t_is_vip t_client.is_vip%TYPE;
  no_sales  EXCEPTION;
  no_changes EXCEPTION;
  
BEGIN
  if :old.id_state = 1  or :old.id_state is null then
  
    select t_client.is_vip
      into t_is_vip
      from t_client
     where t_client.id_client = :new.id_client;
  
    if :new.discount > 20 and t_is_vip = 'N' then
      RAISE no_sales;
    end if;
  else
    RAISE no_changes;
  end if;
  
EXCEPTION
  WHEN no_sales THEN
    raise_application_error(-20001, 'Sale no more 20%');
  WHEN no_changes THEN
    raise_application_error(-20002, 'No changes actual documets%');
END;

--TASK-03
CREATE OR REPLACE NONEDITIONABLE TRIGGER price_sale
  before update or insert on t_sale_str
  for each row

declare
  no_changes EXCEPTION;
  t_id_state t_sale.id_state%Type;
  t_price    t_price_ware.price%Type;
BEGIN

  select t.id_state
    into t_id_state
    from t_sale t
   where t.id_sale = :new.id_sale;

  if t_id_state = 1 then
    select tpw.price * ts.discount / 100
      into t_price
      from t_price_ware tpw, t_sale ts
     where tpw.id_ware = :new.id_ware
       and ts.id_sale = :new.id_sale
       and ts.dt >= tpw.dt_beg
       and (ts.dt < tpw.dt_end or tpw.dt_end is null);
    :new.price := t_price;
  else
    RAISE no_changes;
  end if;

EXCEPTION
  WHEN no_changes THEN
    raise_application_error(-20002, 'No changes actual documets%');
END;




