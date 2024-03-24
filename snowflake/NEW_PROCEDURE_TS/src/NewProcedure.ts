import { Procedure, Arguments, Rights, SnowflakeClient } from "snowproc";

class NewProcedure_Arguments extends Arguments {
}

class NewProcedure extends Procedure {
    rights = Rights.Owner;
    
    run = (client: SnowflakeClient, args: NewProcedure_Arguments) => {
    }
}