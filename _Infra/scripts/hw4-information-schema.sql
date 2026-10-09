-- row_number() нумерует строки итоговой таблицы, предварительно
-- отсортировав ее по какому-то столбцу. В нашем случае мы 
-- отсортировали записи по name и пронумеровали
--
-- union all здесь это как join но по вертикали
-- то есть мы сделали 2 select-подзапроса, у которых столбцы
-- в итоге одинаковы. И поэтому мы можем сделать union all
select
    row_number() over (order by name) as number,
    name,
    type
from (
    select table_name as name, 'Таблица' as type
    from information_schema.tables
    where table_catalog = 'holodilov_artillery_db'
        and table_schema = 'public'
		and table_type = 'BASE TABLE'
    union all
    select sequence_name as name, 'Последовательность' as type
    from information_schema.sequences
    where sequence_catalog = 'holodilov_artillery_db' 
        and sequence_schema = 'public'
) as t
order by number;

