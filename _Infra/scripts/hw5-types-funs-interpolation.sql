do $$
begin

	begin 
		create type public.interpolation_type as
		(
			x0 numeric(6,2),
			y0 numeric(6,2),
			x1 numeric(6,2),
			y1 numeric(6,2)
		);
		alter type public.interpolation_type owner to postgres;
	end;

	begin
		create or replace function public.get_interpolation_type
			(
				par_temperature numeric
			)
		    returns public.interpolation_type
		    language 'plpgsql'
		as $BODY$
		declare
			var_result public.interpolation_type;
		begin
			var_result.x0 = 1;
			var_result.y0 = 1;
			var_result.x1 = 1;
			var_result.y1 = 1;
		
			select x0, y0, x1, y1
			into var_result.x0, var_result.y0, var_result.x1, var_result.y1
			from
			(
				select * from
				(
					(
						select t.high_border as x0, t.correction as y0 from temperature_corrections t
						where t.high_border <= 20
						order by t.high_border desc
						limit 1
					)
					union all
					(
						select 20 as x0, t.correction as y0 from temperature_corrections t
						where t.high_border >=20
						order by t.high_border
						limit 1
					)
					limit 1
				)
				cross join
				(
					(
						select t.low_border as x1, t.correction as y1 from temperature_corrections t
						where t.low_border >= 20
						order by low_border
						limit 1
					)
					union all
					(
						select 20 as x1, t.correction as y1 from temperature_corrections t
						where t.low_border <= 20
						order by low_border desc
						limit 1
					)
					limit 1
				)
			);
			return var_result;
		end;
		$BODY$;
		
		alter function public.get_interpolation_type(numeric)
		    owner to postgres;

	end;

	begin
		create or replace function public.calculate_interpolation
			(
				par_x numeric,
				par_interpolation_type public.interpolation_type
			)
		    returns numeric
		    language 'plpgsql'
		as $BODY$
		declare
			var_virtual_correction numeric(6, 2);
		begin
			if par_interpolation_type.x1 = par_interpolation_type.x0 then
				var_virtual_correction = par_interpolation_type.y0;
				return par_x + var_virtual_correction;
			end if;
			var_virtual_correction = par_interpolation_type.y0 + (par_x - par_interpolation_type.x0) / (par_interpolation_type.x1 - par_interpolation_type.x0) * (par_interpolation_type.y1 - par_interpolation_type.y0);
			return par_x + var_virtual_correction;
		end;
		$BODY$;
		
		alter function public.calculate_interpolation(numeric, public.interpolation_type)
		    owner to postgres;
	end;
end $$;

