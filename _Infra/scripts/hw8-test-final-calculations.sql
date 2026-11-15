-- здесь измеренная температура равна 25
-- виртуальная поправка будет = 2
-- итого в заголовке таблицы 2 имеем 25 + 2 - 15.9 = 11.1 = 11
-- в таблице 2 точного значения для 11 в заголовке нет,
-- разбиваем на десятки и единицы
-- для разряда десятков (10) по всем высотам от 200м до 4000м имеем 10
-- для разряда единиц (1) по всем высотам от 200м до 4000м имеем 1
-- то есть average_temperature_variance должно быть 10 + 1 = 11 для всех высот
call public.sp_calculate_for_all_altitudes(
    row(
        1, -- equipment_type_id
        100::numeric, -- altitude
        25::numeric, -- temperature
        765::numeric, -- pressure
        15::numeric, -- wind_direction
        6::numeric, -- wind_speed
        null -- bullet_variance
    )::public.measurement_params_t,
    1
);
select * from final_calculation_results;


-- здесь измеренная температура равна 3
-- виртуальная поправка будет = 0.3 (интерполяция по таблице 1)
-- итого в заголовке таблицы 2 имеем 3 + 0.3 - 15.9 = -12.6 = -13
-- число отрицательное, поэтому будем брать значения из числителей дробей таблицы 2
-- в таблице 2 точного значения для 13 в заголовке нет
-- разбиваем на десятки и единицы
-- для разряда десятков (10)
-- для разряда единиц (3)
--
-- например для высоты 200м имеем для десятков -9
-- и для разряда единиц -3
-- итого -9 - 3 = -12
--
-- например для высоты 1600м имеем для десятков -7
-- и для разряда единиц -3
-- итого -7 - 3 = -10
--
-- average_wind_speed будет нулевой для всех высот
-- так как измеренная скорость ветра = 2 то есть меньше 3 метров в секунду
call public.sp_calculate_for_all_altitudes(
    row(
        1, -- equipment_type_id
        100::numeric, -- altitude
        3::numeric, -- temperature
        750::numeric, -- pressure
        0::numeric, -- wind_direction
        2::numeric, -- wind_speed
        null -- bullet_variance
    )::public.measurement_params_t,
    1
);
select * from final_calculation_results;



-- в этом примере важно проверить, как сработала интерполяция
-- для bullet_variance. Этого не было в ТЗ, но я обработал
-- случаи, когда bullet_variance не совпало с заголовком таблицы 3,
-- используя интерполяцию
--
-- например, пусть высота = 200м
-- bullet_variance = 122м, но в заголовке есть только значения 120м и 130м
-- для 120м имеем скорость среднего ветра 10 м-с
-- для 130м имеем скорость среднего ветра 11 м-с
-- делаем интерполяцию - получим (122 - 120) / (130 - 120) = (искомое - 10) / (11 - 10)
-- искомое = 10,2 округляем математически до целого получаем 10
-- итого average_wind_speed для высоты 200м и bullet_variance=122м равняется 10м-с
call public.sp_calculate_for_all_altitudes(
    row(
        2, -- equipment_type_id
        100::numeric, -- altitude
        5::numeric, -- temperature
        720::numeric, -- pressure
        7::numeric, -- wind_direction
        null, -- wind_speed
        122 -- bullet_variance
    )::public.measurement_params_t,
    2
);
select * from final_calculation_results;

