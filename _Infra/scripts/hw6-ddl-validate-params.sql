do $$
begin
    
    begin 
        create type public.measurement_params_t as (
            equipment_type_id int,
            altitude numeric(20, 10),
            temperature numeric(20, 10),
            pressure numeric(20, 10),
            wind_direction numeric(20, 10),
            wind_speed numeric(20, 10),
            bullet_variance numeric(20, 10)
        );
		alter type public.measurement_params_t owner to postgres;
    end;

    begin
        create or replace function public.count_param_errors
        (
            params public.measurement_params_t
        )
        returns int
        language 'plpgsql'
        as $body$
        begin
            -- вместо цикла и создания временной таблицы я использую CTE
            -- и тогда даже вспомогательные функции, которые были у меня раньше
            -- (по типу get_measurement_param_limit) не нужны
            --
            -- то есть мы создаем словарь имя_параметра: значение_параметра без 
            -- создания таблицы, просто на лету и называем этот словарь param_names_values
            --
            -- далее делаем CTE из этого param_names_values, и считаем число строк, где есть ошибка
            -- используя функцию-аггрегатор count
            --
            -- а условия, когда происходит ошибка (превышения лимитов) задаем в where
            return (
                with param_names_values(param_name, param_value) as
                (
                    -- эта конструкция select from values, где values создаются на лету,
                    -- должна быть быстрой, так как не меняются данные в долговременной памяти,
                    -- то есть не меняется сама БД (не создаются таблицы как у меня было раньше)
                    --
                    -- эти values сразу в RAM и из этого же RAM берутся в select, быстро обрабатываются
                    -- и удаляются из RAM
                    select * from
                    (
                        values ('Высота метеопоста', params.altitude),
                        ('Температура воздуха', params.temperature),
                        ('Атмосферное давление', params.pressure),
                        ('Направление ветра', params.wind_direction)
                    ) v
                    union all
                    (
                        select 'Скорость ветра', params.wind_speed
                        where params.equipment_type_id = 1
                    )
                    union all
                    (
                        select 'Снос пуль', params.bullet_variance
                        where params.equipment_type_id = 2
                    )
                )
                select count(*)
                from param_names_values
                inner join measurement_param_types t1 on t1.name = param_names_values.param_name
                inner join const_measurement_param_limits t2 on t2.measurement_param_type_id = t1.id
                where 
                (t2.min_limit is null and param_names_values.param_value > t2.max_limit)
                or
                (t2.max_limit is null and param_names_values.param_value < t2.min_limit)
                or
                (t2.min_limit is not null and t2.max_limit is not null and 
                    (
                        param_names_values.param_value < t2.min_limit or 
                        param_names_values.param_value > t2.max_limit
                    )
                )
            );
        end;
        $body$;

        alter function public.count_param_errors(public.measurement_params_t)
            owner to postgres;
    end;

    begin
        create or replace function public.validate_measurement_params
	    (
	        params public.measurement_params_t
		)
        returns text
		language 'plpgsql'
		as $BODY$
		begin
            -- тут тот же механизм что и в count_param_errors()
            return (
                with param_names_values(param_name, param_value) as
                (
                    select * from
                    (
                        values ('Высота метеопоста', params.altitude),
                        ('Температура воздуха', params.temperature),
                        ('Атмосферное давление', params.pressure),
                        ('Направление ветра', params.wind_direction)
                    ) v
                    union all
                    (
                        select 'Скорость ветра', params.wind_speed
                        where params.equipment_type_id = 1
                    )
                    union all
                    (
                        select 'Снос пуль', params.bullet_variance
                        where params.equipment_type_id = 2
                    )
                )
                -- string_agg() собираем строки из всех записей в одну строку с заданным разделителем
                -- у нас в таблице констант есть столбец error_text со строками ошибок
                -- мы их склеиваем через разделитель переноса строки
                -- а если ошибок нет, string_agg вернет null и мы обрабатываем null через coalesce
                select coalesce(string_agg(t2.error_text, E'\n'), '')
                from param_names_values
                inner join measurement_param_types t1 on t1.name = param_names_values.param_name
                inner join const_measurement_param_limits t2 on t2.measurement_param_type_id = t1.id
                where 
                (t2.min_limit is null and param_names_values.param_value > t2.max_limit)
                or
                (t2.max_limit is null and param_names_values.param_value < t2.min_limit)
                or
                (t2.min_limit is not null and t2.max_limit is not null and 
                    (
                        param_names_values.param_value < t2.min_limit or 
                        param_names_values.param_value > t2.max_limit
                    )
                )
            );
		end;
		$BODY$;
		
		alter function public.validate_measurement_params(public.measurement_params_t)
		    owner to postgres;
    end;
    commit;

end $$;

