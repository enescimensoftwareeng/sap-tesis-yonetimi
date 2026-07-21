CLASS lhc_resident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR resident RESULT result.
    METHODS validatemandatoryfields FOR VALIDATE ON SAVE
      IMPORTING keys FOR resident~validatemandatoryfields.

ENDCLASS.

CLASS lhc_resident IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = VALUE #(
      FOR key IN keys
      ( %tky = key-%tky
        %update = if_abap_behv=>auth-allowed
        %delete = if_abap_behv=>auth-allowed
      )
    ).
  ENDMETHOD.

  METHOD validateMandatoryFields.
    " 1. İlgili kayıtların güncel durumlarını oku (Hafızaya al)
    READ ENTITIES OF ZI_TS_RESIDENT IN LOCAL MODE
      ENTITY Resident
        FIELDS ( FirstName LastName ApartmentNo ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_residents).

    " 2. Gelen her bir kaydı döngüye al ve ilgili alanları kontrol et
    LOOP AT lt_residents INTO DATA(ls_resident).

      " Ad alanı boş mu?
      IF ls_resident-FirstName IS INITIAL.
        APPEND VALUE #( %tky = ls_resident-%tky ) TO failed-resident.
        APPEND VALUE #( %tky = ls_resident-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Ad alanı zorunludur, boş bırakılamaz.' )
                        %element-FirstName = if_abap_behv=>mk-on ) TO reported-resident.
      ENDIF.

      " Soyad alanı boş mu?
      IF ls_resident-LastName IS INITIAL.
        APPEND VALUE #( %tky = ls_resident-%tky ) TO failed-resident.
        APPEND VALUE #( %tky = ls_resident-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Soyad alanı zorunludur, boş bırakılamaz.' )
                        %element-LastName = if_abap_behv=>mk-on ) TO reported-resident.
      ENDIF.

      " Daire No alanı boş mu?
      IF ls_resident-ApartmentNo IS INITIAL.
        APPEND VALUE #( %tky = ls_resident-%tky ) TO failed-resident.
        APPEND VALUE #( %tky = ls_resident-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Daire No alanı zorunludur, boş bırakılamaz.' )
                        %element-ApartmentNo = if_abap_behv=>mk-on ) TO reported-resident.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
