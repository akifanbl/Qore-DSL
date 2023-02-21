# TODO

PRIO

1. Check /migrate endpoint and run "Create todo and person table (m:1)" to learn lookup behavior
2. Implement lookup column type

[] Qore-Base integration
[x] Delete id (auto created when creating a table)
[x] In 'migration' attribute of creating a relation, 'nullable' attribute is required

[x] Create Index

[] One-to-One relation using lookup fields?

[] Complete select properties

```
export type SelectInstruction = {
  condition?: FilterQuery<{}>;
  populate?: string[];
  join?: "left" | "inner";
  limit?: number;
  offset?: number;
  groupBy?: string[];
  orderBy?: OrderBy;
  fields?: string[];
  params?: Record<string, string>;
} & DMLInstruction;
```

[x] View
[x] Add `conditions` attribute!
[x] other attributes : order, limit, offset, etc

[x] Create role&permissions ddl
[x] Make 1 row of dsl can use some operation for 1 table combinations
[x] Create filtered table row permissions

[] Complete qore-data supported column type in DSL (sisa yg aneh2 ex:action,rollup,)

[] Complete qore-data supported definitons in DSL (pk, fk)
