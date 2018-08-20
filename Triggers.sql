CREATE OR REPLACE  TRIGGER changes_discount
  before update or delete or insert on t_sale
  for each row

declare
  t_is_vip t_client.is_vip%TYPE;
  no_sales   EXCEPTION;
  no_changes EXCEPTION;

BEGIN
  if :old.id_state = 1 or :old.id_state is null then
  
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
  
/*  if updating then
    update t_sale_str t
       set t.disc_price = t.price * t.discount * :new.discount
     where t.id_sale = :new.id_sale;
  end if;*/   

EXCEPTION
  WHEN no_sales THEN
    raise_application_error(-20001, 'Sale no more 20%');
  WHEN no_changes THEN
    raise_application_error(-20002, 'No changes actual documets%');
END;

CREATE OR REPLACE  TRIGGER price_sale
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
    select tpw.price
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
create or replace  trigger summa_sale_str
  before update or insert on t_sale_str
  for each row
begin
  


  :new.disc_price := :new.price - (:new.price * :new.discount / 100);
  :new.summa      := (:new.price -
                     (:new.price * :new.discount / 100)) * :new.qty;
  :new.nds        := (:new.price -
                     (:new.price * :new.discount / 100)) * :new.qty * 118 / 100;

  pkg_around_mutation.bUpdPainters := true;
  pkg_around_mutation.t_id_sale    := :new.id_sale;

end;


create or replace  trigger T_summa_t_supply
after update or delete or insert
on t_supply_str
begin
  pkg_around_mutation.p_summa_t_supply;
end T_summa_t_supply;

create or replace  trigger T_summa_t_supply_str
  before update or delete or insert on t_supply_str
  for each row

begin
   
    :new.summa                       := :new.price  * :new.qty;
    :new.nds                         := :new.price * :new.qty * 18 / 118;
    pkg_around_mutation.bUpdPainters := true;
  
    if (inserting or updating) then
      pkg_around_mutation.t_id_supply := :new.id_supply;
    else
      pkg_around_mutation.t_id_supply := :old.id_supply;
    end if;
    change_count_ware(:new.id_ware, :new.qty);
end Tsumma_t_supply;

create or replace  trigger T_summa_t_sale
after update or delete or insert
on t_sale_str
begin
  pkg_around_mutation.p_summa_t_sale;
end ;

create or replace noneditionable package body pkg_around_mutation
is
  procedure p_summa_t_supply
  is
  t_summa t_supply.summa%TYPE;
  t_nds t_supply.nds%type;
  
  begin
    if bUpdPainters then
       bUpdPainters := false;

      select sum(summa),sum(nds)
        into t_summa,t_nds
        from t_supply_str z where z.id_supply=t_id_supply;

      update t_supply ts
         set ts.summa = t_summa, ts.nds=t_nds
      where ts.id_supply = t_id_supply;
    end if;
  end;
  
  --процедура для расчета суммы и ндс таблицы t_sale
  procedure p_summa_t_sale
  is
  t_summa_sale t_sale.summa%TYPE;
  t_nds_sale t_sale.nds%type;
  
  begin
    if bUpdPainters then
       bUpdPainters := false;

      select sum(summa),sum(nds)
        into t_summa_sale,t_nds_sale
        from t_sale_str z where z.id_sale=t_id_sale;

      update t_sale ts
         set ts.summa = t_summa_sale, ts.nds=t_nds_sale
      where ts.id_sale =t_id_sale;
    end if;
  end;  
  
end pkg_around_mutation;

create or replace noneditionable package pkg_around_mutation
is
  bUpdPainters boolean;
  t_id_supply number;
  t_id_sale number;
  procedure p_summa_t_supply;
  procedure p_summa_t_sale;
end pkg_around_mutation;


