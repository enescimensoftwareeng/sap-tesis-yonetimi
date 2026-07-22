@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Durum Açılır Menüsü'
@ObjectModel.resultSet.sizeCategory: #XS  
define view entity ZI_TS_VH_DURUM as select from zts_durum {
  key durum as Durum
}
