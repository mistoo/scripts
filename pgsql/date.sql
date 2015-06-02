-- PostgreSQL date formatting functions 
-- Copyright (c) 2015 Pawel Gajda
-- License: MIT

DROP FUNCTION IF EXISTS date_day(date) CASCADE;
CREATE FUNCTION date_day(date) RETURNS varchar
  AS 'SELECT pg_catalog.to_char($1, ''YYYY-MM-DD'')' 
  LANGUAGE SQL
  IMMUTABLE
  RETURNS NULL ON NULL INPUT;

DROP FUNCTION IF EXISTS date_week(date) CASCADE;
CREATE FUNCTION date_week(date) RETURNS varchar
  AS 'SELECT pg_catalog.date_trunc(''week'', $1)::date::varchar'
  LANGUAGE SQL
  IMMUTABLE
  RETURNS NULL ON NULL INPUT;

DROP FUNCTION IF EXISTS date_month(date) CASCADE;
CREATE FUNCTION date_month(date) RETURNS varchar
  AS 'SELECT pg_catalog.to_char($1, ''YYYY-MM'')' 
  LANGUAGE SQL
  IMMUTABLE
  RETURNS NULL ON NULL INPUT;
  

DROP FUNCTION IF EXISTS date_quarter(date) CASCADE;
CREATE FUNCTION date_quarter(date) RETURNS varchar
  AS 'SELECT replace(pg_catalog.to_char($1, ''YYYY Q''), '' '', ''-Q'')'
  LANGUAGE SQL
  IMMUTABLE
  RETURNS NULL ON NULL INPUT;

DROP FUNCTION IF EXISTS date_halfyear(date) CASCADE;
CREATE FUNCTION date_halfyear(date) RETURNS varchar
  AS 'SELECT pg_catalog.to_char($1, ''YYYY'') || ''-'' || CASE WHEN pg_catalog.to_char($1, ''Q'')::integer IN (1,2) THEN ''H1'' ELSE ''H2'' END'
  LANGUAGE SQL
  IMMUTABLE
  RETURNS NULL ON NULL INPUT;


DROP FUNCTION IF EXISTS date_year(date) CASCADE;
CREATE FUNCTION date_year(date) RETURNS integer
  AS 'SELECT pg_catalog.to_char($1, ''YYYY'')::integer'
  LANGUAGE SQL
  IMMUTABLE
  RETURNS NULL ON NULL INPUT;


DROP FUNCTION IF EXISTS date_month_i(date) CASCADE;
CREATE FUNCTION date_month_i(date) RETURNS integer
  AS 'SELECT pg_catalog.to_char($1, ''YYYYMM'')::integer' 
  LANGUAGE SQL
  IMMUTABLE
  RETURNS NULL ON NULL INPUT;

DROP FUNCTION IF EXISTS date_quarter_i(date) CASCADE;
CREATE FUNCTION date_quarter_i(date) RETURNS integer
  AS 'SELECT pg_catalog.to_char($1, ''Q'')::integer'
  LANGUAGE SQL
  IMMUTABLE
  RETURNS NULL ON NULL INPUT;

DROP FUNCTION IF EXISTS date_halfyear_i(date) CASCADE;
CREATE FUNCTION date_halfyear_i(date) RETURNS integer
  AS 'SELECT CASE WHEN pg_catalog.to_char($1, ''Q'')::integer IN (1,2) THEN 1 ELSE 2 END::integer'
  LANGUAGE SQL
  IMMUTABLE
  RETURNS NULL ON NULL INPUT;
  
