
create table if not exists const_altitudes(
    id int primary key,
    altitude int unique not null
);

insert into const_altitudes(altitude) values
(1, 200),
(2, 400),
(3, 800),
(4, 1200),
(5, 1600),
(6, 2000),
(7, 2400),
(8, 3000),
(9, 4000);

create table if not exists const_virtual_temperature_variances(
    id int primary key,
    virtual_temperature_variance int not null unique
);

insert into const_virtual_temperature_variances(id, virtual_temperature_variance) values
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 20),
(12, 30),
(13, 40),
(14, 50);

create table if not exists average_temperature_variances(
    id int primary key,
    positive_value int,
    negative_value int,
    const_altitude_id int not null,
    const_virtual_temperature_variance_id int not null
);

insert into average_temperature_variances(
    id, 
    postitive_value, 
    negative_value, 
    const_altitude_id,
    const_virtual_temperature_variance_id
) values
();


