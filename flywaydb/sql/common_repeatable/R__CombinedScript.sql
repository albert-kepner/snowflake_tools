create or replace function DATE_TO_INT(date_in DATE)
  returns FLOAT
AS
$$
	(date_in - TO_DATE('1900-01-01'))::FLOAT
  $$
  ;
 

create or replace function INT_TO_DATE(int_date FLOAT)
  returns DATE
AS
$$
    DATEADD(DAY,int_date,TO_DATE('1900-01-01'))
  $$
  ;



CREATE OR REPLACE FUNCTION DEMO_UDTF()
    RETURNS TABLE ( NAME VARCHAR, PET VARCHAR, PET_AGE FLOAT)
    LANGUAGE JAVASCRIPT
    AS 
	$$
	{
	initFunctions: () => {
// export {};
var Pets = /** @class */ (function () {
    function Pets() {
    }
    Pets.prototype.getPets = function () {
        return [
            {
                name: 'John',
                pet: 'Fluffy',
                pet_age: 13,
            },
            {
                name: 'Sam',
                pet: 'Fly',
                pet_age: 2,
            },
        ];
    };
    return Pets;
}());
var makePets = function () { return new Pets(); };
// export { makePets };
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


create or replace procedure NewProcedure()
	returns variant
	language javascript
	execute as Owner
	as
$$
class SQLCommand {
    constructor(sql) {
        this.sqlText = sql;
    }
}
/**
 * @class Result of executing a query
 * @description Contains tools for processing of query results
 */
class QueryResult {
    constructor(internalResults, statement, type) {
        this.internalResults = internalResults;
        this.statement = statement;
        this.type = type;
        this.getInstance = () => this.type === undefined
            ? {}
            : new this.type();
        /**
        * @description maps column value to an object instance
        *
        * Snowflake returns column names in all-caps so this matches
        * column names by querying object keys
        * @param instance Object instance
        * @param col Name of the column to retrieve
        */
        this.mapProperty = (instance, col) => {
            let prop = Object.keys(instance)
                .filter(p => instance.hasOwnProperty(p))
                .find(p => p.toUpperCase() === col);
            if (prop !== undefined) {
                instance[prop] = this.internalResults[col];
            }
            else {
                instance[col.toLowerCase()] = this.internalResults[col];
            }
            return instance;
        };
        this.rowLimitReached = () => this.rowLimit !== undefined && this.processedRows === this.rowLimit;
        this.columns = this.loadColumns();
        this.rowCount = this.statement.getRowCount();
        this.queryId = statement.getQueryId();
    }
    [Symbol.iterator]() {
        return this;
    }
    /**
     * Set filter condition to apply to this result set.
     * Subsequent calls will replace the original filter condition.
     * @example
     * const filtered = queryResult.filter(example => example.subject == 'filter');
     */
    filter(condition) {
        this._filter = condition;
        return this;
    }
    /**
    * Loops through rows and returns first match for condition
    * @example
    * const row = queryResult.find(example => example.subject === 'filter');
    */
    find(condition) {
        this._filter = condition;
        // iterating already applies filter so the first row we get is the first filter hit
        for (let row of this) {
            return row;
        }
    }
    /**
     * Mimics Array.forEach(), executes an action for each row
     * @param action action to execute for each row
     * @example
     * client
     *     .execute('show warehouses')
     *     .forEach(row => doSomething(row))
     */
    forEach(action) {
        for (let row of this) {
            action(row);
        }
    }
    /**
     * Mimics Array.map(). Equivalent to calling .materialize().map();
     * @param mapping
     */
    map(mapping) {
        return this.materialize().map(mapping);
    }
    /**
     * Load entire result set to array
     * @example
     * var snowflake = new SnowflakeClient();
     * var results = snowflake
     *     .execute<string>('select col from tbl'))
     *     .materialize();
     */
    materialize() {
        return Array.from(this);
    }
    /**
     * @description Set max amount of rows this QueryResult returns
     * @argument limit Row limit
     */
    limit(limit) {
        this.rowLimit = limit;
        return this;
    }
    /**
     * @description Map columns from internal result set to an instance of T
     */
    getRow() {
        return this.columns.reduce((row, col) => this.mapProperty(row, col), this.getInstance());
    }
    /**
     * @description implementation of iterator. Iterates until row limit is reached.
     * If filter is set, this recurses until the condition is met.
     *
     * @returns IteratorResult<T>
     */
    next() {
        if (!this.rowLimitReached() && this.internalResults.next()) {
            let currentRow = this.getRow();
            this.processedRows++;
            if (this._filter !== undefined && !this._filter(currentRow)) {
                return this.next(); // recurse until filter returns true
            }
            this.currentRow = currentRow;
            return {
                done: false,
                value: currentRow
            };
        }
        return {
            done: true,
            value: null
        };
    }
    /**
     * Retrieve column names from internal result set
     */
    loadColumns() {
        let columnCount = this.statement.getColumnCount();
        let columnNames = Array();
        for (let i = 1; i <= columnCount; i++) {
            let name = this.statement.getColumnName(i);
            columnNames.push(name);
        }
        return columnNames;
    }
}
class SnowflakeClient {
    constructor() {
        /**
         * @method useDatabase Switches the session to a new database.
         * Doesn't work for procedures with owner's rights.
         */
        this.useDatabase = (database) => this.execute(`use database ${database}`);
        /**
         * @method useSchema Switches the session to a new schema.
         * Doesn't work for procedures with owner's rights.
         */
        this.useSchema = (schema) => this.execute(`use schema ${schema}`);
        /**
         * @method useRole Switches the session to a new role.
         * Doesn't work for procedures with owner's rights.
         */
        this.useRole = (roleName) => this.execute(`use role ${roleName}`);
        this.drop = (objectName, objectType) => this.execute(`drop ${objectType} ${objectName}`);
        this.snowflake = snowflake;
    }
    /**
     * @method execute Run a query and return a `QueryResult` mapped to `T`
     * @param sql Query
     * @param type Type for generic QueryResult, leave blank for `any`
     * @example
     * let result = client.execute('sql');
     * let genericResult = client.execute('sql', SomeClass)
     */
    execute(sql, type) {
        let command = new SQLCommand(sql);
        let statement = this.snowflake.createStatement(command);
        let internalResults = statement.execute();
        return new QueryResult(internalResults, statement, type);
    }
    /**
     * @method getTable Selects all rows from a table
     * @param table table name (optionally fully qualified)
     * @example
     * const myTable = client.getTable('mytable');
     * const myQualifiedTable = client.getTable('mydb.myschema.mytable')
     */
    getTable(table, type) {
        return this.execute(`select * from ${table}`, type);
    }
    /**
     * @method executeAs Switches to a role, executes a query
     * and then reverts the role change so the session isn't affected.
     * Doesn't work for procedures with owner's rights.
     * @param roleName Name of the role
     * @param sql Query
     * @param type Type for generic QueryResult, leave blank for `any`
     */
    executeAs(roleName, sql, type) {
        let state = new StateManager();
        this.useRole(roleName);
        var result = this.execute(sql, type);
        state.restore();
        return result;
    }
}
class State {
    constructor() { }
}
class StateManager {
    constructor() {
        this.state = { role: '', database: '', schema: '' };
        this.snowflake = new SnowflakeClient();
        this.state = this.getCurrent();
    }
    getCurrent() {
        let state = new State();
        for (const prop in state) {
            if (state.hasOwnProperty(prop)) {
                state[prop] = this.snowflake
                    .execute(`select current_${prop}() as current`)
                    .materialize()
                    .pop()
                    .current;
            }
        }
        return state;
    }
    restore(state) {
        state = state || this.state;
        this.snowflake.execute(`use role ${state.role}`);
        this.snowflake.execute(`use database ${state.database}`);
        this.snowflake.execute(`use schema ${state.schema}`);
    }
}
/**
 * @abstract Base class for declaring procedure arguments.
 * Values will be assigned by the compiler.
 * @example
 * export class AssignRoleArguments extends Arguments {
 *     stringArg: string;
 *     dateArg: Date;
 *     numberArg: number;
 * }
 */
class Arguments {
}
class Procedure {
    constructor() {
        this.canReturnNull = true; // Not active yet
        this.restoreState = true; // Not active yet
        /**
         * @property Execute procedure with rights of caller or owner. Defaults to owner.
         */
        this.rights = Rights.Owner;
    }
}
var Rights;
(function (Rights) {
    Rights[Rights["Caller"] = 0] = "Caller";
    Rights[Rights["Owner"] = 1] = "Owner";
})(Rights || (Rights = {}));
class NewProcedure_Arguments extends Arguments {
}
class NewProcedure extends Procedure {
    constructor() {
        super(...arguments);
        this.rights = Rights.Owner;
        this.run = (client, args) => {
        };
    }
}
const proc = new NewProcedure();
const args = {};
const client = new SnowflakeClient();
return proc.run(client, args);

$$;

