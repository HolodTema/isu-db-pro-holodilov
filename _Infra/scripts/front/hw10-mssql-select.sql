-- продукты
-- это обычный select 
select 
    id as id,
    productid as external_id,
    description as name,
    flaging as flagging
from dbo.[product]
order by id;

-- а это уже select, который
-- на выход дает строку sql кода 
-- с конструкцией insert into, чтобы
-- вставить данные в postgres
select 'insert into products(id, external_id, name, flagging, created_at) values ('''
    + cast(id as varchar(max)) + ''', '''
    + cast(productid as varchar(max)) + ','  
    + cast( as varchar(max))   + ');' 
    as [sql]
 from [size] 


