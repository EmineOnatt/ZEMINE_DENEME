@AbapCatalog.sqlViewName: 'ZEO_CDS001'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS ORNEK'
@OData.publish: true

define view ZEO_DDL001 as select from acdoca {
   key rldnr,
   key rbukrs,
   key gjahr,
   key belnr,
   key docln,
    hsl,
    case 
    when hsl < 0
    then '-'
    when hsl > 0
    then '+'
    when hsl = 0
    then 'SIFIR'
    end as DURUM
    
    
} 
 