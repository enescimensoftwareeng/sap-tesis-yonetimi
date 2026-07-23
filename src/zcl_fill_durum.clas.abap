CLASS zcl_fill_durum DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_fill_durum IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA: lt_durum TYPE TABLE OF zts_durum.

    " 1. Eski verileri temizle (Mükerrer kaydı önlemek için)
    DELETE FROM zts_durum.

    " 2. Eklenecek yeni seçenekleri hazırla
    lt_durum = VALUE #(
      ( durum = 'AKTİF' )
      ( durum = 'BEKLEMEDE' )
      ( durum = 'PASİF' )
    ).

    " 3. Verileri doğrudan veritabanı tablosuna kaydet
    INSERT zts_durum FROM TABLE @lt_durum.

    " 4. Ekrana (Konsola) başarı mesajı yazdır
    out->write( 'Tebrikler! Veriler ZTS_DURUM tablosuna başarıyla eklendi!' ).
  ENDMETHOD.

ENDCLASS.
