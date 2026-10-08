
do $$
begin
	-- первая вложенная транзакция 
    -- создаем все таблицы 
    -- создаем sequence как default для каждого primary key в каждой таблице
	begin
        create table if not exists physical_quantities(
            id int primary key,
            name text not null
        );
		create sequence seq_physical_quantities start with 1;
		alter table physical_quantities 
            alter column id set default nextval('seq_physical_quantities');


        create table if not exists measurement_units(
            id int primary key,
            name text not null,
            physical_quantity_id int not null
        );
		create sequence seq_measurement_units start with 1;
		alter table measurement_units 
            alter column id set default nextval('seq_measurement_units');
        

        create table if not exists equipment_types(
            id int primary key,
            name text not null
        );
		create sequence seq_equipment_types start with 1;
		alter table equipment_types 
            alter column id set default nextval('seq_equipment_types');


        create table if not exists job_positions(
            id int primary key,
            name text not null,
            description text
        );
		create sequence seq_job_positions start with 1;
		alter table job_positions 
            alter column id set default nextval('seq_job_positions');


        create table if not exists users(
            id int primary key,
            first_name text not null,
            last_name text not null,
            job_position_id int not null
        );
		create sequence seq_users start with 1;
		alter table users 
            alter column id set default nextval('seq_users');


        create table if not exists measurement_bundles(
            id int primary key,
            created_at timestamp not null,
            altitude int not null,
            pressure_variance int not null,
            temperature_variance int not null,
            user_id int not null,
            equipment_type_id int not null,
            temperature_correction_id int not null
        );
		create sequence seq_measurement_bundles start with 1;
		alter table measurement_bundles 
            alter column id set default nextval('seq_measurement_bundles');


        create table if not exists measurement_param_types(
            id int primary key,
            name text not null,
            measurement_unit_id int not null
        );
		create sequence seq_measurement_param_types start with 1;
		alter table measurement_param_types 
            alter column id set default nextval('seq_measurement_param_types');


        create table if not exists measurement_params(
            id int primary key,
            measurement_bundle_id int not null,
            measurement_param_type_id int not null,
            value numeric(20, 10) not null
        );
		create sequence seq_measurement_params start with 1;
		alter table measurement_params 
            alter column id set default nextval('seq_measurement_params');


        -- создаем новую таблицу, которая содержит виртуальные поправки температуры
        -- low_border нижняя граница диапазона, для которого подходит поправка
        -- high_border верхняя граница диапазона, для которого подходит поправка
        -- correction само значение виртуальной поправки
        --
        -- если нижней границы нет, или верхней границы
        -- нет, то low_border или high_border могут быть null
        --
        -- Например, если измеренная температура от 0 до 5 градусов, то поправка = 0.5
        -- тогда low_border = 0, high_border = 5, correction = 0.5
        create table if not exists temperature_corrections(
            id int primary key,
            low_border int,
            high_border int,
            correction numeric(2, 1) not null
        );
        create sequence seq_temperature_corrections start with 1;
        alter table temperature_corrections
            alter column id set default nextval('seq_temperature_corrections');
	end;
	commit;

	begin
        -- вторая транзакция - заполняем данными 
		insert into equipment_types(name) values
	    ('Десантный метеокомплект'),
	    ('Ветровое ружье');

		
		insert into job_positions(name, description) values
		('Командир метеоотделения', 'Командует отделением солдат для определения погоды'),
		('Администратор метеокомплекта', 'Использует оборудование для получения данных о погоде');
		
		insert into users(first_name, last_name, job_position_id) values
		('Иван', 'Иванов', 1),
		('Пётр', 'Петров', 2),
		('Александр', 'Сидоров', 2),
		('Василий', 'Пупкин', 2);

		insert into physical_quantities(name) values
		('Температура'),
		('Давление'),
		('Скорость'),
		('Угол'),
		('Расстояние');
	
		
		insert into measurement_units(name, physical_quantity_id) values
		('Градус Цельсия', 1),
		('мм рт. ст.', 2),
		('Метр в секунду', 3),
		('Градус', 4),
		('Mетр', 5);
	
		
		insert into measurement_param_types(name, measurement_unit_id) values
        ('Высота метеопоста', 5),
		('Температура воздуха', 1),
		('Атмосферное давление', 2),
		('Направление ветра', 4),
		('Скорость ветра', 3),
		('Снос пуль', 5);
	

        insert into measurement_bundles (
            created_at, 
            altitude, 
            pressure_variance, 
            temperature_variance, 
            user_id, 
            equipment_type_id,
            temperature_correction_id
        ) values 
        ('2026-10-03 21:07:52.491913', 150, 10, 2, 1, 1, 5),
        ('2026-10-03 21:07:52.491913', -50, 5, -1, 1, 2, 3),
        ('2026-10-03 21:07:52.491913', 300, 15, 5, 1, 1, 6),
        ('2026-10-03 21:07:52.491913', 0, 0, 0, 2, 2, 4),
        ('2026-10-03 21:07:52.491913', 220, 8, 1, 2, 1, 4),
        ('2026-10-03 21:07:52.491913', 80, 2, -3, 2, 2, 2),
        ('2026-10-03 21:07:52.491913', 500, 20, 10, 3, 1, 3),
        ('2026-10-03 21:07:52.491913', -200, 12, 4, 3, 2, 7),
        ('2026-10-03 21:07:52.491913', 50, 3, -2, 3, 1, 1),
        ('2026-10-03 21:07:52.491913', 1000, 25, 15, 4, 2, 2),
        ('2026-10-03 21:07:52.491913', 400, 18, 8, 4, 1, 6),
        ('2026-10-03 21:07:52.491913', 250, 6, 0, 4, 2, 4);


        insert into measurement_params (measurement_bundle_id, measurement_param_type_id, value) 
        values 
        (1, 1, 150),
        (1, 2, 25.5),
        (1, 3, 760),
        (1, 4, 12),
        (1, 5, 45),
        (2, 1, -50),
        (2, 2, 10),
        (2, 3, 800),
        (2, 4, 30),
        (2, 6, 8),
        (3, 1, 300),
        (3, 2, 32.1),
        (3, 3, 740),
        (3, 4, 21),
        (3, 5, 120),
        (4, 1, 0),
        (4, 2, 20.5),
        (4, 3, 755),
        (4, 4, 39),
        (4, 6, 15),
        (5, 1, 220),
        (5, 2, 18.9),
        (5, 3, 770),
        (5, 4, 18),
        (5, 5, 88),
        (6, 1, 80),
        (6, 2, 5.2),
        (6, 3, 820),
        (6, 4, 27),
        (6, 6, 3),
        (7, 1, 500),
        (7, 2, 15),
        (7, 3, 720),
        (7, 4, 45),
        (7, 5, 10),
        (8, 1, -200),
        (8, 2, 40.8),
        (8, 3, 880),
        (8, 4, 33),
        (8, 6, 12),
        (9, 1, 50),
        (9, 2, -10.5),
        (9, 3, 790),
        (9, 4, 0),
        (9, 5, 150),
        (10, 1, 1000),
        (10, 2, 8.3),
        (10, 3, 690),
        (10, 4, 10),
        (10, 6, 1),
        (11, 1, 400),
        (11, 2, 28.4),
        (11, 3, 735),
        (11, 4, 11),
        (11, 5, 67),
        (12, 1, 250),
        (12, 2, 22.2),
        (12, 3, 785),
        (12, 4, 24),
        (12, 6, 10);


        insert into temperature_corrections(low_border, high_border, correction) values
        (null, 0, 0),
        (0, 5, 0.5),
        (10, 15, 1),
        (20, 20, 1.5),
        (25, 25, 2),
        (30, 30, 3.5),
        (40, 40, 4.5);
	end;
	commit;

    begin
        -- настраиваем foreign key и constraints для таблиц
        alter table measurement_units
        add constraint fk_measurement_units_physical_quantity
        foreign key (physical_quantity_id) references physical_quantities(id);

        alter table users
        add constraint fk_users_job_position
        foreign key (job_position_id) references job_positions(id);

        alter table measurement_bundles
        add constraint fk_measurement_bundles_user
        foreign key (user_id) references users(id);

        alter table measurement_bundles
        add constraint fk_measurement_bundles_equipment_type
        foreign key (equipment_type_id) references equipment_types(id);

        alter table measurement_bundles
        add constraint fk_measurement_bundles_temperature_correction
        foreign key (temperature_correction_id) references temperature_corrections(id);

        alter table measurement_param_types
        add constraint fk_measurement_param_types_measurement_unit
        foreign key (measurement_unit_id) references measurement_units(id);

        alter table measurement_params
        add constraint fk_measurement_params_measurement_bundle
        foreign key (measurement_bundle_id) references measurement_bundles(id);

        alter table measurement_params
        add constraint fk_measurement_params_measurement_param_type
        foreign key (measurement_param_type_id) references measurement_param_types(id);

        -- в заголовке пачки значение БББ - отклонение-давления по ТЗ определяется 
        -- как измеренное-давление - 750
        -- А измеренное давление у нас в диапазоне от 500 до 900
        -- поэтому отклонение-давления будет в диапазоне (500-750; 900-750) = (-250; 150)
        alter table measurement_bundles
        add constraint chk_measurement_bundles_pressure_variance
        check (pressure_variance between -250 and 150);
        
        -- если одна из границ null, то это полуинтервал, такая запись нормальна
        -- нельзя чтобы low_border и high_border были равны null одновременно
        -- и очевидно, что верхняя граница больше нижней
        alter table temperature_corrections
        add constraint chk_temperature_corrections_borders
        check (
            (low_border is null and high_border is not null)
            or (low_border is not null and high_border is null)
            or (
                (low_border is not null) 
                and (high_border is not null) 
                and (low_border <= high_border)
            )
        );
    end;
    commit;
end $$;

