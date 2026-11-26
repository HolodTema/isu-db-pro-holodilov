do $$
begin
    -- создаем таблицу для времени
    -- я бы сделал отдельную таблицу типов кварталов и типов месяцев 
    -- и связал бы их с таблицей time как one-to-many
    --
    -- но в forlabs задании конкретно такая структура
    begin
        create table if not exists time(
            id int primary key,
            month_start date not null,
            month_end date not null,
            month_name varchar(30) not null,
            year year int not null,
            quarter_number int,
            quarter_name varchar(100)
        );
        
        create sequence seq_time start with 1;
        alter table time
            alter column id set default nextval('seq_time');
    end;

    -- заполняем месяцы
    -- можно было через цикл, но число месяцев константно = 12,
    -- поэтому без цикла
    begin
        insert into time(
            month_start, 
            month_end, 
            month_name, 
            year, 
            quarter_number, 
            quarter_name
        ) values
        ('2026-01-01'::date, '2026-01-31'::date, 'Январь', 2026, 1, 'Первый квартал'),
        ('2026-02-01'::date, '2026-02-28'::date, 'Февраль', 2026, 1, 'Первый квартал'),
        ('2026-03-01'::date, '2026-03-31'::date, 'Март', 2026, 1, 'Первый квартал'),
        ('2026-04-01'::date, '2026-04-30'::date, 'Апрель', 2026, 2, 'Второй квартал'),
        ('2026-05-01'::date, '2026-05-31'::date, 'Май', 2026, 2, 'Второй квартал'),
        ('2026-06-01'::date, '2026-06-30'::date, 'Июнь', 2026, 2, 'Второй квартал'),
        ('2026-07-01'::date, '2026-07-31'::date, 'Июль', 2026, 3, 'Третий квартал'),
        ('2026-08-01'::date, '2026-08-31'::date, 'Август', 2026, 3, 'Третий квартал'),
        ('2026-09-01'::date, '2026-09-30'::date, 'Сентябрь', 2026, 3, 'Третий квартал'),
        ('2026-10-01'::date, '2026-10-31'::date, 'Октябрь', 2026, 4, 'Четвертый квартал'),
        ('2026-11-01'::date, '2026-11-30'::date, 'Ноябрь', 2026, 4, 'Четвертый квартал'),
        ('2026-12-01'::date, '2026-12-31'::date, 'Декабрь', 2026, 4, 'Четвертый квартал');
    end;
end $$;

