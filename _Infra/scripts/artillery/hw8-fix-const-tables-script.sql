do $$
begin
    -- этот скрипт исправляет скрипт 20261102.sql 
    -- не через полное пересоздание старого, как я делал раньше
    -- а через безумный alter table всего подряд


    -- до этого я давал другие названия для таблиц и последовательностей
    -- и уже с этими новыми именами написал много нового кода.
    -- мне легче переименовать старые названия на мои
    begin
        -- для таблицы высот
        alter sequence calc_correction_height_seq rename to seq_const_altitudes;
        alter table calc_correction_heights rename to const_altitudes;
        alter table const_altitudes rename column height to altitude;
        alter table const_altitudes alter column id set default nextval('seq_const_altitudes');

        -- для таблицы корректировок
        alter sequence calc_correction_seq rename to seq_corrections;
        alter table calc_correction rename to corrections;
        alter table corrections rename column height_id to const_altitude_id;
        alter table corrections rename column type_id  to correction_header_id;
        alter table corrections alter column id set default nextval('seq_corrections');

        -- для таблицы заголовков
        alter sequence calc_correction_types_seq rename to seq_correction_headers;
        alter table calc_correction_types rename to correction_headers;
        alter table correction_headers rename column measurment_equipment_id to equipment_type_id;
        alter table correction_headers 
            alter column id set default nextval('seq_correction_headers');
    end;


    -- чтобы добавлять новые столбцы и foreign key
    -- надо сначала truncate очистить таблицы
    --
    -- и еще в записях таблиц сейчас много ошибок, легче все truncate
    -- и потом заново insert
    --
    -- я прочитал, что truncate выполняется за О(1)
    -- я подозреваю, что там просто указатель на диске перемещается
    -- указатель, отделяющий аллоцированные сектора диска от тех, которые можно затереть
    -- и таким образом за О(1). В любом случае, время выполнения truncate не зависит
    -- от числа записей в таблице
    begin
        truncate table correction_headers;
        truncate table corrections;
    end;
        

    -- удаляем и добавляем столбцы
    -- так как сейчас таблицы пустые, то добавление столбцов сработает без ошибок
    begin
        -- столбцы description и parent_id не нужны в таблице заголовков
        alter table correction_headers drop column description;
        alter table correction_headers drop column parent_id;
        -- добавляем будущий внешний ключ для связи таблицы заголовков и таблицы типов заголовков
        alter table correction_headers add column correction_header_type_id int not null;

        -- раньше header_values массив не был not null это странно, ведь смысл от заголовка,
        -- если он пуст
        alter table correction_headers alter column header_values set not null;

        -- высоты должны быть уникальными
        alter table const_altitudes add constraint unique_altitude unique (altitude);
    end;


    -- добавляем таблицу типов заголовков
    -- до этого этой таблицы вообще не было
    begin
        create table if not exists correction_header_types(
            id int primary key,
            description text not null
        );
        create sequence seq_correction_header_types start with 1;
        alter table correction_header_types
            alter column id set default nextval('seq_correction_header_types');


        comment on table correction_header_types is 'Справочник типов заголовков таблиц';
        comment on column correction_header_types.id is 'Уникальный код';
        comment on column correction_header_types.description is 'Описание типа заголовка';
    end;


    -- добавляем foreign keys между таблицами
    begin 
        alter table correction_headers add constraint fk_equipment_type
            foreign key (equipment_type_id)
            references equipment_types(id);

        alter table correction_headers add constraint fk_correction_header_type
            foreign key (correction_header_type_id)
            references correction_header_types(id);

        alter table corrections add constraint fk_const_altitude
            foreign key (const_altitude_id)
            references const_altitudes(id);

        alter table corrections add constraint fk_correction_header
            foreign key (correction_header_id)
            references correction_headers(id);
    end;


    -- в таблице высот все значения верны
    -- в таблицах корректировок и заголовков было много ошибок + мы поменяли
    -- столбцы и добавили новую таблицу типов заголовков.
    -- ранее мы очистили таблицы через truncate
    -- теперь можно заполнить правильные данные через insert
    begin
        -- надо для последовательностей задать след. генерируемое значение для id в единицу
        alter sequence seq_correction_headers restart with 1;
        alter sequence seq_corrections restart with 1;

        insert into correction_header_types(description) values
        ('Таблица 2, Температура'),
        ('Таблица 3, Скорость среднего ветра'),
        ('Таблица 3, Направление среднего ветра');

        insert into correction_headers(
            equipment_type_id, 
            correction_header_type_id, 
            header_values
        ) values
        -- заголовки положительные и отрицательные температуры имеют 
        -- один и тот же тип заголовка "таблица 2, температуры"
        -- таблица 2 общая для всех видов оборудования, поэтому equipment_type_id = null
        (null, 1, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]), 
        (null, 1, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]), 
        -- таблица 3 для ВР
        (2, 2, array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]), 
        (2, 3, array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]), 
        -- таблица 3 для ДМК
        (1, 2, array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]), 
        (1, 3, array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]); 

        insert into corrections(const_altitude_id, correction_header_id, row_values) values
        -- Таблица 2, отрицательные температуры
        (1, 1, array[-1, -2, -3, -4, -5, -6, -7, -8, -8, -9, -20, -29, -39, -49]), -- 200
        (2, 1, array[-1, -2, -3, -4, -5, -6, -6, -7, -8, -9, -19, -29, -39, -48]), -- 400
        (3, 1, array[-1, -2, -3, -4, -5, -6, -6, -7, -7, -8, -18, -28, -37, -46]), -- 800
        (4, 1, array[-1, -2, -3, -4, -4, -5, -5, -6, -7, -8, -17, -26, -35, -44]), -- 1200
        (5, 1, array[-1, -2, -3, -3, -4, -4, -5, -6, -7, -7, -17, -25, -34, -42]), -- 1600
        (6, 1, array[-1, -2, -3, -3, -4, -4, -5, -6, -6, -7, -16, -24, -32, -40]), -- 2000
        (7, 1, array[-1, -2, -2, -3, -4, -4, -5, -5, -6, -7, -15, -23, -31, -38]), -- 2400
        (8, 1, array[-1, -2, -2, -3, -4, -4, -4, -5, -5, -6, -15, -22, -30, -37]), -- 3000
        (9, 1, array[-1, -2, -2, -3, -4, -4, -4, -4, -5, -6, -14, -20, -27, -34]), -- 4000
        -- Таблица 2, положитеьные температуры
        (1, 2, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]), -- 200
        (2, 2, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]), -- 400
        (3, 2, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]), -- 800
        (4, 2, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]), -- 1200
        (5, 2, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]), -- 1600
        (6, 2, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]), -- 2000
        (7, 2, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]), -- 2400
        (8, 2, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]), -- 3000
        (9, 2, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30]), -- 4000
        -- Таблица 3, Дальность сноса ветровых пуль (ВР)
        (1, 3, array[3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 12, 12]), -- 200
        (2, 3, array[4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 ,15]), -- 400
        (3, 3, array[4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15 ,16]), -- 800
        (4, 3, array[4, 5, 7, 8, 8, 9, 11, 12, 13, 15, 15, 16]), -- 1200
        (5, 3, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 15, 17, 17]), -- 1600
        (6, 3, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 15, 17, 18]), -- 2000
        (7, 3, array[4, 6, 8, 9, 9, 10, 12, 14, 15, 16, 18, 19]), -- 2400
        (8, 3, array[5, 6, 8, 9, 10, 11, 12, 14, 15, 17, 18, 19]), -- 3000
        (9, 3, array[5, 6, 8, 9, 10, 11, 12, 14, 16, 18, 19, 20]), -- 4000
        -- Таблица 3, Направление среднего ветра (ВР)
        (1, 4, array[0]), -- 200
        (2, 4, array[1]), -- 400
        (3, 4, array[2]), -- 800
        (4, 4, array[2]), -- 1200
        (5, 4, array[3]), -- 1600
        (6, 4, array[3]), -- 2000
        (7, 4, array[3]), -- 2400
        (8, 4, array[4]), -- 3000
        (9, 4, array[4]), -- 4000
        -- Таблица 3, Скорость приземного ветра (ДМК)
        (1, 5, array[4,6,8,9,10,12,14,15,16,18,20,21,22]), -- 200
        (2, 5, array[5,7,10,11,12,14,17,18,20,22,23,25,27]), -- 400
        (3, 5, array[5,8,10,11,13,15,18,19,21,23,25,27,28]), -- 800
        (4, 5, array[5,8,11,12,13,16,19,20,23,24,26,28,30]), -- 1200
        (5, 5, array[6,8,11,13,14,17,20,21,23,25,27,29,32]), -- 1600
        (6, 5, array[6,9,11,13,14,17,20,21,24,26,28,30,32]), -- 2000
        (7, 5, array[6,9,12,14,15,18,21,22,25,27,29,32,34]), -- 2400
        (8, 5, array[6,9,12,14,15,18,21,23,25,28,30,32,36]), -- 3000
        (9, 5, array[6,10,12,14,16,19,22,24,26,29,32,34,36]), -- 4000
        -- 'Таблица 3, Направление среднего ветра (ДМК)
        (1, 6, array[1]), -- 200
        (2, 6, array[2]), -- 400
        (3, 6, array[3]), -- 800
        (4, 6, array[3]), -- 1200
        (5, 6, array[4]), -- 1600
        (6, 6, array[4]), -- 2000
        (7, 6, array[4]), -- 2400
        (8, 6, array[5]), -- 3000
        (9, 6, array[5]); -- 4000
    end;


    -- осталось комментарии для таблиц обновить
    begin
        comment on table corrections is 'Универсальная таблица корректировок';
        comment on column corrections.id is 'Уникальный код';
        comment on column corrections.const_altitude_id is 'Код высоты';
        comment on column corrections.correction_header_id is 'Код типа таблиц';
        comment on column corrections.row_values is 'Значения с корректировками';

        comment on table correction_headers is 'Справочник заголовков таблиц';
        comment on column correction_headers.id is 'Уникальный код';
        comment on column correction_headers.equipment_type_id is 'Тип оборудования';
        comment on column correction_headers.correction_header_type_id is 'Тип заголовка';
        comment on column correction_headers.header_values is 'Значения в заголовке';

        comment on table const_altitudes is 'Таблица стандартных высот';
        comment on column const_altitudes.id is 'Уникальный код';
        comment on column const_altitudes.altitude is 'Высота';
    end;

end $$;

