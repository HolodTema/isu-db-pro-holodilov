do $$
    
    -- бинарный поиск
    --
    -- возвращает либо индекс вхождения целевого элемента в массив,
    -- либо (если вхождений нет) индекс элемента, после которого можно вставить
    -- целевой элемент в отсортированный массив, чтобы сохранить
    -- упорядоченность массива
    --
    -- на вход принимает отсортированный массив и целевой элемент
    -- временная сложность O(logN)
    create or replace function binary_search(
        par_arr int[],
        par_target int
    )
    returns int
    language 'plpgsql'
    as $body$
    declare
        low int;
        high int;
        mid int;
        n int;
    begin
        if par_arr is null then
            raise exception 'par_arr cannot be null';
        end if;

        if par_target is null then
            raise exception 'par_target cannot be null';
        end if;

        n := coalesce(array_length(par_arr, 1), 0);
        if n = 0 then
            raise exception 'par_arr cannot be empty';
        end if;

        -- если целевой элемент меньше первого (минимального) элемента
        -- массива, то целевой элемент можно вставить только в самое начало
        -- массива. То есть 0 (индексы в plpgsql идут с единицы, а нулевой индекс 
        -- будто бы идет перед первым элементом массива)
        if par_target < par_arr[1] then
            return 0;
        end if;

        -- аналогично, если целевой элемент больше последнего (максимального) 
        -- элемента массива, то целевой элемент надо вставить в конец массива,
        -- поэтому возвращаем последний индекс
        if par_target >= par_arr[n] then
            return n;
        end if;

        low := 1;
		high := n;
	    while low <= high loop
	        mid := (low + high) / 2;
            if par_arr[mid] = par_target then
                return mid;
            end if;
	        if par_arr[mid] < par_target then
	            low := mid + 1;
	        else
	            high := mid - 1;
	        end if;
	    end loop;
	    return high;
    end;
    $body$;
	


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
		where t3.description ilike '%таблица 2%' 
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
        -- здесь можно искать не точное совпадение строки, а слово в строке
        -- можно искать регистронезависимо через ilike
		where t2.description ilike '%таблица 2%'
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
		var_virtual_temperature_variance := abs(var_virtual_temperature_variance);
		
		var_certain_header_index := array_position(var_header_values, var_virtual_temperature_variance);
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
	
	
	
	-- вспомогательная функция, определяющая среднее направление ветра
	-- для определенной высоты и измеренного приземного направления ветра
	-- для ДМК и ВР одна и та же формула среднего направления ветра
	-- будут отличаться только строки в таблицах 3 для ДМК и ВР
	-- поэтому третьим параметром передается флаг par_is_dmk
	create or replace function get_average_wind_direction(
		par_wind_direction numeric,
		par_altitude int,
		par_is_dmk boolean
	)
	returns int
	language 'plpgsql'
	as $body$
	declare
		var_average_wind_increment int;
		var_result int;
	begin
		-- из таблицы 3 получаем приращение среднего ветра (var_average_wind_increment)
		select t1.row_values[1]
		into var_average_wind_increment from corrections t1
		inner join correction_headers t2 on t1.correction_header_id = t2.id
		inner join correction_header_types t3 on t2.correction_header_type_id = t3.id
		inner join const_altitudes t4 on t1.const_altitude_id = t4.id
		where t3.description ilike '%Направление среднего ветра%'
			and t4.altitude = par_altitude
			and (
				par_is_dmk and t2.equipment_type_id = 1 
				or not(par_is_dmk) and t2.equipment_type_id = 2
			);
		-- формула среднего направления ветра одинакова для ВР и ДМК
		-- мы к измеренному приземному направлению ветра прибалвляем приращение 
		-- среднего ветра из таблицы 3
		var_result := par_wind_direction + var_average_wind_increment;
		return var_result;
	end;	
	$body$;
	
	
	
	-- вспомогательная функция, определяющая среднюю скорость ветра
	-- для определенной высоты и измеренной скорости приземного ветра (ДМК)
	-- эта функция именно для ДМК, так как здесь не требуется интерполяция скорости 
	-- приземного ветра, так как в таблице 3 для ДМК значения в заголовке целые и 
	-- непрерывные от 3 до 15 метров в секунду.
	-- для ВР будет похожая функция, но с интерполяцией для дальности сноса пуль
	create or replace function get_average_wind_speed_dmk(
		par_wind_speed numeric,
		par_altitude int
	)
	returns int
	language 'plpgsql'
	as $body$
	declare
		var_header_values int[];
		var_row_values int[];
		var_wind_index int;
	begin
		-- если скорость измеренного приземного ветра меньше 3 метров в секунду,
		-- то можно сразу возвращать 0 по ТЗ
		if par_wind_speed < 3.0::numeric then
			return 0;
		end if;
		
		-- получаем массив int[] - строку из таблицы 3 для ДМК
		select t1.row_values
		into var_row_values 
		from corrections t1
		inner join correction_headers t2 on t1.correction_header_id = t2.id
		inner join correction_header_types t3 on t2.correction_header_type_id = t3.id
		inner join const_altitudes t4 on t1.const_altitude_id = t4.id
		where t3.description ilike '%Скорость среднего ветра%'
			and t4.altitude = par_altitude
			and t2.equipment_type_id = 1;
	
		-- получаем заголовок с измеренной приземной скоростью ветра
		-- из таблицы 3 для ДМК
		select t1.header_values
		into var_header_values
		from correction_headers t1
		inner join correction_header_types t2 on t1.correction_header_type_id = t2.id
		where t2.description ilike '%скорость среднего ветра%'
			and t1.equipment_type_id = 1;
	
		-- теперь в массиве заголовка надо найти индекс, в котором лежит наше 
		-- измеренное значение скорости приземного ветра 
		var_wind_index := array_position(var_header_values, par_wind_speed::int);
		return var_row_values[var_wind_index];
	end;	
	$body$;
	
	
	
	-- вспомогательная функция, определяющая среднюю скорость ветра
	-- для определенной высоты и дальности сноса пуль (ВР)
	-- эта функция именно для ВР. 
	-- В ТЗ не описан случай, когда дальность сноса пуль не попадает в конкретное
	-- значение заголовка в таблице 3 для ВР
	-- например, если дальность сноса пуль = 122, а в заголовке есть значения 120 и 130
	-- ТЗ не объясняет, что делать в такой ситуации, я решил, что нужна интерполяция,
	-- тем более, в прошлых ДЗ уже была написана пропорция для расчета интерполяции
	create or replace function get_average_wind_speed_vr(
		par_bullet_variance numeric,
		par_altitude int
	)
	returns int
	language 'plpgsql'
	as $body$
	declare
		var_header_values int[];
		var_row_values int[];
		-- для интерполяции
        var_low_index int;
		var_x0 numeric;
		var_x1 numeric;
		var_y0 numeric;
		var_y1 numeric;
		var_y numeric;
	begin
		-- если дальность сноса пуль меньше 40 метров,
		-- то можно сразу возвращать 0 по ТЗ
		if par_bullet_variance < 40.0::numeric then
			return 0;
		end if;
		
		-- получаем массив int[] - строку из таблицы 3 для ВР
		select t1.row_values
		into var_row_values 
		from corrections t1
		inner join correction_headers t2 on t1.correction_header_id = t2.id
		inner join correction_header_types t3 on t2.correction_header_type_id = t3.id
		inner join const_altitudes t4 on t1.const_altitude_id = t4.id
		where t3.description ilike '%скорость среднего ветра%'
			and t4.altitude = par_altitude
			and t2.equipment_type_id = 2;
	
		-- получаем заголовок с дальностью сноса пуль
		select t1.header_values
		into var_header_values
		from correction_headers t1
		inner join correction_header_types t2 on t1.correction_header_type_id = t2.id
		where t2.description ilike '%скорость среднего ветра%'
			and t1.equipment_type_id = 2;
	
		-- теперь в массиве заголовка надо найти индекс, в котором лежит 
		-- дальность сноса пуль
		-- но массив заголовка не покрывает все возможные значения дальности сноса пуль
		-- то есть нужна интерполяция
		--
		-- например, дальность сноса пуль равна 126 метров
		-- а в заголовке есть только значения 120 и 130 метров
		-- в прошлых был расчет интерполяции по формуле пропорции
		-- ее и можно использовать если вхождения bullet_variance в заголовок нет
        var_low_index := public.binary_search(var_header_values, par_bullet_variance::int);
        -- проверяем есть ли вхождение нашего bullet_variance в заголовок
        if var_header_values[var_low_index] = par_bullet_variance::int then
            -- вхождение есть, интерполяция не нужна
			return var_row_values[var_low_index];
        else
            -- вхождения нет, нужна интерполяция
            var_x0 := var_header_values[var_low_index];
		    var_x1 := var_header_values[var_low_index + 1];
		    var_y0 := var_row_values[var_low_index];
		    var_y1 := var_row_values[var_low_index + 1];
            -- формула пропорции выглядит так, где var_y искомое значение
		    -- (par_bullet_variance - var_x0) / (var_x1 - var_x0) = 
            -- (var_y - var_y0) / (var_y1 - var_y0);    
            --
		    -- из этой формулы вытащим var_y
            var_y := var_y0 + (par_bullet_variance - var_x0) * (var_y1 - var_y0) / (var_x1 - var_x0);
		    return round(var_y)::int;
        end if;
	end;	
	$body$;
	
	
	
	create or replace procedure sp_calculate_for_all_altitudes(
		params measurement_params_t,
		par_equipment_type_id int
	)
	language plpgsql
	as $$
	declare 
		var_is_dmk boolean;
		var_altitude int;
		var_average_wind_speed int;
	begin
		-- если в типе measurement_params_t поле "снос пуль" null, 
		-- то мы имеем дело с ДМК, иначе имеем дело с ВР
		var_is_dmk := par_equipment_type_id = 1;
		
		-- итоговая таблица, куда записываются значения для всех высот
		drop table if exists final_calculation_results;
		create table final_calculation_results(
			altitude int primary key,
			average_temperature_variance int not null,
			average_wind_direction int not null,
			average_wind_speed int not null
		);
	
	
		for var_altitude in select const_altitudes.altitude from const_altitudes
	    loop
			if var_is_dmk then
				var_average_wind_speed := public.get_average_wind_speed_dmk(params.wind_speed, var_altitude);
			else
				var_average_wind_speed := public.get_average_wind_speed_vr(params.bullet_variance, var_altitude);
			end if;
			
	        insert into final_calculation_results(
				altitude, 
				average_temperature_variance, 
				average_wind_direction, 
				average_wind_speed
			) values
			(
				var_altitude, 
				public.get_average_temperature_variance(params.temperature, var_altitude),
				public.get_average_wind_direction(params.wind_direction, var_altitude, var_is_dmk),
				var_average_wind_speed
			);
	    end loop;
	end;
	$$;

end $$;
