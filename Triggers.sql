
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




