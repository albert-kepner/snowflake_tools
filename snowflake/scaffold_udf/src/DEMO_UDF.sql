CREATE OR REPLACE FUNCTION DEMO_UDF (
    FILL_COVERAGE VARIANT, FROM_DATE FLOAT, TO_DATE FLOAT)
    RETURNS FLOAT
    LANGUAGE JAVASCRIPT
    AS 
	$$
    <placeholder>
    return PDC.pdcForDateRange(FILL_COVERAGE, FROM_DATE, TO_DATE);
    $$;