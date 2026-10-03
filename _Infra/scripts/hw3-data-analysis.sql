-- каждый юзер должен иметь одинаковое число пачек
-- если все верно, то в столбце amount_bundles_per_user все значения
-- равны между собой
select * from users t1
left join
(
	select t1.user_id, count(*) as amount_bundles_per_user 
	from measurement_bundles t1
	group by t1.user_id
) as t2 on t1.id = t2.user_id;


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


-- проверяем, что все параметры с типом temperature
-- имеют значения в диапазоне от -58 до +58
-- если все верно, то вернется пустая таблица.
--
-- То есть запрос получает все параметры с типом temperature,
-- и потом отбирает те, у которых значение НЕ В НОРМЕ. Поэтому
-- пустая таблица - верный результат.
select t1.value from measurement_params t1
inner join
(
	select t1.id from measurement_param_types t1
	where t1.name = 'temperature'
) as t2 on t1.measurement_param_type_id = t2.id
where value < -58 or value > 58;


-- проверяем, что все параметры с типом pressure
-- имеют значения в диапазоне от 500 до 900
-- если все верно, то вернется пустая таблица.
--
-- То есть запрос получает все параметры с типом pressure,
-- и потом отбирает те, у которых значение НЕ В НОРМЕ. Поэтому
-- пустая таблица - верный результат.
select t1.value from measurement_params t1
inner join
(
	select t1.id from measurement_param_types t1
	where t1.name = 'pressure'
) as t2 on t1.measurement_param_type_id = t2.id
where value < 500 or value > 900;


-- проверяем, что все параметры с типом wind_direction
-- имеют значения в диапазоне от 0 до 59
-- если все верно, то вернется пустая таблица.
--
-- То есть запрос получает все параметры с типом wind_direction,
-- и потом отбирает те, у которых значение НЕ В НОРМЕ. Поэтому
-- пустая таблица - верный результат.
select t1.value from measurement_params t1
inner join
(
	select t1.id from measurement_param_types t1
	where t1.name = 'wind_direction'
) as t2 on t1.measurement_param_type_id = t2.id
where value < 0 or value > 59;


-- проверяем, что все параметры с типом wind_speed
-- имеют значения в диапазоне от 0 до 15
-- если все верно, то вернется пустая таблица.
--
-- То есть запрос получает все параметры с типом wind_speed,
-- и потом отбирает те, у которых значение НЕ В НОРМЕ. Поэтому
-- пустая таблица - верный результат.
select t1.value from measurement_params t1
inner join
(
	select t1.id from measurement_param_types t1
	where t1.name = 'wind_speed'
) as t2 on t1.measurement_param_type_id = t2.id
where value < 0 or value > 15;


-- проверяем, что все параметры с типом bullet_variance
-- имеют значения в диапазоне от 0 до 150
-- если все верно, то вернется пустая таблица.
--
-- То есть запрос получает все параметры с типом bullet_variance,
-- и потом отбирает те, у которых значение НЕ В НОРМЕ. Поэтому
-- пустая таблица - верный результат.
select t1.value from measurement_params t1
inner join
(
	select t1.id from measurement_param_types t1
	where t1.name = 'bullet_variance'
) as t2 on t1.measurement_param_type_id = t2.id
where value < 0 or value > 150;


-- проверяем, что физическая величина Длина имеет только единицы измерения,
-- связанные с длиной. Все верно если результатом будет одно имя - метр.
select t1.name from measurement_units t1
inner join
(
	select t1.id from physical_quantities t1
	where t1.name = 'Длина'
) as t2 on t1.physical_quantity_id = t2.id;


-- проверяем, что физическая величина Давление имеет только единицы измерения,
-- связанные с давлением. Все верно если результатом будет одно имя - миллиметр ртутного столба.
select t1.name from measurement_units t1
inner join
(
	select t1.id from physical_quantities t1
	where t1.name = 'Давление'
) as t2 on t1.physical_quantity_id = t2.id;


-- проверяем, что физическая величина Температура имеет только единицы измерения,
-- связанные с температурой. Все верно если результатом будет одно имя - градус цельсия.
select t1.name from measurement_units t1
inner join
(
	select t1.id from physical_quantities t1
	where t1.name = 'Температура'
) as t2 on t1.physical_quantity_id = t2.id;


-- проверяем, что физическая величина Скорость имеет только единицы измерения,
-- связанные со скоростью. Все верно если результатом будет одно имя - метр в секунду.
select t1.name from measurement_units t1
inner join
(
	select t1.id from physical_quantities t1
	where t1.name = 'Скорость'
) as t2 on t1.physical_quantity_id = t2.id;


-- проверяем, что физическая величина Угол имеет только единицы измерения,
-- связанные со углом. Все верно если результатом будет одно имя - градус.
select t1.name from measurement_units t1
inner join
(
	select t1.id from physical_quantities t1
	where t1.name = 'Угол'
) as t2 on t1.physical_quantity_id = t2.id;


-- проверим, что если тип параметра называется altitude или bullet_variance, то он измеряется в метрах
-- все верно, если результатом будет таблица с двумя записями altitude и bullet_variance
select t1.name from measurement_param_types t1
inner join
(
	select t1.id from measurement_units t1 
	where t1.name = 'метр'
) as t2 on t1.measurement_unit_id = t2.id;


-- проверим, что если тип параметра называется temperature, то он измеряется в градусах Цельсия
-- все верно, если результатом будет таблица с одной записью temperature
select t1.name from measurement_param_types t1
inner join
(
	select t1.id from measurement_units t1 
	where t1.name = 'градус Цельсия'
) as t2 on t1.measurement_unit_id = t2.id;


-- проверим, что если тип параметра называется pressure, то он измеряется в миллиметрах ртутного столба
-- все верно, если результатом будет таблица с одной записью pressure
select t1.name from measurement_param_types t1
inner join
(
	select t1.id from measurement_units t1 
	where t1.name = 'мм рт. ст.'
) as t2 on t1.measurement_unit_id = t2.id;


-- проверим, что если тип параметра называется wind_direction, то он измеряется в градусах
-- все верно, если результатом будет таблица с одной записью wind_direction
select t1.name from measurement_param_types t1
inner join
(
	select t1.id from measurement_units t1 
	where t1.name = 'градус'
) as t2 on t1.measurement_unit_id = t2.id;


-- проверим, что если тип параметра называется wind_speed, то он измеряется в метрах в секунду
-- все верно, если результатом будет таблица с одной записью wind_speed
select t1.name from measurement_param_types t1
inner join
(
	select t1.id from measurement_units t1 
	where t1.name = 'метр в секунду'
) as t2 on t1.measurement_unit_id = t2.id;

