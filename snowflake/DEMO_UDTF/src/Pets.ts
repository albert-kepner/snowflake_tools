class Pets {

    getPets(): any[] {
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
    }

}

const makePets = () => { return new Pets(); };

export { makePets };