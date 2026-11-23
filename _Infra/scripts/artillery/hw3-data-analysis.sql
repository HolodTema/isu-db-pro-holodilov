-- каждый юзер должен иметь одинаковое количество пачек
-- если все верно, то min = max
-- 
-- Как работает запрос. В подзапросе мы получаем 2 столбца: id-юзера и сколько пачек
-- имеет этот юзер. 
-- Во внешнем запросе мы получаем минимальное и максимальное значение из столбца с 
-- количеством пачек на юзера. То есть если min = max, то все значения в этом столбце
-- равны между собой. А значит все юзеры имеют одинаковое количество пачек.
select min(inner_t.amount_bundles_per_user), max(inner_t.amount_bundles_per_user)
from (
	select t1.id as user_id, count(t2.id) as amount_bundles_per_user from users t1
	left join measurement_bundles t2
	on t1.id = t2.user_id
	group by t1.id
) as inner_t;


-- каждый юзер должен иметь одинаковое количество измеренных им параметров
-- если все верно, то min = max
-- 
-- Как работает запрос. В подзапросе мы получаем 2 столбца: id-юзера и сколько парамтров
-- измерил этот юзер. 
-- Во внешнем запросе мы получаем минимальное и максимальное значение из столбца с 
-- количеством параметров на юзера. То есть если min = max, то все значения в этом столбце
-- равны между собой. А значит все юзеры имеют одинаковое количество параметров.
select min(inner_t.amount_params_per_user), max(inner_t.amount_params_per_user)
from
(
	select 
		t1.id as user_id,
		count(t3.id) as amount_params_per_user
	from users t1
	left join measurement_bundles t2 on t1.id = t2.user_id
	left join measurement_params t3 on t3.measurement_bundle_id = t2.id
	group by t1.id
) as inner_t;


-- проверяем, что не существует пачек, у которых нет параметров
-- если все верно, то запрос вернет пустую таблицу, что пустых пачек нет
select measurement_bundle_id, amount_params_per_bundle from
(
	select t1.measurement_bundle_id, count(*) as amount_params_per_bundle
	from measurement_params t1
	group by measurement_bundle_id
) where amount_params_per_bundle = 0;


-- проверяем, что каждая пачка содержит ровно 5 параметров
-- если все верно, то запрос вернет пустую таблицу, что пачек, у которых
-- число параметров не равно 5, нет
select measurement_bundle_id, amount_params_per_bundle from
(
	select t1.measurement_bundle_id, count(*) as amount_params_per_bundle
	from measurement_params t1
	group by measurement_bundle_id
) where amount_params_per_bundle != 5;


-- я в промпте просил Гигачат насоздавать 12 пачек. Проверим это для дальнейших запросов
-- должно быть число 12
select count(*) from measurement_bundles;


-- проверяем, что каждая пачка содержит ровно 1 параметр с типом парметра altitude
-- если все верно, то результатом будет таблица, где каждой из 12 пачек
-- соответствует 1 параметр с типом altitude
select t1.measurement_bundle_id, count(*) as amount_altitude_params_in_bundle from measurement_params t1
inner join
(
	select t1.id from measurement_param_types t1
	where t1.name = 'altitude'
) as t2 on t1.measurement_param_type_id = t2.id
group by t1.measurement_bundle_id;


-- проверяем, что каждая пачка содержит ровно 1 параметр с типом парметра temperature
-- если все верно, то результатом будет таблица, где каждой из 12 пачек 
-- соответствует 1 параметр с типом temperature
select t1.measurement_bundle_id, count(*) as amount_temperature_params_in_bundle from measurement_params t1
inner join
(
	select t1.id from measurement_param_types t1
	where t1.name = 'temperature'
) as t2 on t1.measurement_param_type_id = t2.id
group by t1.measurement_bundle_id;


-- проверяем, что каждая пачка содержит ровно 1 параметр с типом парметра pressure
-- если все верно, то результатом будет таблица, где каждой из 12 пачек 
-- соответствует 1 параметр с типом pressure
select t1.measurement_bundle_id, count(*) as amount_pressure_params_in_bundle from measurement_params t1
inner join
(
	select t1.id from measurement_param_types t1
	where t1.name = 'pressure'
) as t2 on t1.measurement_param_type_id = t2.id
group by t1.measurement_bundle_id;


-- проверяем, что каждая пачка содержит ровно 1 параметр с типом парметра wind_direction
-- если все верно, то результатом будет таблица, где каждой из 12 пачек
-- соответствует 1 параметр с типом wind_direction
select t1.measurement_bundle_id, count(*) as amount_wind_direction_params_in_bundle from measurement_params t1
inner join
(
	select t1.id from measurement_param_types t1
	where t1.name = 'wind_direction'
) as t2 on t1.measurement_param_type_id = t2.id
group by t1.measurement_bundle_id;


-- проверяем, что все параметры имеют значения в правильных диапазонах
-- если все значения всех параметров верны, то результатом будет пустая таблица.
--
-- если какие-то параметры имеют ненормальные значения, id, имя и тип таких параметров
-- будут в таблице
select
    t1.id as param_id,
    t2.name as param_type_name,
    t1.measurement_bundle_id as bundle_id,
    t1.value as param_value
from measurement_params t1
join measurement_param_types t2
    on t1.measurement_param_type_id = t2.id
where
    (t2.name = 'temperature' and (t1.value < -58 or t1.value > 58))
or (t2.name = 'pressure' and (t1.value < 500 or t1.value > 900))
or (t2.name = 'wind_direction' and (t1.value < 0   or t1.value > 59))
or (t2.name = 'wind_speed' and (t1.value < 0   or t1.value > 15))
or (t2.name = 'bullet_variance' and (t1.value < 0   or t1.value > 150));


-- проверяем, что физические величины связаны с правильными единицами измерения.
-- Например, что длина связана с метрами, а температура с градусами цельсия.
-- Все верно, если пары значений из unit_name и quantity_name верны.
select 
	t1.id as unit_id, 
	t1.name as unit_name, 
	t2.id as quantity_id, 
	t2.name as quantity_name 
from measurement_units t1
inner join physical_quantities t2
on t1.physical_quantity_id = t2.id;


-- проверим, что типы параметров связаны с правильными единицами измерения.
-- Например, что altitude связана с метрами, а wind_direction связано с углом.
-- Все верно, если пары значений из param_type_name и unit_name верны.
select 
	t1.id as param_type_id, 
	t1.name as param_type_name, 
	t2.id as unit_id, 
	t2.name as unit_name
from measurement_param_types t1
inner join measurement_units t2
on t1.measurement_unit_id = t2.id;

