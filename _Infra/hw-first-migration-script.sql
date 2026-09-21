create table if not exists equipment_types(
	id int primary key,
	name text not null
);

create table if not exists job_positions(
	id int primary key,
	name text not null,
	description text
);

create table if not exists users(
	id int primary key,
	first_name text not null,
	last_name text not null,
	job_position_id int not null
);

create table if not exists measurement_params(
	id int primary key,
	altitude int not null,
	temperature numeric(3, 1) not null check(temperature >= -58 and temperature <= 58),
	pressure int not null check(pressure >= 500 and pressure <= 900),
	wind_direction int not null check(wind_direction >= 0 and wind_direction <= 59),
	wind_speed int check(wind_speed >= 0 and wind_speed <= 15),
	bullet_variance int check(bullet_variance >= 0 and bullet_variance <= 150),
	equipment_type_id int not null,
	user_id int not null
);

create table if not exists measurement_bundles(
    id int primary key,
    created_at timestamp not null,
    altitude int not null,
    pressure_variance int not null,
    temperature_variance int not null,
	measurement_param_id int not null
);

insert into equipment_types(id, name) values
    (1, 'Ветровое ружье'),
    (2, 'Десантный метеокомплект')
on conflict (id) do nothing;

insert into job_positions(id, name, description) values
	(1, 'Командир метеоотделения', 'Командует отделением солдат для определения погоды'),
	(2, 'Администратор метеокомплекта', 'Использует метеорологическое оборудование для получения данных о погоде')
on conflict (id) do nothing;

insert into users(id, first_name, last_name, job_position_id) values
    (1, 'Иван', 'Иванов', 1),
    (2, 'Пётр', 'Петров', 2),
	(3, 'Александр', 'Сидоров', 2),
	(4, 'Василий', 'Пупкин', 2)
on conflict (id) do nothing;

insert into measurement_params(id, altitude, temperature, pressure, wind_direction, wind_speed, bullet_variance, equipment_type_id, user_id) values
    (1, 100, 15.0, 750, 0, 0, null, 2, 4),
    (2, 200, 25.0, 765, 15, 6, null, 2, 2),
    (3, 600, -3.0, 743, 40, null, 30, 1, 3)
on conflict (id) do nothing;

insert into measurement_bundles(id, created_at, altitude, pressure_variance, temperature_variance, measurement_param_id) values
    (1, timestamp '2026-03-23 06:10:00', 100,   0,   0, 1),
    (2, timestamp '2026-09-17 06:20:00', 200,  15,  11, 2),
    (3, timestamp '2025-01-01 06:30:00', 600,  -7, -19, 3)
on conflict (id) do nothing;

select * from measurement_bundle_layers
join measurement_bundles on measurement_bundles.id = measurement_bundle_layers.measurement_bundle_id
join measurement_params on measurement_params.id = measurement_bundles.measurement_param_id
join equipment_types on equipment_types.id = measurement_params.equipment_type_id
join users on users.id = measurement_params.user_id
join job_positions on job_positions.id = users.job_position_id;

