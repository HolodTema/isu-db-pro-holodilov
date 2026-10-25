do $$
begin

    create table if not exists const_measurement_param_limits(
        measurement_param_type_id int primary key ,
        min_limit numeric(20, 10),
        max_limit numeric(20, 10),
        error_text varchar(100) not null
    );

    insert into const_measurement_param_limits
    (measurement_param_type_id, min_limit, max_limit, error_text)
    values
    (1, null, null, ''),
    (2, -58, 58, 'Температура должна быть в диапазоне от -58 до +58.'),
    (3, 500, 900, 'Давление должно быть в диапазоне от 500 до 900.'),
    (4, 0, 59, 'Направление ветра должно быть в диапазоне от 0 до 59'),
    (5, 0, 15, 'Скорость ветра должна быть в диапазоне от 0 до 15'),
    (6, 0, 150, 'Дальность сноса пуль должна быть в диапазоне от 0 до 150');
end $$;

