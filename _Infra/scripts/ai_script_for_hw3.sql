-- Шаг 1: Очистка таблиц
-- Используем CASCADE, чтобы не нарушить FK-ограничения при наличии связанных записей
TRUNCATE TABLE measurement_params RESTART IDENTITY CASCADE;
TRUNCATE TABLE measurement_bundles RESTART IDENTITY CASCADE;
TRUNCATE TABLE measurement_param_types RESTART IDENTITY CASCADE;
TRUNCATE TABLE measurement_units RESTART IDENTITY CASCADE;
TRUNCATE TABLE physical_quantities RESTART IDENTITY CASCADE;

-- Шаг 2: Заполнение справочников и данных

-- 1. Физические величины
INSERT INTO physical_quantities (id, name) VALUES
(1, 'Длина'),
(2, 'Скорость'),
(3, 'Температура'),
(4, 'Давление'),
(5, 'Угол');

-- 2. Единицы измерения
INSERT INTO measurement_units (id, name, physical_quantity_id) VALUES
(1, 'метр', 1),
(2, 'метр в секунду', 2),
(3, 'градус Цельсия', 3),
(4, 'мм рт. ст.', 4),
(5, 'градус', 5);

-- 3. Типы параметров измерений
INSERT INTO measurement_param_types (id, name, measurement_unit_id) VALUES
(1, 'altitude', 1),
(2, 'temperature', 3),
(3, 'pressure', 4),
(4, 'wind_direction', 5),
(5, 'bullet_variance', 1), -- Для оборудования ВР (id=1)
(6, 'wind_speed', 2);      -- Для оборудования ДМК (id=2)

-- 4. Пачки измерений (measurement_bundles) и их параметры (measurement_params)
-- Создаем 12 пачек (по 3 на каждого из 4 пользователей).
-- ID пачек: 1-3 (user_id=1), 4-6 (user_id=2), 7-9 (user_id=3), 10-12 (user_id=4).
-- Оборудование чередуется: ВР (id=1) для нечетных ID, ДМК (id=2) для четных.

-- Пачка 1 (user_id=1, equipment_type_id=1 - ВР)
INSERT INTO measurement_bundles (id, created_at, altitude, pressure_variance, temperature_variance, user_id, equipment_type_id) 
VALUES (1, NOW(), 150, 10, 2, 1, 1);
INSERT INTO measurement_params (measurement_bundle_id, measurement_param_type_id, value) VALUES
(1, 1, 150), (1, 2, 25.5), (1, 3, 760), (1, 4, 120), (1, 5, 45);

-- Пачка 2 (user_id=1, equipment_type_id=2 - ДМК)
INSERT INTO measurement_bundles (id, created_at, altitude, pressure_variance, temperature_variance, user_id, equipment_type_id) 
VALUES (2, NOW(), -50, 5, -1, 1, 2);
INSERT INTO measurement_params (measurement_bundle_id, measurement_param_type_id, value) VALUES
(2, 1, -50), (2, 2, 10.0), (2, 3, 800), (2, 4, 30), (2, 6, 8);

-- Пачка 3 (user_id=1, equipment_type_id=1 - ВР)
INSERT INTO measurement_bundles (id, created_at, altitude, pressure_variance, temperature_variance, user_id, equipment_type_id) 
VALUES (3, NOW(), 300, 15, 5, 1, 1);
INSERT INTO measurement_params (measurement_bundle_id, measurement_param_type_id, value) VALUES
(3, 1, 300), (3, 2, 32.1), (3, 3, 740), (3, 4, 210), (3, 5, 120);

-- Пачка 4 (user_id=2, equipment_type_id=2 - ДМК)
INSERT INTO measurement_bundles (id, created_at, altitude, pressure_variance, temperature_variance, user_id, equipment_type_id) 
VALUES (4, NOW(), 0, 0, 0, 2, 2);
INSERT INTO measurement_params (measurement_bundle_id, measurement_param_type_id, value) VALUES
(4, 1, 0), (4, 2, 20.5), (4, 3, 755), (4, 4, 90), (4, 6, 15);

