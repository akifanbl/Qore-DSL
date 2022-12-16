{
  function generateModel(table, columns) {
    let separator = columns.length > 0? ',' : ''
    let result = JSON.parse(`[${table} ${separator} ${columns}]`)
    let tableName = result[0].migration.name
    result.forEach((op) => {
      if (op.resource == 'Column'){
         op.migration.table = tableName
      } else if (op.resource.includes("Relation")){
        if (op.resource.startsWith("OneToMany")){
      	  op.migration.one = {"table":tableName}
        } else if (op.resource.startsWith("ManyToOne")){
      	  op.migration.many = {"table":tableName}
        } else if (op.resource.startsWith("ManyToMany")){
       	  op.migration.origin = {"table":tableName}
        }
      }
    })
    return result;
  }
  
  function generateRolePermission(role, permissions) {
    let separator = permissions.length > 0? ',' : ''
    let result = JSON.parse(`[${role} ${separator} ${permissions}]`)
    let roleName = result[0].migration.name
    result.forEach((op) => {
      if (op.resource == 'Permission'){
         op.migration.role = roleName
      }
    })
    return result;
  }
  
  function mergeOperations(models) {
  	const merged = [].concat(...models);
    return {"operations": merged}
  }
  
  function mergeColumnDefinition(input_definitions, default_definitions){
     let merged = default_definitions ? default_definitions : {}
     if (input_definitions){
       input_definitions.forEach((def) => {
         merged = Object.assign(merged, def)
       })
     }
     return JSON.stringify(merged)
  }
  
  function buildObject(props){
    let obj = {}
    props.forEach((prop) => {
    	obj = Object.assign(obj, prop)
    })
    return obj;
  }
  
  function generateRelationMigration(name, targetTable, relType, relDefs){
   let migration = {"name":name, "onUpdate" : "CASCADE", "onDelete" : "CASCADE"}
   switch (relType){
     case ("OneToManyRelation"):
       migration["many"] = {"table":targetTable}
       break;
     case ("ManyToOneRelation"):
       migration["one"] = {"table":targetTable}
       break;
     case ("ManyToManyRelation"):
       migration["target"] = {"table":targetTable}
       break;       
   }
   relDefs.forEach((def) => {
      migration = Object.assign(migration, def)
   })
   return JSON.stringify(migration)
  }
}

start
	= Entities

Entities = entities:(Model/RolePermission)* {return mergeOperations(entities)}
/* Model */
Model
	= _ "model" _ table:Table _ "{"_ columns:Columns _"}" _
    {return generateModel(table,columns)}

Table = tableName:TableName {return `{"operation": "Create", "resource": "Table", "migration": {"name": "${tableName}"}}`}
TableName = VariableName
Column = _ colName:ColumnName _ colType:ColumnType _ colDefs:ColumnDefinitionsInput {return `{"operation": "Create", "resource": "Column","migration":{"name":"${colName}","table":"","column": {"type":"${colType.type}", "definition": ${mergeColumnDefinition(colDefs,colType.definition)}}}}`}
Relation = _ colName:ColumnName _ tableName:TableName _ relType:RelationType _ relDefs:RelationDefinitions {return `{"operation": "Create", "resource": "${relType}","migration":${generateRelationMigration(colName, tableName, relType, relDefs)}}` }
Columns = (Column/Relation)*
ColumnName = VariableName
ColumnType = BigIntegerType / BooleanType / DateType / DateTimeType / FileType / FloatType / IntegerType / StringType 
ColumnDefinition = (Unique / Default / PK / Nullable)
ColumnDefinitions = ColumnDefinition* 
ColumnDefinitionsInput = "[" colDefs:ColumnDefinitions "]" {return colDefs} / ""
RelationDefinition = RelationConstraintOnUpdate / RelationConstraintOnDelete
RelationDefinitions = RelationDefinition*
RelationType = rel:("OneToMany" / "ManyToOne" / "ManyToMany" / "OneToOne") {return `${rel}Relation`}
RelationConstraintOnUpdate = _("OnUpdate" / "onUpdate" / "onupdate" / "ONUPDATE") _ ":" _ val:RelationConstraintType _ {return {"onUpdate": val}}
RelationConstraintOnDelete = _"OnDelete" _ ":" _ val:RelationConstraintType _ {return {"onDelete": val}}
RelationConstraintType = "CASCADE" / "RESTRICT" / "SETNULL"

/*Role & Permissions*/
RolePermission = _ "role" _ role:Role _ "{"_ permissions:Permissions _"}" _ {return generateRolePermission(role,permissions)}
Role = roleName:RoleName {return `{"operation":"Create", "resource":"Role", "migration": {"name":"${roleName}", "deletionProtection":true}}`}
RoleName = VariableName
Permissions = (Permission)*
Permission = _ type:PermissionType _ "[" tables:( _ TableName _ )+ "]" {return `{"operation":"Create", "resource":"Permission", "migration": {"role":"", "tables":${tables}, "actions": ["${type}"]}}`}
PermissionType = "insert"/"select"/"update"/"delete"/"insight"


/*DSL Column Type*/
BigIntegerType = "bigint" {return {"type":"bigint", "definition": { "default": 0, "nullable": true }}}
BooleanType = "bool" {return {"type":"boolean", "definition": { "default": null, "nullable": true }}}
DateType = "date" {return {"type":"date", "definition" : { "default": "now()", "exact": false, "nullable": true }}}
DateTimeType = "datetime" {return {"type":"datetime", "definition" : { "default": "now()", "exact": false, "nullable": true, "triggers": [] }}}
FileType = "file" {return {"type":"file","definition" : {"extensions": ".jpg, .png, .svg","default": { "filename": "", "size": 0, "mime": "application/octet-stream" }}}}
FloatType = "float" {return {"type":"float","definition": {"precision": 8, "scale": 2, "default": 0, "nullable": true}}}
IntegerType = "int" {return {"type":"integer", "definition": {"default":0, "nullable":true}}}
StringType = "str" {return {"type":"text", "definition": {"textType": "text"}}}

/*Column Definition*/
PK = _ "pk" _ {return {"primary_key":true, "nullable":false}}
Unique = _"unique" _ ":" _ val:Boolean _ {return {"unique": val}}
Nullable = _"nullable" _ ":" _ val:Boolean _ {return {"nullable": val}}
Default = _"default" _ ":" _ val:AllType _ {return {"default": val}}
FK = _ "fk" _ "(" _ ")" _
/* Variable name syntax */
VariableName "valid variable name syntax"
  = [a-zA-Z_0-9]+ {return text()}

/* Basic Type */
Char = .
String "string" = '"'val:[^"]*'"' { return `${val.join('')}`} / "'"val:[^']*"'" { return `${val.join('')}`}
Integer "integer"
  = [0-9]+ { return parseInt(text(), 10); }
Float "float"
    = left:[0-9]+ "." right:[0-9]+ { return parseFloat(left.join("") + "." +   right.join("")); }
Object "object" = "{" props: Properties "}" {return props}
Properties = props: Property* {return buildObject(props)}
Property = _ key:VariableName _ ":" _ value:AllType _ {return {[key] : value}} 
Boolean "boolean" = "true" { return true } / "false" { return false}
AllType = String / Float / Integer / Boolean / Object

_ "whitespace"
  = [ \t\n\r]*