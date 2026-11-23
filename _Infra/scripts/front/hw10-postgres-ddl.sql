do $$
begin
    begin
        create database front;
    end;

    begin
        create table if not exists products(
            id bigint primary key,
            external_id bigint not null unique,
            name text,
            flaging smallint,
            date_add timestamp default now()
        );

		create sequence seq_products start with 1;
        alter table products
            alter column id set default nextval('seq_products');
    end;

    begin 
        create table if not exists categories(
            id bigint primary key,
            external_id bigint not null unique,
            name text,
            parent_id bigint,
            date_add timestamp default now()
        );

        create sequence seq_categories start with 1;
        alter table categories
            alter column id set default nextval('seq_categories');
    end;

    begin
        create table if not exists units(
            id bigint primary key,
            source_id bigint not null unique,
            unit_name text,
            conversion_factor float,
            date_add timestamp default now()
        );

        create sequence seq_units start with 1;
        alter table units
            alter column id set default nextval('seq_units');
    end;

    begin
        create table if not exists vendors(
            id bigint primary key,
            external_id bigint not null unique,
            name text,
            parent_id bigint,
            parent_name text,
            date_add timestamp default now()
        );

        create sequence seq_vendors start with 1;
        alter table vendors
            alter column id set default nextval('seq_vendors');
    end;

    begin
        create table if not exists storages(
            id bigint primary key default nextval('seq_dim_storages'),
            external_id bigint not null unique,
            name text,
            date_add timestamp default now()
        );

        create sequence seq_storages start with 1;
        alter table storages
            alter column id set default nextval('seq_storages');
    end;

    begin
        -- филиалы компании 
        create table if not exists departments(
            id bigint primary key,
            external_id bigint not null unique,
            name text,
            inn text,
            kpp text,
            date_add timestamp default now()
        );

        create sequence seq_departments start with 1;
        alter table departments
            alter column id set default nextval('seq_departments');
    end;

    begin
        create table staff
        (
            id bigint primary key,
            external_id bigint not null unique,
            last_name text,
            first_name text,
            middle_name text,
            percent float,
            date_add timestamp default now()
        );

        create sequence seq_staff start with 1;
        alter table staff
            alter column id set default nextval('seq_staff');
    end;

    begin
        create table roles
        (
            id bigint primary key, 
            external_id bigint not null unique,
            name text,
            date_add timestamp default now()
        );

        create sequence seq_roles start with 1;
        alter table roles
            alter column id set default nextval('seq_roles');
    end;

    begin
        create table storage_operation_types
        (
            id bigint primary key,
            external_id bigint not null unique,
            name text,
            factor smallint,
            date_add timestamp default now()
        );

        create sequence seq_storage_operation_types start with 1;
        alter table storage_operation_types
            alter column id set default nextval('seq_storage_operation_types');
    end;

    begin
        create table transaction_types
        (
            id bigint primary key,
            external_id bigint not null unique,
            name text,
            preview_group text,
            date_add timestamp default now()
        );

        create sequence seq_transaction_types start with 1;
        alter table transaction_types
            alter column id set default nextval('seq_transaction_types');
    end;

    begin
        create table product_loss_reasons
        (
            id bigint primary key,
            external_id bigint not null unique,
            name text,
            date_add timestamp default now()
        );

        create sequence seq_product_loss_reasons start with 1;
        alter table product_loss_reasons
            alter column id set default nextval('seq_product_loss_reasons');
    end;
end $$;

