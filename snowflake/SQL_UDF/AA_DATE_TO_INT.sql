create or replace function DATE_TO_INT(date_in DATE)
  returns FLOAT
AS
$$
	(date_in - TO_DATE('1900-01-01'))::FLOAT
  $$
  ;
 