-- Пачка 5 (user_id=2, equipment_type_id=1 - ВР)
INSERT INTO measurement_bundles (id, created_at, altitude, pressure_variance, temperature_variance, user_id, equipment_type_id) 
VALUES (5, NOW(), 220, 8, 1, 2, 1);
INSERT INTO measurement_params (measurement_bundle_id, measurement_param_type_id, value) VALUES
(5, 1, 220), (5, 2, 18.9), (5, 3, 770), (5, 4, 180), (5, 5, 88);

-- Пачка 6 (user_id=2, equipment_type_id=2 - ДМК)
INSERT INTO measurement_bundles (id, created_at, altitude, pressure_variance, temperature_variance, user_id, equipment_type_id) 
VALUES (6, NOW(), 80, 2, -3, 2, 2);
INSERT INTO measurement_params (measurement_bundle_id, measurement_param_type_id, value) VALUES
(6, 1, 80), (6, 2, 5.2), (6, 3, 820), (6, 4, 270), (6, 6, 3);

-- Пачка 7 (user_id=3, equipment_type_id=1 - ВР)
INSERT INTO measurement_bundles (id, created_at, altitude, pressure_variance, temperature_variance, user_id, equipment_type_id) 
VALUES (7, NOW(), 500, 20, 10, 3, 1);
INSERT INTO measurement_params (measurement_bundle_id, measurement_param_type_id, value) VALUES
(7, 1, 500), (7, 2, 15.0), (7, 3, 720), (7, 4, 45), (7, 5, 10);

-- Пачка 8 (user_id=3, equipment_type_id=2 - ДМК)
INSERT INTO measurement_bundles (id, created_at, altitude, pressure_variance, temperature_variance, user_id, equipment_type_id) 
VALUES (8, NOW(), -200, 12, 4, 3, 2);
INSERT INTO measurement_params (measurement_bundle_id, measurement_param_type_id, value) VALUES
(8, 1, -200), (8, 2, 40.8), (8, 3, 880), (8, 4, 330), (8, 6, 12);

-- Пачка 9 (user_id=3, equipment_type_id=1 - ВР)
INSERT INTO measurement_bundles (id, created_at, altitude, pressure_variance, temperature_variance, user_id, equipment_type_id) 
VALUES (9, NOW(), 50, 3, -2, 3, 1);
INSERT INTO measurement_params (measurement_bundle_id, measurement_param_type_id, value) VALUES
(9, 1, 50), (9, 2, -10.5), (9, 3, 790), (9, 4, 0), (9, 5, 150);

-- Пачка 10 (user_id=4, equipment_type_id=2 - ДМК)
INSERT INTO measurement_bundles (id, created_at, altitude, pressure_variance, temperature_variance, user_id, equipment_type_id) 
VALUES (10, NOW(), 1000, 25, 15, 4, 2);
INSERT INTO measurement_params (measurement_bundle_id, measurement_param_type_id, value) VALUES
(10, 1, 1000), (10, 2, 8.3), (10, 3, 690), (10, 4, 180), (10, 6, 1);

-- Пачка 11 (user_id=4, equipment_type_id=1 - ВР)
INSERT INTO measurement_bundles (id, created_at, altitude, pressure_variance, temperature_variance, user_id, equipment_type_id) 
VALUES (11, NOW(), 400, 18, 8, 4, 1);
INSERT INTO measurement_params (measurement_bundle_id, measurement_param_type_id, value) VALUES
(11, 1, 400), (11, 2, 28.4), (11, 3, 735), (11, 4, 90), (11, 5, 67);

-- Пачка 12 (user_id=4, equipment_type_id=2 - ДМК)
INSERT INTO measurement_bundles (id, created_at, altitude, pressure_variance, temperature_variance, user_id, equipment_type_id) 
VALUES (12, NOW(), 250, 6, 0, 4, 2);
INSERT INTO measurement_params (measurement_bundle_id, measurement_param_type_id, value) VALUES
(12, 1, 250), (12, 2, 22.2), (12, 3, 785), (12, 4, 240), (12, 6, 10);