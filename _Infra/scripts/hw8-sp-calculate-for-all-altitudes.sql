-- вспомогательная функция, которая по таблице 2 рассчитывает среднее отклонение температуры
-- для определенной высоты и измеренной температуры
create or replace function get_average_temperature_variance(
	par_temperature numeric,
	par_altitude int
)
returns int
language 'plpgsql'
as $body$
declare
	var_interpolation_type interpolation_type;
	var_virtual_temperature_variance int;
	var_header_values int[];
	var_certain_header_index int;
	var_tens_header_index int;
	var_units_header_index int;
	var_is_virtual_temperature_variance_negative boolean;
	var_row_values int[];
	var_result int;
begin
	-- в таблице 2 заголовком является отклонение виртуальной температуры (virtual_temperature_variance)
	-- оно считается как измеренная температура плюс виртуальная поправка их таблицы 1 минус константа 15.9
	-- c прошлых ДЗ была функция расчета интерполяции (для виртуальной поправки температуры и таблицы 1)
	var_interpolation_type := public.get_interpolation_type(par_temperature);
	var_virtual_temperature_variance := round(public.calculate_interpolation(par_temperature, var_interpolation_type) - 15.9::numeric);

	-- итого у нас есть отклонение виртуальной температуры var_virtual_temperature_variance - значение в заголовке таблицы 2 
	-- теперь надо взять для нужной высоты строчку из таблицы 2 либо отрицательную, либо положительную
	-- в зависимости от того, является ли отклонение виртуальной температуры отрицательным или положительным
	var_is_virtual_temperature_variance_negative := var_virtual_temperature_variance < 0;
	-- в plpgsql индекс массивов с единицы по умолчанию
	-- то есть я проверяю, что строка в corrections это строка отрицательных значений, если первый элемент в строке отрицательный
	-- ибо все элементы отрицательные в этой строке отрицательные по ТЗ, а значит и первый отрицательный
	select t1.row_values 
	into var_row_values
	from corrections t1
	inner join correction_headers t2 on t1.correction_header_id = t2.id
	inner join correction_header_types t3 on t2.correction_header_type_id = t3.id
	inner join const_altitudes t4 on t1.const_altitude_id = t4.id
	where t3.description = 'Таблица 2, Температура' 
	and t4.altitude = par_altitude 
	and (
		(var_is_virtual_temperature_variance_negative and t1.row_values[1] < 0)
		or (not(var_is_virtual_temperature_variance_negative) and t1.row_values[1] >= 0)
	);
		
	-- в таблице 2 и для отрицательных и для положительных температур заголовок температур одиноаковый
	-- поэтому можно сделать limit 1
	select t1.header_values 
	into var_header_values
	from correction_headers t1
	inner join correction_header_types t2 on t1.correction_header_type_id = t2.id
	where t2.description = 'Таблица 2, Температура'
	limit 1;
	-- теперь нужно проверить, есть ли наша температура в var_header_values
	-- если да, получим индекс var_certain_header_index, используя array_position
	-- если нет, то будем искать уже 2 индекса для разряда десятков и разряда единиц
	--
	-- PS. массив var_header_values всегда отсортирован, то есть можно было бы применить бинарный поиск
	-- вместо array_position() и находить индекс не за О(N), а за О(logN)
	-- но как будто бы делать бин-поиск в plpgsql сложно...
	--
	-- в var_header_values все значения положительные. Мы уже получили var_row_values выше, поэтому знак
	-- нашей var_virtual_temperature_variance можно отбросить
	var_virtual_temperature_variance := abs(var_virtual_temperature_variance)
	
	var_certain_header_index := array_position(var_header_values, var_virtual_temperature_variance)
	if var_certain_header_index is null then
		-- нашей температуры нет в заголовке, надо найти индексы для разряда десятков и единиц
		var_tens_header_index := array_position(var_header_values, var_virtual_temperature_variance / 10 * 10);
		var_units_header_index := array_position(var_header_values, var_virtual_temperature_variance % 10);
		var_result := var_row_values[var_tens_header_index] + var_row_values[var_units_header_index];
	else
		var_result := var_row_values[var_certain_header_index];
	end if;

	return var_result;                                                      
end;	
$body$;








create or replace function get_average_wind_speed(
	par_temperature numeric,
	par_altitude int
)
returns int
language 'plpgsql'
as $body$
declare
begin
end;	
$body$;




create or replace storage procedure sp_calculate_for_all_altitudes(
	params measurement_params_t,
	equipment_type_id int
)
language plpgsql
as $$
declare 
	
begin
	-- итоговая таблица, куда записываются значения для всех высот
	drop table if exists final_calculation_results
	create table final_calculation_results(
		altitude int primary key,
		average_temperature_variance int not null,
		average_wind_direction int not null,
		average_wind_speed int not null
	);


	for altitude in select const_altitudes.altitude from const_altitudes
    loop
        insert into final_calculation_results(
			altitude, 
			average_temperature_variance, 
			average_wind_direction, 
			average_wind_speed
		) values
		(
			altitude, 
			get_average_temperature_variance(params.temperature, altitude),
		)
    end loop;
	
end;
$$;

