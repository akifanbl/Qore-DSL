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
      	  op.migration.one = op.migration.one || {"table":tableName}
      	  op.migration.many = op.migration.many || {"table":tableName}
        } else if (op.resource.startsWith("ManyToMany")){
       	  op.migration.origin = {"table":tableName}
        }
        op.migration.nullable = op.migration.nullable || true;
      }
    })
    return result;
  }
  
  function generateView(view, table, viewAttributes) {
    let separator = columns.length > 0? ',' : ''
    let result = JSON.parse(`[${view}]`)
    
    result[0].migration = {
    	name: result[0].migration.name,
        table,
    }
    
    viewAttributes.forEach(el => {
    	for(var k in el) result[0].migration[k]=el[k];
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
  
  function generatePermissions(types, tables){
    let operations = ''
    tables.forEach(el => {
      operations += `{"operation":"Create", "resource":"Permission", "migration": {"role":"", "tables": [${el.tableName}], ${el.condition !== "null"? `"condition": ${el.condition},` : ''} "actions": [${types}]}},`
    })
    
    return operations.slice(0,-1);
  }

  function generateIndex(index,indexRequiredAttributes,indexOptionalAttributes) {
  	let separator = columns.length > 0? ',' : ''
    let result = JSON.parse(`[${index}]`)
    
  
    indexRequiredAttributes.forEach(el => {
    	for(var k in el) result[0].migration[k]=el[k];
    })
    
    indexOptionalAttributes.forEach(el => {
    	for(var k in el) result[0].migration[k]=el[k];
    })

  
    return result;
  }
}

start
	= Entities

Entities = entities:(Model/View/RolePermission/Index)* {return mergeOperations(entities)}
/* Model */
Model
	= _ "model" _ table:Table _ "{"_ columns:Columns _"}" _
    {return generateModel(table,columns)}

Table = tableName:TableName {return `{"operation": "Create", "resource": "Table", "migration": {"name": "${tableName}"}}`}
TableName = VariableName
Column = _ colName:ColumnName _ colType:ColumnType _ colDefs:ColumnDefinitionsInput {return `{"operation": "Create", "resource": "Column","migration":{"name":"${colName}","table":"","column": {"type":"${colType.type}", "definition": ${mergeColumnDefinition(colDefs,colType.definition)}}}}`}
Relation = _ colName:ColumnName _ tableName:TableName _ relType:RelationType _ relDefs:RelationDefinitions {return `{"operation": "Create", "resource": "${relType == "ManyToOneRelation"?"OneToManyRelation": relType}","migration":${generateRelationMigration(colName, tableName, relType, relDefs)}}` }
Columns = (Column/Relation)*
ColumnName = VariableName
ColumnType = BigIntegerType / BooleanType / DateTimeType / DateType / FileType / FloatType / IntegerType / JSONType / LinestringType / MultipleFileType / PasswordType / PointType / PolygonType / RawType / RichTextType / SelectType / StringType / TimestampType
ColumnDefinition = (Enums / Unique / Default / PK / Nullable)
ColumnDefinitions = ColumnDefinition* 
ColumnDefinitionsInput = "[" colDefs:ColumnDefinitions "]" {return colDefs} / ""
RelationDefinition = RelationConstraintOnUpdate / RelationConstraintOnDelete / Nullable
RelationDefinitions = RelationDefinition*
RelationType = rel:("OneToMany" / "ManyToOne" / "ManyToMany" / "OneToOne") {return `${rel}Relation`}
RelationConstraintOnUpdate = _("OnUpdate" / "onUpdate" / "onupdate" / "ONUPDATE") _ ":" _ val:RelationConstraintType _ {return {"onUpdate": val}}
RelationConstraintOnDelete = _"OnDelete" _ ":" _ val:RelationConstraintType _ {return {"onDelete": val}}
RelationConstraintType = "CASCADE" / "RESTRICT" / "SET NULL"
 
/*View*/
View
	= _ "view" _ viewName:ViewName _ ":" _ tableName:TableName _  "{"_ viewAttributes:SelectProperties _"}" _
    {return generateView(viewName,tableName,viewAttributes)} 
ViewName = viewName:VariableName {return `{"operation": "Create", "resource": "View", "migration": {"name": "${viewName}"}}`}

/*Index*/
Index = _ "index" _ indexName:IndexName _ "{" _ indexRequiredAttributes:IndexRequiredAttributes _ indexOptionalAttributes:IndexOptionalAttributes _ "}" {return generateIndex(indexName,indexRequiredAttributes,indexOptionalAttributes)}
IndexName = indexName:VariableName {return `{"operation": "Create", "resource": "Index", "migration": {"name": "${indexName}"}}`}
IndexRequiredAttributes = (IndexTable IndexColumns) / (IndexColumns IndexTable)
IndexOptionalAttributes = (Unique/Condition/IndexType)*
IndexTable = _ "table" _ tableName:TableName { return {"table": tableName}}
IndexColumns = _ "columns" _ "[" columns:(_ column:(ColumnName) _ {return `${column}`})* "]" {return {columns: columns} }
IndexType = _ "type" _ type:IndexTypeEnum { return {"type": type}}
IndexTypeEnum = "btree" / "hash" / "gist" / "gin" / "spgist" / "brin"

/*Select Properties*/
SelectProperties = (Fields/Condition/Populate/Limit/Offset/GroupBy/Join)*
Fields = _ "fields" _ "[" fields:(_ fieldName:(ColumnName) _ {return `${fieldName}`})* "]" {return {"fields": fields} }
Condition = _ "condition" _ formulaWithPrefix:(formula:String {return `Formula: ${formula}`}) _ {return {"condition": {"$and": [{[formulaWithPrefix] : {"$eq": true}}]}}}
Limit = _ "limit" _ limit:Integer _ {return {"limit": limit}}
Offset = _ "offset" _ offset:Integer _ {return {"offset": offset}}
Populate = _ "populate" _ "[" populate:(_ fieldName:(ColumnName) _ {return `${fieldName}`})* "]" {return {"populate": populate} }
GroupBy = _ "groupBy" _ "[" groupBy:(_ fieldName:(ColumnName) _ {return `${fieldName}`})* "]" {return {"groupBy": groupBy} }
Join = _ "join" _ join:("left"/"inner") _ {return {"join": join}}

/*Role & Permissions*/
RolePermission = _ "role" _ role:Role _ "{"_ permissions:Permissions _"}" _ {return generateRolePermission(role,permissions)}
Role = roleName:RoleName {return `{"operation":"Create", "resource":"Role", "migration": {"name":"${roleName}", "deletionProtection":false}}`}
RoleName = VariableName
Permissions = (Permission)*
Permission = types:(_ typeName: (PermissionType) _ {return `"${typeName}"`})* "[" tables: (_ tableName: (TableName) condition:( "[" formula:Formula "]" {return formula})? _  {return {tableName:`"${tableName}"`, condition: JSON.stringify(condition)}})* "]" {return generatePermissions(types, tables)}
Formula = formulaWithPrefix:(formula:String {return `Formula: ${formula}`}) {return {"$and": [{[formulaWithPrefix] : {"$eq": true}}]}}
PermissionType = "insert"/"select"/"update"/"delete"/"insight"

/*DSL Column Type*/
BigIntegerType = "bigint" {return {"type":"bigint", "definition": { "default": 0, "nullable": true }}}
BooleanType = "bool" {return {"type":"boolean", "definition": { "default": null, "nullable": true }}}
DateTimeType = "datetime" {return {"type":"datetime", "definition" : { "default": "now()", "exact": false, "nullable": true, "triggers": [] }}}
DateType = "date" {return {"type":"date", "definition" : { "default": "now()", "exact": false, "nullable": true }}}
FileType = "file" {return {"type":"file","definition" : {"extensions": ".jpg, .png, .svg","default": { "filename": "", "size": 0, "mime": "application/octet-stream" }}}}
FloatType = "float" {return {"type":"float","definition": {"precision": 8, "scale": 2, "default": 0, "nullable": true}}}
IntegerType = "int" {return {"type":"integer", "definition": {"default":0, "nullable":true}}}
JSONType = "json" {return {"type":"json", "definition": {"default":null, "nullable":true}}}
LinestringType = "linestring" {return {"type":"linestring", "definition": {"default":null, "nullable":true}}}
MultipleFileType = "multiFile" {return {"type":"multiple_files", "definition": {"default":null, "nullable":true}}}
PasswordType = "password" {return {"type":"password", "definition": {"textType": "text", "nullable":true, "algorithm": "sha256", "salt":"admin-secret"}}}
PointType = "point" {return {"type":"point", "definition": {"default": null, "nullable":true}}}
PolygonType = "polygon" {return {"type":"polygon", "definition": {"default": null, "nullable":true}}}
RawType = "raw" {return {"type":"polygon", "definition": {"default": null, "nullable":true, "raw": "(price * 2)"}}}
RichTextType = "richtext" {return {"type":"richtext", "definition": {"default": null, "nullable":true}}}
SelectType = "select" {return {"type":"select", "definition": {"default": null, "enums":[], "nullable": true}}}
StringType = "str" {return {"type":"text", "definition": {"textType": "text"}}}
TimestampType = "timestamp" {return {"type":"timestamp", "definition": {"default": "now()", "nullable": true}}}

/*Column Definition*/
Enums = _ "enums" _ ":" _  "[" values: (_ val: (AllType) _ {return val})* "]" {return {"enums": values }}
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