do $$
declare
    v_expected numeric;
    v_actual numeric;
begin
	begin
		select 24.8 into v_expected;
	    select public.calculate_interpolation
		(
			23,
			public.get_interpolation_type(23)
	   	)
		into v_actual;
	    assert v_actual = v_expected, 
			format('expected %s, got %s', v_expected, v_actual);
	end;

	begin
		select 3.3 into v_expected;
	    select public.calculate_interpolation
		(
			3,
			public.get_interpolation_type(3)
	   	)
		into v_actual;
	    assert v_actual = v_expected, 
			format('expected %s, got %s', v_expected, v_actual);
	end;

	begin
		select 39 into v_expected;
	    select public.calculate_interpolation
		(
			35,
			public.get_interpolation_type(35)
	   	)
		into v_actual;
	    assert v_actual = v_expected, 
			format('expected %s, got %s', v_expected, v_actual);
	end;

	begin
		select 21.5 into v_expected;
	    select public.calculate_interpolation
		(
			20,
			public.get_interpolation_type(20)
	   	)
		into v_actual;
	    assert v_actual = v_expected, 
			format('expected %s, got %s', v_expected, v_actual);
	end;

	begin
		select 49.5 into v_expected;
	    select public.calculate_interpolation
		(
			45,
			public.get_interpolation_type(45)
	   	)
		into v_actual;
	    assert v_actual = v_expected, 
			format('expected %s, got %s', v_expected, v_actual);
	end;
end $$;

