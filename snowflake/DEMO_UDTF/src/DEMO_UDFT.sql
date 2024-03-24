CREATE OR REPLACE FUNCTION DEMO_UDTF()
    RETURNS TABLE ( NAME VARCHAR, PET VARCHAR, PET_AGE FLOAT)
    LANGUAGE JAVASCRIPT
    AS 
	$$
	{
	initFunctions: () => {
		<placeholder>
		return makePets();
	},
    processRow: function (row, rowWriter, context) {
	
    },
    finalize: function (rowWriter, context) {
		const fns = this.initFunctions();
        let pets = fns.getPets();
        for (const row of pets) {
            rowWriter.writeRow({
			    NAME: row.name,
                PET: row.pet,
                PET_AGE: row.pet_age,
		    });
        }
    },
    initialize: function(argumentInfo, context) {

    },
	}
	$$;
