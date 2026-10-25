do $$
begin 
    -- В заголовке метео-приближенный находим дату ДДЧЧМ
    begin
        create or replace function public.get_meteo_date()
            returns char(5)
            language 'plpgsql'
        as $body$
        declare
            var_now timestamp := now();
            var_result char(5);
        begin
            var_result := to_char(var_now, 'DDHH24') || (to_char(var_now, 'MI')::int / 10)::text;
            return var_result;
        end;
        $body$;

        alter function public.get_meteo_date() owner to postgres;
    end;

    -- В заголовке метео-приближенный находим ВВВВ 
    -- это высота метеопоста из 4 цифр, где при необходимости нужны ведущие нули
    begin
        create or replace function public.get_meteo_altitude(par_altitude numeric)
            returns char(4)
            language 'plpgsql'
        as $body$
        declare
            var_altitude int;
            var_result char(4);
        begin
            var_altitude := round(par_altitude)::int;
            if var_altitude >= 0 then
                var_result := lpad(var_altitude::text, 4, '0');
            else
                var_result := '-' || lpad(abs(var_altitude)::text, 3, '0');
            end if;
            return var_result;
        end;
        $body$;

        alter function public.get_meteo_altitude(numeric)
            owner to postgres;
    end;

    -- в заголовке метео-приближенный находим БББТТ
    -- БББ - отклонение давления от 750мм ртутного столба
    -- ТТ - отклонение приземной виртуальной температуры
    begin
        create or replace function public.get_meteo_pressure_temperature_variance(
            par_temperature numeric,
            par_pressure numeric
        )
            returns text            
            -- тип данных из предыдущего ДЗ
            language 'plpgsql'
        as $body$
        declare
            -- отклонение давления от 750 мм-рт-ст будет записываться сюда
            var_pressure_variance int;
            
            -- строки, части одной строки БББТТ
            var_pressure_part text;
            var_temp_part text;

            var_interp public.interpolation_type;
            var_virtual_temp numeric;
            var_temp_int int;
        begin
            -- ббб: отклонение давления от табличного значения 750 мм рт. ст.
            var_pressure_variance := round(par_pressure)::int - 750;
            if var_pressure_variance >= 0 then
                -- lpad() заполняет незначащие нули в числе и возвращает строку
                var_pressure_part := lpad(var_pressure_variance::text, 3, '0');
            else
                -- по ТЗ если отклонение давления меньше ноля, ставим в начале цифру 5
                var_pressure_part := '5' || abs(var_pressure_variance)::text;
            end if;
            
            -- тип данных из предыдущего ДЗ
            var_interp := public.get_interpolation_type(par_temperature);
            -- используем функцию из предыдущего ДЗ
            var_virtual_temp := public.calculate_interpolation(
                par_temperature, var_interp
            );
            var_temp_int := round(var_virtual_temp - 15.9)::int;

            if var_temp_int >= 0 then
                var_temp_part := lpad(var_temp_int::text, 2, '0');
            else
                -- В ТЗ не сказано, что делать, если число ТТ получится меньше 0
                -- Допустим измеренная температура = -50
                -- поправка по таблице 1 = 0
                -- тогда ТТ = -50 + 0 - 15.9 = -65.9 
                -- и как мы запишем такое число в ТТ? Недосказанность ТЗ...
                -- Ну или я чего-то не понял
                --
                -- Допустим, мы поступим как с БББ
                -- отрицательные значения ТТ кодируем с цифрой 5 
                var_temp_part := '5' || abs(var_temp_int)::text;
            end if;

            return var_pressure_part || var_temp_part;
        end;
        $body$;

        alter function public.get_meteo_pressure_temperature_variance(numeric, numeric)
            owner to postgres;
    end;

    -- эта функция понадобится для тестов позже
    -- собираем все части заголовка метео-приближенный в одну строку
    begin
        create or replace function public.get_meteo_header(
            par_altitude numeric,
            par_temperature numeric,
            par_pressure numeric
        )
            returns text
            language 'plpgsql'
        as $body$
        begin
            return public.get_meteo_date()
                || ' ' || public.get_meteo_altitude(par_altitude)
                || ' ' || public.get_meteo_pressure_temperature_variance(par_temperature, par_pressure);
        end;
        $body$;

        alter function public.get_meteo_header(numeric, numeric, numeric)
            owner to postgres;
    end;
end $$;

