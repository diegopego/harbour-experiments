STATIC hTypes := {=>}

// Fun��o que abstrai tipo
FUNCTION getType( xVal )
    IF ValType( xVal ) == "H" .AND. HB_HHASKEY( xVal, "__typeName" )
       RETURN xVal[ "__typeName" ]
    ELSE
       RETURN ValType( xVal )
    ENDIF
 RETURN NIL


 function schema_factory(type, pattern, fields)
 schema := {
    "typeName"    => <string>,
    "type"        => <"object"|"string"|...>,
    "pattern"     => <regex string>,
    "fields"      => { <fieldName> => <sub-schema> | <field-hash> },
    "validate"    => {|val| ...optional valida��o extra do objeto... },
    "matchType"   => {|other| ... },
    "new"         => {|...args| cria inst�ncia... } 
  }
 return schema


 FUNCTION typeRegistry( cAction, cNamespace, cTypeName, xValue )
    LOCAL cFullName := Lower( AllTrim( cNamespace + "::" + cTypeName ) )
 
    DO CASE
    CASE cAction == "set"
       hTypes[ cFullName ] := xValue
    CASE cAction == "get"
       RETURN IIF( HB_HHASKEY( hTypes, cFullName ), hTypes[ cFullName ], NIL )
    CASE cAction == "has"
       RETURN HB_HHASKEY( hTypes, cFullName )
    CASE cAction == "all"
       RETURN hTypes
    ENDCASE
 
 RETURN NIL
 