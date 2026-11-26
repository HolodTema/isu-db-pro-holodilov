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
-- flaging, description может быть null, поэтому оборачиваю в case-when или coalesce
select 'insert into products(external_id, name, flagging) values ('
    + cast(id as varchar(max)) + ', '
    + case when description is null then 'null' else '''' + description + '''' end + ', '
    + coalesce(cast(flaging as varchar(max)), 'null')   + ');' 
from dbo.product
order by id;



-- аналогично для категорий
select 'insert into categories(external_id, name, parent_id) values ('
    + cast(id as varchar(max)) + ', '
    + case when description is null then 'null' else '''' + description + '''' end + ', '
    + coalesce(cast(ParentID as varchar(max)), 'null') + ');'
from dbo.category
order by id;



-- аналогично для единиц измерения
select 'insert into units(external_id, name, conversion_factor) values ('
    + cast(ID as varchar(max)) + ', '
    + case when description is null then 'null' else '''' + description + '''' end + ', '
    + coalesce(cast(portionrate as varchar(max)), 'null') + ');'
from dbo.size
order by ID;

select 'insert into base_units(external_id, short_name, full_name) values ('
    + cast(t2.ID as varchar(max)) + ', '
    + case when t2.ShortName is null then 'null' else '''' + t2.ShortName + '''' end + ', '
    + case when t2.Description is null then 'null' else '''' + t2.Description + '''' end + ');'
from dbo.size t1
inner join dbo.bm_classifierSizes t2 on t1.BaseSizeID = t2.ID
group by t2.ID, t2.ShortName, t2.Description
order by t2.ID;



-- аналогично для поставщиков
select 'insert into vendors(external_id, name, parent_id, parent_name) values ('
    + cast(t1.id as varchar(max)) + ', '
    + case when t1.clientid is null then 'null' else '''' + t1.clientid + '''' end + ', '
    + coalesce(cast(t1.clientgroup as varchar(max)), 'null') + ', '
    + case when t2.description is null then 'null' else '''' + t2.description + '''' end + ');'
from dbo.vendors t1
left join dbo.vendorgroup t2 on t2.vendorgroupid = t1.clientgroup
order by t1.id;



-- склады
select 'insert into storages(external_id, name) values ('
    + cast(id as varchar(max)) + ', '
    + case when description is null then 'null' else '''' + description + '''' end + ');'
from dbo.storages
order by id;



-- филиалы компаний
select 'insert into departments(external_id, short_name, full_name, inn_state_id, kpp_state_id, ogrn_state_id) values ('
    + cast(ID as varchar(max)) + ', '
    + case when ShortName is null then 'null' else '''' + ShortName + '''' end + ', '
    + case when CompanyName is null then 'null' else '''' + CompanyName + '''' end + ');'
from dbo.bm_Companies
order by ID;



-- сотрудники
select 'insert into staff(external_id, last_name, first_name, middle_name) values ('
    + cast(personid as varchar(max)) + ', '
    + case when nullif(lastname, '') is null then 'null' else '''' + lastname + '''' end + ', '
    + case when nullif(firstname, '') is null then 'null' else '''' + firstname + '''' end + ', '
    + case when nullif(middlename, '') is null then 'null' else '''' + middlename + '''' end + ');'
from dbo.personnel
order by personid;



-- типы операций с продуктами на складе
select 'insert into storage_operation_types(external_id, name, factor) values ('
    + cast(ID as varchar(max)) + ', '
    + case when nullif(description, '') is null then 'null' else '''' + description + '''' end + ', '
    + coalesce(cast(Factor as varchar(max)), 'null') + ');'
from dbo.bm_StorageOperationsType
order by ID;



-- операции с продуктами на складе
select 'insert into storage_operations(external_id, product_id, vendor_id, storage_id, unit_id, operation_type_id, price, amount) values ('
    + cast(ID as varchar(max)) + ', '
    + coalesce(cast(ProductID as varchar(max)), 'null') + ', '
    + coalesce(cast(VendorID as varchar(max)), 'null') + ', '
    + coalesce(cast(StorageID as varchar(max)), 'null') + ', '
    + coalesce(cast(RangeID as varchar(max)), 'null')  + ', '
    + coalesce(cast(OperationID as varchar(max)), 'null')  + ', '
    + coalesce(cast(Price as varchar(max)), 'null')  + ', '
    + coalesce(cast(Amount as varchar(max)), 'null')  + ');'
from dbo.bm_StorageOperations
order by ID;
 


-- причины исчезновения продуктов
select 'insert into product_loss_reasons(external_id, name) values ('
    + cast(ID as varchar(max)) + ', '
    + case when nullif(Description, '') is null then 'null' else '''' + Description + '''' end + ');'
from dbo.bm_ReasonDebit
order by ID;

