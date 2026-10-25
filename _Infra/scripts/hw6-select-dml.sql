-- запрос "список параметров с ошибками"
with params as (
	select 
		t1.id as bundle_id, 
		t2.id as equipment_id,
		t2.name as equipment_name,
		max(t3.value) filter (where t3.measurement_param_type_id = 1) as altitude,
		max(t3.value) filter (where t3.measurement_param_type_id = 2) as temperature,
		max(t3.value) filter (where t3.measurement_param_type_id = 3) as pressure,
		max(t3.value) filter (where t3.measurement_param_type_id = 4) as wind_direction,
		max(t3.value) filter (where t3.measurement_param_type_id = 5) as wind_speed,
		max(t3.value) filter (where t3.measurement_param_type_id = 6) as bullet_variance
	from measurement_bundles t1
	inner join equipment_types t2 on t1.equipment_type_id = t2.id
	left join measurement_params t3 on t3.measurement_bundle_id = t1.id
	group by t1.id, t2.id, t2.name
),
validated as (
	select
		p.*,
		public.validate_measurement_params(
			row(
				p.equipment_id,
				p.altitude,
				p.temperature,
				p.pressure,
				p.wind_direction,
				p.wind_speed,
				p.bullet_variance
			)::public.measurement_params_t
		) as errors_text
	from params as p
)
select
	bundle_id as "№",
	equipment_name as "Тип оборудования",
	altitude as "Высота метеопоста",
	temperature as "Температура",
	pressure as "Давление",
	wind_direction as "Направление ветра",
	wind_speed as "Скорость ветра",
	bullet_variance as "Дальность сноса пуль",
	case 
		when coalesce(errors_text, '') != '' then 'да' else 'нет' 
	end as "Флаг: Есть ошибка",
	nullif(errors_text, '') as "Описание ошибки"
from validated
order by bundle_id;


-- запрос "лучший стрелок"
with params as (
    select
        t1.user_id,
        t2.id as equipment_id,
        max(t3.value) filter (where t3.measurement_param_type_id = 1) as altitude,
        max(t3.value) filter (where t3.measurement_param_type_id = 2) as temperature,
        max(t3.value) filter (where t3.measurement_param_type_id = 3) as pressure,
        max(t3.value) filter (where t3.measurement_param_type_id = 4) as wind_direction,
        max(t3.value) filter (where t3.measurement_param_type_id = 5) as wind_speed,
        max(t3.value) filter (where t3.measurement_param_type_id = 6) as bullet_variance
    from measurement_bundles t1
    inner join equipment_types t2 on t1.equipment_type_id = t2.id
    left join measurement_params t3 on t3.measurement_bundle_id = t1.id
    group by t1.id, t1.user_id, t2.id
),
validated as (
    select
        p.user_id,
		u.last_name,
		u.first_name,
        public.count_param_errors(
            row(
                p.equipment_id,
                p.altitude,
                p.temperature,
                p.pressure,
                p.wind_direction,
                p.wind_speed,
                p.bullet_variance
            )::public.measurement_params_t
        ) as errors_count
    from params as p
	inner join users u on u.id = p.user_id
)
select 
    t1.user_id as "№",
    t1.last_name as "Фамилия",
    t1.first_name as "Имя",
    sum(errors_count) as "Количество ошибок"
from validated t1
group by t1.user_id, t1.last_name, t1.first_name
order by "Количество ошибок";

