do $$
begin
	-- ddl: create tables
	begin
		-- table with altitudes for table-2, table3-dmk, table3-vr
		create table if not exists const_altitudes(
			id int primary key,
			altitude int unique not null
		);
		create sequence seq_const_altitudes start with 1;
		alter table const_altitudes 
            alter column id set default nextval('seq_const_altitudes');

		create table if not exists correction_types(
			id int primary key,
			equipment_type_id int,
			description text not null,
		    header_values int[],

			constraint fk_equipment_type
				foreign key (equipment_type_id)
				references equipment_types(id)
		);
		create sequence seq_correction_types start with 1;
		alter table correction_types
			alter column id set default nextval('seq_correction_types');

		create table if not exists corrections(
			id int primary key,
			const_altitude_id int,
			correction_type_id int,
			row_values int[],

			constraint fk_const_altitude
				foreign key (const_altitude_id)
				references const_altitudes(id),

			constraint fk_correction_type
				foreign key (correction_type_id)
				references correction_types(id)
		);
		create sequence seq_corrections start with 1;
		alter table corrections
			alter column id set default nextval('seq_corrections');
	end;

	-- put some values into the tables
	begin
		insert into const_altitudes(altitude) values
		(200),
		(400),
		(800),
		(1200),
		(1600),
		(2000),
		(2400),
		(3000),
		(4000);

		insert into correction_types(equipment_type_id, description, header_values) values
		(null, 'Таблица 2, отрицательные температуры', array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]), 
		(null, 'Таблица 2, положительные температуры', array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]), 
		(2, 'Таблица 3, Дальность сноса ветровых пуль (ВР)', array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]), 
		(2, 'Таблица 3, Направление среднего ветра (ВР)', array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]), 
		(1, 'Таблица 3, Скорость приземного ветра (ДМК)', array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]), 
		(1, 'Таблица 3, Направление среднего ветра (ДМК)', array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]); 

		insert into corrections(const_altitude_id, correction_type_id, row_values) values
		-- Таблица 2, отрицательные температуры
		(1, 1, array[-1, -2, -3, -4, -5, -6, -7, -8, -8, -9, -20, -29, -39, -49]), -- 200
		(2, 1, array[-1, -2, -3, -4, -5, -6, -6, -7, -8, -9, -19, -29, -39, -48]), -- 400
		(3, 1, array[-1, -2, -3, -4, -5, -6, -6, -7, -7, -8, -18, -28, -37, -46]), -- 800
		(4, 1, array[-1, -2, -3, -4, -4, -5, -5, -6, -7, -8, -17, -26, -35, -44]), -- 1200
		(5, 1, array[-1, -2, -3, -3, -4, -4, -5, -6, -7, -7, -17, -25, -34, -42]), -- 1600
		(6, 1, array[-1, -2, -3 -3, -4, -4, -5, -6, -6, -7, -16, -24, -32, -40]), -- 2000
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
		(7, 3, array[4, 6, 8, 9, 9, 10, 12, 14, 5, 16, 18, 19]), -- 2400
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
		-- Таблица 3,Скорость приземного ветра (ДМК)
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
end $$;

