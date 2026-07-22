CLASS lhc_resident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR resident RESULT result.
    METHODS validatemandatoryfields FOR VALIDATE ON SAVE
      IMPORTING keys FOR resident~validatemandatoryfields.
    METHODS setinitialstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR resident~setinitialstatus.
    METHODS setactive FOR MODIFY
      IMPORTING keys FOR ACTION resident~setactive RESULT result.

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
  METHOD setInitialStatus.
    " 1. Eklenen yeni kayıtların güncel durumunu oku
    READ ENTITIES OF ZI_TS_RESIDENT IN LOCAL MODE
      ENTITY Resident
        FIELDS ( PortalStatus ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_residents).

    " 2. Güncellenecek veriler için geçici bir tablo oluştur
    DATA: lt_update TYPE TABLE FOR UPDATE ZI_TS_RESIDENT.

    " 3. Kayıtları döngüye al
    LOOP AT lt_residents INTO DATA(ls_resident).
      " Eğer kullanıcı portal durumunu boş bıraktıysa 'BEKLEMEDE' olarak ayarla
      IF ls_resident-PortalStatus IS INITIAL.
        APPEND VALUE #( %tky = ls_resident-%tky
                        PortalStatus = 'BEKLEMEDE'
                        %control-PortalStatus = if_abap_behv=>mk-on ) TO lt_update.
      ENDIF.
    ENDLOOP.

    " 4. Eğer değiştirilecek bir kayıt varsa veritabanını (taslağı) güncelle
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF ZI_TS_RESIDENT IN LOCAL MODE
        ENTITY Resident
          UPDATE FROM lt_update
        REPORTED DATA(lt_reported).

      " Olası sistem mesajlarını UI tarafına ilet
      reported-resident = CORRESPONDING #( lt_reported-resident ).
    ENDIF.
  ENDMETHOD.

  METHOD setActive.
    " 1. Seçilen kayıtların durumunu 'AKTİF' olarak güncelle
    MODIFY ENTITIES OF ZI_TS_RESIDENT IN LOCAL MODE
      ENTITY Resident
        UPDATE
          FIELDS ( PortalStatus )
          WITH VALUE #( FOR key IN keys ( %tky = key-%tky PortalStatus = 'AKTİF' ) )
      FAILED failed
      REPORTED reported.

    " 2. Ekranın (Fiori) güncel veriyi anında görebilmesi için kaydı tekrar oku
    READ ENTITIES OF ZI_TS_RESIDENT IN LOCAL MODE
      ENTITY Resident
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_residents).

    " 3. Güncel veriyi Fiori UI'a sonuç (result) olarak geri gönder
    result = VALUE #( FOR resident IN lt_residents ( %tky = resident-%tky %param = resident ) ).
  ENDMETHOD.

ENDCLASS.
