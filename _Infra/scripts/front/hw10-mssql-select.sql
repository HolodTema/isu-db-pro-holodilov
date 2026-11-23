-- продукты
-- это обычный select 
select 
    id as id,
    productid as external_id,
    description as name,
    flaging as flagging
from dbo.product
order by id;

-- а это уже select, который
-- на выход дает строку sql кода 
-- с конструкцией insert into, чтобы
-- вставить данные в postgres
--
-- в sql нет экранирования кавычки через обратный слеш как в других ЯП \'
-- для экранирования кавычки надо написать две кавычки ''
--
-- flaging, description может быть null, при этом если null, то надо 
-- этот null вернуть без кавычек вокруг. Поэтому везде куча конструкций case-when
select 'insert into products(external_id, name, flagging) values ('
    + cast(id as varchar(max)) + ', '''
    + coalesce(description, 'null') + ''', '
    + coalesce(cast(flaging as varchar(max)), 'null')   + ');' 
from dbo.product
order by id;



-- аналогично для категорий
select 'insert into categories(external_id, name, parent_id) values ('
    + cast(id as varchar(max)) + ', '''
    + coalesce(description, 'null') + ''', '
    + coalesce(cast(ParentID as varchar(max)), 'null') + ');'
from dbo.category
order by id;



-- аналогично для единиц измерения
select 'insert into units(external_id, name, conversion_factor) values ('
    + cast(ID as varchar(max)) + ', '''
    + coalesce(description, 'null') + ''', '
    + coalesce(cast(portionrate as varchar(max)), 'null') + ');'
from dbo.size
order by ID;



-- аналогично для поставщиков
select 'insert into vendors(external_id, name, parent_id, parent_name) values ('
    + cast(v.id as varchar(max)) + ', '''
    + replace(v.clientid, '''', '''''') + ''', '
    + coalesce(cast(v.clientgroup as varchar(max)), 'null') + ', '
    + coalesce('''' + replace(g.[description], '''', '''''') + '''', 'null') + ');'
from dbo.vendors 
left join dbo.vendorgroup on dbo.vendorgroup.vendorgroupid = dbo.vendors.clientgroup
order by dbo.vendors.id;



-- склады
select 'insert into storages(external_id, name) values ('
    + cast(id as varchar(max)) + ', '''
    + coalesce(description, 'null') + ''');'
from dbo.storages
order by id;



-- филиалы компаний
-- столбец KPP может иметь пустые строки или null - поэтому оборачиваем в nullif()
select 'insert into departments(external_id, short_name, full_name, inn_state_id, kpp_state_id, ogrn_state_id) values ('
    + cast(ID as varchar(max)) + ', '''
    + coalesce(ShortName, 'null') + ''', '''
    + coalesce(CompanyName, 'null') + ''', '''
    + coalesce(INN, 'null') + ''', '''
    + coalesce(nullif(KPP, ''), 'null') + ''', '''
    + coalesce(OGRN, 'null') + ''');'
from dbo.bm_Companies
order by ID;


