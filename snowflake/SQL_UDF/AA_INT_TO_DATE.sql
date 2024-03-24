create or replace function INT_TO_DATE(int_date FLOAT)
  returns DATE
AS
$$
    DATEADD(DAY,int_date,TO_DATE('1900-01-01'))
  $$
  ;