@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@EndUserText.label: 'Sakinler CDS View'
@Metadata.allowExtensions: true
define root view entity ZI_TS_RESIDENT
  as select from zts_resident
{
  key resident_id            as ResidentId,
  
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Blok'
      block_id               as BlockId,
      
      @EndUserText.label: 'Daire No'
      apartment_no           as ApartmentNo,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Ad'
      first_name             as FirstName,
      
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Soyad'
      last_name              as LastName,
      
      @EndUserText.label: 'Telefon'
      phone_number           as PhoneNumber,
      
      @EndUserText.label: 'Ev Sahibi mi?'
      is_owner               as IsOwner,
      
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_TS_VH_DURUM', element: 'Durum' } }]
      @EndUserText.label: 'Portal Durumu'
      portal_status          as PortalStatus,
      
      case portal_status
        when 'AKTİF'     then 3 // 3: Yeşil Renk (Olumlu)
        when 'BEKLEMEDE' then 2 // 2: Sarı/Turuncu Renk (Uyarı)
        when 'PASİF'     then 1 // 1: Kırmızı Renk (Olumsuz)
        else 0                  // 0: Gri Renk (Nötr)
      end                    as PortalStatusCriticality,
      
      created_by             as CreatedBy,
      created_at             as CreatedAt,
      last_changed_by        as LastChangedBy,
      last_changed_at        as LastChangedAt,
      local_last_changed_at  as LocalLastChangedAt
}
