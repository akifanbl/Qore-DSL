# TODO

[] Qore-Base integration
    [x] Delete id (auto created when creating a table)
    [x] In 'migration' attribute of creating a relation, 'nullable' attribute is required

[] One-to-One relation using lookup fields?

[]  View
    [] Add `conditions` attribute!
    [] other attributes : order, limit, offset, etc

Create View DDL Example
{
    "operation": "Create",
    "resource": "View",
    "migration": {
    "name": "user_view",
    "table": "users",
    "condition": {
        "$and": [
        {
            "Formula: external_id == 'lala'" : {
            "$eq": true
            }
        }
        ]
    },
    "populate": [
    ],
    "join": "left",
    "groupBy": [
        "id"
    ],
    "fields": [
        "external_id"
    ]
    }
}

[] Create role&permissions ddl
    [x] Make 1 row of dsl can use some operation for 1 table combinations

[] Complete qore-data supported column type in DSL (sisa yg aneh2 ex:action,rollup,)

[] Complete qore-data supported definitons in DSL (pk, fk)