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

    -- создаем функцию, которая возвращает минимальный-максимальный лимит для определенного
    -- типа параметра
    begin
        create or replace function public.get_measurement_param_limit
			(
				param_name text,
                limit_type char(3)
			)
		    returns numeric(20, 10)
		    language 'plpgsql'
		as $BODY$
        declare
            result numeric(20, 10);
		begin
            if limit_type = 'min' then
                select min_limit into result from const_measurement_param_limits t1
                inner join measurement_param_types t2 on t1.measurement_param_type_id = t2.id
                where t2.name = param_name;

                return result;
            end if;

            if limit_type = 'max' then
                select max_limit into result from const_measurement_param_limits t1
                inner join measurement_param_types t2 on t1.measurement_param_type_id = t2.id
                where t2.name = param_name;

                return result;
            end if;
            return null;
        end;
		$BODY$;
		
		alter function public.get_measurement_param_limit(text, char(3))
		    owner to postgres;
    end;

    -- создаем функцию, которая возвращает текст ошибки, в случае если в значении параметра
    -- имеется ошибка
    begin
        create or replace function public.get_measurement_param_limit_error
			(
				param_name text
			)
		    returns varchar(100)
		    language 'plpgsql'
		as $BODY$
        declare
            result varchar(100);
		begin
            select t1.error_text into result from const_measurement_param_limits t1
            inner join measurement_param_types t2 on t1.measurement_param_type_id = t2.id
            where t2.name = param_name;

            return result;
        end;
		$BODY$;
		
		alter function public.get_measurement_param_limit_error(text)
		    owner to postgres;
    end;

    begin
        create or replace function public.check_param_errors
        (
            param_name text,
            param_value numeric(20, 10),
            on_min_limit_error_callback text,
            on_max_limit_error_callback text,
            on_min_max_limit_error_callback text
        )
        as $body$
        declare
            min_limit numeric(20, 10);
            max_limit numeric(20, 10);
        begin
            min_limit := public.get_measurement_param_limit(param_name, 'min');
            max_limit := public.get_measurement_param_limit(param_name, 'max');

            if min_limit is null and max_limit is null then
                return;
            end if;

            if min_limit is null and 
            -- вызываем функцию-коллбэк по ее названию 
            execute format('select %s($1)', on_min_limit_error_callback::regproc)
            into ...
            using ...;

            
        end;
        $body$;
        
        alter function public.check_param_errors(text, text, text, text)
            owner to postgres;
    end;

    begin
        create or replace function public.on_min_limit_error_callback
        (
            inout 
        )
    end;
    begin
        create or replace function public.count_param_errors
            (
                params public.measurement_params_t
            )
            returns int
            language 'plpgsql'
        as $body$
        declare
            var_count int := 0;
            min_limit numeric(20, 10);
            max_limit numeric(20, 10);
            e record;
 
       begin
            min_limit := public.get_measurement_param_limit('Высота метеопоста', 'min');
            max_limit := public.get_measurement_param_limit('Высота метеопоста', 'max');

            if min_limit is null and max_limit is not null and e.param_value > max_limit then
                var_count := var_count + 1;
            elsif then

            else

            end if;

            -- словарь сопоставлений: имя поля в типе -> имя параметра в const_*
            create table if not exists dict_param_names (
                param_name text,
                param_value numeric(20, 10)
            );
            truncate dict_param_names;
            insert into dict_param_names values
            ('Высота метеопоста', params.altitude),
            ('Температура воздуха', params.temperature),
            ('Атмосферное давление', params.pressure),
            ('Направление ветра', params.wind_direction);

            if params.equipment_type_id = 1 then
                insert into dict_param_names values
                ('Скорость ветра', params.wind_speed);
            end if;

            if params.equipment_type_id = 2 then
                insert into dict_param_names values
                ('Снос пуль', params.bullet_variance);
            end if;

            for e in select param_name, param_value from dict_param_names loop
                min_limit := public.get_measurement_param_limit(e.param_name, 'min');
                max_limit := public.get_measurement_param_limit(e.param_name, 'max');

                if min_limit is null and max_limit is null then
                    continue;
                end if;

                if min_limit is null and e.param_value > max_limit then
                    var_count := var_count + 1;
                    continue;
                end if;

                if max_limit is null and e.param_value < min_limit then
                    var_count := var_count + 1;
                    continue;
                end if;

                if not (e.param_value between min_limit and max_limit) then
                    var_count := var_count + 1;
                end if;
            end loop;

            return var_count;
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
		declare
            str_errors text := '';
            min_limit numeric(20, 10);
            max_limit numeric(20, 10);
            -- для цикла for
            e record;
		begin
            -- надо как-то сопоставить названия полей в типе данных measurement_params_t
            -- c именами полей в нашей БД - они на русском и на английском
            -- в PL нет словарей, но можно сделать временную таблицу, как словарь
            create table if not exists dict_param_names (
                param_name text, 
                param_value numeric(20, 10)
            );
            truncate dict_param_names;
            insert into dict_param_names values
            ('Высота метеопоста', params.altitude),
            ('Температура воздуха', params.temperature),
            ('Атмосферное давление', params.pressure),
            ('Направление ветра', params.wind_direction);

            if params.equipment_type_id = 1 then
                insert into dict_param_names values
                ('Скорость ветра', params.wind_speed);
            end if;

            if params.equipment_type_id = 2 then
                insert into dict_param_names values
                ('Снос пуль', params.bullet_variance);
            end if;
                
            for e in select param_name, param_value from dict_param_names loop
                min_limit := public.get_measurement_param_limit(e.param_name, 'min');
                max_limit := public.get_measurement_param_limit(e.param_name, 'max');
                if min_limit is null and max_limit is null then
                    continue;
                end if;

                if min_limit is null and e.param_value > max_limit then
                    str_errors := str_errors || public.get_measurement_param_limit_error(e.param_name) || E'\n';
                    continue;
                end if;

                if max_limit is null and e.param_value < min_limit then
                    str_errors := str_errors || public.get_measurement_param_limit_error(e.param_name) || E'\n';
                    continue;
                end if;

                if not (e.param_value between min_limit and max_limit) then
                    str_errors := str_errors || public.get_measurement_param_limit_error(e.param_name) || E'\n';
                end if;
            end loop;

           	return str_errors;
		end;
		$BODY$;
		
		alter function public.validate_measurement_params(public.measurement_params_t)
		    owner to postgres;
    end;
    commit;

end $$;

