create table if not exists equipment_types(
	id int primary key,
	name text not null
);

comment on table  equipment_types      is 'Справочник типов метеорологического оборудования';
comment on column equipment_types.id   is 'Уникальный идентификатор типа оборудования';
comment on column equipment_types.name is 'Название типа оборудования (ВР или ДМК)';

create table if not exists job_positions(
	id int primary key,
	name text not null,
	description text
);

comment on table  job_positions             is 'Справочник должностей военнослужащих метеопоста';
comment on column job_positions.id          is 'Уникальный идентификатор должности';
comment on column job_positions.name        is 'Название должности';
comment on column job_positions.description is 'Описание обязанностей на должности';

create table if not exists users(
	id int primary key,
	first_name text not null,
	last_name text not null,
	job_position_id int not null
);

comment on table  users                 is 'Пользователи ПАК (личный состав метеопоста)';
comment on column users.id              is 'Уникальный идентификатор пользователя';
comment on column users.first_name      is 'Имя пользователя';
comment on column users.last_name       is 'Фамилия пользователя';
comment on column users.job_position_id is 'Ссылка на должность пользователя (job_positions.id)';

create table if not exists measurement_params(
	id int primary key,
	altitude int not null,
	temperature numeric(3, 1) not null check(temperature >= -58 and temperature <= 58),
	pressure int not null check(pressure >= 500 and pressure <= 900),
	wind_direction int not null check(wind_direction >= 0 and wind_direction <= 59),
	wind_speed int check(wind_speed >= 0 and wind_speed <= 15),
	bullet_variance int check(bullet_variance >= 0 and bullet_variance <= 150),
    measurement_bundle_id int not null
);

comment on table  measurement_params                   is 'Исходные данные наземного замера на метеопосту';
comment on column measurement_params.id                is 'Уникальный идентификатор замера';
comment on column measurement_params.altitude          is 'Высота метеопоста над уровнем моря';
comment on column measurement_params.temperature       is 'Измеренная приземная температура воздуха';
comment on column measurement_params.pressure          is 'Измеренное атмосферное давление';
comment on column measurement_params.wind_direction    is 'Направление приземного ветра';
comment on column measurement_params.wind_speed        is 'Скорость приземного ветра, заполняется только для ДМК';
comment on column measurement_params.bullet_variance   is 'Дальность сноса ветровых пуль, заполняется только для ВР';
comment on column measurement_params.measurement_bundle_id   is 'Ссылка на исходную пачку (measurement_bundles.id)';

create table if not exists measurement_bundles(
    id int primary key,
    created_at timestamp not null,
    altitude int not null,
    pressure_variance int not null,
    temperature_variance int not null,
    user_id int not null,
    equipment_type_id int not null
);

comment on table  measurement_bundles                        is 'Пачки метеобюллетеня Метео-11 приближённый';
comment on column measurement_bundles.id                     is 'Уникальный идентификатор пачки';
comment on column measurement_bundles.created_at             is 'Дата и время окончания зондирования (ДДЧЧМ)';
comment on column measurement_bundles.altitude               is 'Высота метеопоста над уровнем моря (ВВВВ)';
comment on column measurement_bundles.pressure_variance      is 'Отклонение наземного давления';
comment on column measurement_bundles.temperature_variance   is 'Отклонение приземной виртуальной температуры';
comment on column measurement_bundles.equipment_type_id      is 'Ссылка на тип оборудования (equipment_types.id)';
comment on column measurement_bundles.user_id                is 'Ссылка на пользователя, выполнившего замер (users.id)';
  
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

insert into measurement_bundles(id, created_at, altitude, pressure_variance, temperature_variance, user_id, equipment_type_id) values
    (1, timestamp '2026-03-23 06:10:00', 100,   0,   3, 1, 2),
    (2, timestamp '2026-09-17 06:20:00', 200,  15,  1, 2, 2),
    (3, timestamp '2025-01-01 06:30:00', 600,  -7, 2, 3, 1)
on conflict (id) do nothing;

insert into measurement_params(id, altitude, temperature, pressure, wind_direction, wind_speed, bullet_variance, measurement_bundle_id) values
    (1, 100, 15.0, 750, 0, 0, null, 1),
    (2, 200, 25.0, 765, 15, 6, null, 2),
    (3, 600, -3.0, 743, 40, null, 30, 3)
on conflict (id) do nothing;

select *
from measurement_bundles mb
join measurement_params mp
    on mp.measurement_bundle_id = mb.id
join equipment_types et
    on et.id = mb.equipment_type_id
join users u
    on u.id = mb.user_id
join job_positions jp
    on jp.id = u.job_position_id;

