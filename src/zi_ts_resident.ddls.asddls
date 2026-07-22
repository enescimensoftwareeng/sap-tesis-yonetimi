@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sakinler CDS View'
@Metadata.allowExtensions: true
define root view entity ZI_TS_RESIDENT
  as select from zts_resident
{
  key resident_id            as ResidentId,
      block_id               as BlockId,
      apartment_no           as ApartmentNo,
      first_name             as FirstName,
      last_name              as LastName,
      phone_number           as PhoneNumber,
      is_owner               as IsOwner,
      
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_TS_VH_DURUM', element: 'Durum' } }]
      portal_status          as PortalStatus,
      
      created_by             as CreatedBy,
      created_at             as CreatedAt,
      last_changed_by        as LastChangedBy,
      last_changed_at        as LastChangedAt,
      local_last_changed_at  as LocalLastChangedAt
}
