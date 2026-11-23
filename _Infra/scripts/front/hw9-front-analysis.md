## ДЗ 9. Анализ БД Front

Я начал смотреть таблицы и понял, что есть очень много пустых таблиц.

Поэтому сначала узнал имена таблиц, где есть хотя бы 1 запись

## Запрос, чтобы получить все непустые таблицы

```sql
select t.name 
from sys.dm_db_partition_stats AS p
join sys.tables as t on p.object_id = t.object_id
join sys.schemas as s on t.schema_id = s.schema_id
where p.index_id IN (0, 1)
having sum(p.row_count) > 0
```

## Анализ закупки продукции

видим, что таблица vendors (поставщики) не пустая. В это



