CLASS zcl_ts_resident_gen DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    " Bu interface, class'ı konsol uygulaması gibi F9 ile çalıştırmamızı sağlar
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_ts_resident_gen IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA: lt_residents TYPE TABLE OF zts_resident.

    " Testin her çalışmasında verilerin çakışmaması için önce tabloyu temizliyoruz
    DELETE FROM zts_resident.

    " Tabloya eklenecek örnek sakinleri tanımlıyoruz
    lt_residents = VALUE #(
      ( client = sy-mandt
        resident_id = cl_system_uuid=>create_uuid_x16_static( )
        block_id = 'A1'
        apartment_no = '15'
        first_name = 'Muhammed Enes'
        last_name = 'Cimen'
        phone_number = '+905551234567'
        is_owner = abap_true
        portal_status = 'AKTIF' )

      ( client = sy-mandt
        resident_id = cl_system_uuid=>create_uuid_x16_static( )
        block_id = 'B2'
        apartment_no = '7'
        first_name = 'Ahmet'
        last_name = 'Yilmaz'
        phone_number = '+905329876543'
        is_owner = abap_false
        portal_status = 'BEKLEMEDE' )
    ).

    " Verileri fiziksel olarak veritabanına basıyoruz
    INSERT zts_resident FROM TABLE @lt_residents.

    " Konsola başarı mesajı yazdırıyoruz
    out->write( |Harika! Tabloya { lines( lt_residents ) } adet kayit basariyla eklendi.| ).
  ENDMETHOD.
ENDCLASS.
