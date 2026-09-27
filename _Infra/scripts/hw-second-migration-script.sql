create table if not exists physical_quantities(
    id int primary key,
    name text not null
);

comment on table  physical_quantities is 'Справочник базовых единиц измерения - фактически это физические величины';
comment on column physical_quantities.id is 'Уникальный идентификатор физической величины';
comment on column physical_quantities.name is 'Название физической величины';

create table if not exists measurement_units(
    id int primary key,
    name text not null,
    physical_quantity_id int not null
);

comment on table  measurement_units is 'Справочник единиц измерения';
comment on column measurement_units.id is 'Уникальный идентификатор единицы измерения';
comment on column measurement_units.name is 'Название единицы измерения';
comment on column measurement_units.physical_quantity_id is 'Ссылка на физическую величину';

create table if not exists measurement_param_types(
    id int primary key,
    name text not null,
    measurement_unit_id int not null
);

comment on table  measurement_param_types is 'Справочник типов параметров измерений';
comment on column measurement_param_types.id is 'Уникальный идентификатор типа параметра';
comment on column measurement_param_types.name is 'Название типа параметра';
comment on column measurement_param_types.measurement_unit_id is 'Cсылка на единицу измерения';

create table if not exists equipment_param_types(
    equipment_type_id int not null,
    measurement_param_type_id int not null
);

comment on table  equipment_param_types is 'Логическая связка типов оборудования и типов параметров';
comment on column equipment_param_types.equipment_type_id is 'Логическая ссылка на тип оборудования';
comment on column equipment_param_types.measurement_param_type_id is 'Логическая ссылка на тип параметра';

insert into physical_quantities(id, name) values
    (1, 'Температура'),
    (2, 'Давление'),
    (3, 'Скорость'),
    (4, 'Угол'),
    (5, 'Расстояние')
on conflict (id) do nothing;

insert into measurement_units(id, name, physical_quantity_id) values
    (1, 'Градус Цельсия', 1),
    (2, 'мм рт. ст.', 2),
    (3, 'Метр в секунду', 3),
    (4, 'Градус', 4),
    (5, 'Mетр', 5)
on conflict (id) do nothing;

insert into measurement_param_types(id, name, measurement_unit_id) values
    (1, 'Температура воздуха', 1),
    (2, 'Атмосферное давление', 2),
    (3, 'Направление ветра', 4),
    (4, 'Скорость ветра', 3),
    (5, 'Снос пуль', 5)
on conflict (id) do nothing;

insert into equipment_param_types(equipment_type_id, measurement_param_type_id) values
    -- ВР
    (1, 1), (1, 2), (1, 3), (1, 5),
    -- ДМК
    (2, 1), (2, 2), (2, 3), (2, 4);

create table if not exists measurement_params_temp(
    id serial primary key,
    measurement_bundle_id int not null,
    measurement_param_type_id int not null,
    value numeric(20, 10)
);

comment on table  measurement_params_temp is 'Значение параметра в пачке (одна запись - это один параметр)';
comment on column measurement_params_temp.id is 'Уникальный идентификатор записи';
comment on column measurement_params_temp.measurement_bundle_id is 'Сcылка на пачку';
comment on column measurement_params_temp.measurement_param_type_id is 'Ссылка на тип параметра';
comment on column measurement_params_temp.value is 'Значение параметра';

insert into measurement_params_temp (measurement_bundle_id, measurement_param_type_id, value)
select measurement_bundle_id, 1, temperature from measurement_params
union all
select measurement_bundle_id, 2, pressure from measurement_params
union all
select measurement_bundle_id, 3, wind_direction from measurement_params
union all
select measurement_bundle_id, 4, wind_speed from measurement_params where wind_speed is not null
union all
select measurement_bundle_id, 5, bullet_variance from measurement_params where bullet_variance is not null;

drop table if exists measurement_params;

alter table measurement_params_temp rename to measurement_params;

select
    mb.created_at as "Дата измерения",
    mb.id as "Номер пачки",
    u.last_name || ' ' || u.first_name as "ФИО сотрудника",
    mpt.name || ' (' || mu.name || ')' as "Наименование параметра и ед. измерения",
    mp.value as "Значение"
from measurement_bundles mb
join users u on u.id = mb.user_id
join measurement_params mp on mp.measurement_bundle_id = mb.id
join measurement_param_types mpt on mpt.id = mp.measurement_param_type_id
join measurement_units mu on mu.id = mpt.measurement_unit_id
order by mb.created_at, mb.id, mpt.name;

