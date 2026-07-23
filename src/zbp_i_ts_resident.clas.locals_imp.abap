CLASS lhc_resident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR resident RESULT result.
    METHODS validateMandatoryFields FOR VALIDATE ON SAVE
      IMPORTING keys FOR resident~validateMandatoryFields.
    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR resident~setInitialStatus.
    METHODS setActive FOR MODIFY
      IMPORTING keys FOR ACTION resident~setActive RESULT result.
    METHODS validateApartmentConflict FOR VALIDATE ON SAVE
      IMPORTING keys FOR resident~validateApartmentConflict.

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
    " 1. Kontrol edilecek kayıtları oku
    READ ENTITIES OF ZI_TS_RESIDENT IN LOCAL MODE
      ENTITY Resident
        FIELDS ( FirstName LastName ApartmentNo ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_residents).

    LOOP AT lt_residents INTO DATA(ls_resident).

      IF ls_resident-FirstName IS INITIAL.
        APPEND VALUE #( %tky = ls_resident-%tky ) TO failed-resident.
        APPEND VALUE #( %tky = ls_resident-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = 'Ad alanı boş bırakılamaz!' )
                        %element-FirstName = if_abap_behv=>mk-on ) TO reported-resident.
      ENDIF.

      IF ls_resident-LastName IS INITIAL.
        APPEND VALUE #( %tky = ls_resident-%tky ) TO failed-resident.
        APPEND VALUE #( %tky = ls_resident-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = 'Soyad alanı boş bırakılamaz!' )
                        %element-LastName = if_abap_behv=>mk-on ) TO reported-resident.
      ENDIF.

      IF ls_resident-ApartmentNo IS INITIAL.
        APPEND VALUE #( %tky = ls_resident-%tky ) TO failed-resident.
        APPEND VALUE #( %tky = ls_resident-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text     = 'Daire Numarası boş bırakılamaz!' )
                        %element-ApartmentNo = if_abap_behv=>mk-on ) TO reported-resident.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.
  METHOD setInitialStatus.
    " 1. Yeni oluşturulan (Create) kayıtların anahtarlarını alarak mevcut durumlarını oku
    READ ENTITIES OF ZI_TS_RESIDENT IN LOCAL MODE
      ENTITY Resident
        FIELDS ( PortalStatus ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_residents).

    " 2. Sadece Portal Durumu boş bırakılanları bul ve 'BEKLEMEDE' olarak güncellemek için paket hazırla
    DATA lt_update TYPE TABLE FOR UPDATE ZI_TS_RESIDENT.

    LOOP AT lt_residents INTO DATA(ls_resident) WHERE PortalStatus IS INITIAL.
      APPEND VALUE #(
        %tky                  = ls_resident-%tky
        PortalStatus          = 'BEKLEMEDE' " Otomatik atanacak başlangıç değeri
        %control-PortalStatus = if_abap_behv=>mk-on " Sisteme bu alanın değişeceğini haber ver
      ) TO lt_update.
    ENDLOOP.

    " 3. Eğer güncellenecek (boş bırakılmış) kayıt varsa veritabanına/taslağa yaz
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF ZI_TS_RESIDENT IN LOCAL MODE
        ENTITY Resident
          UPDATE FROM lt_update
        REPORTED DATA(update_reported).

      " Olası sistem mesajlarını ana rapora aktar
      reported = CORRESPONDING #( DEEP update_reported ).
    ENDIF.
  ENDMETHOD.

  METHOD validateApartmentConflict.
    " 1. Kaydedilmek istenen kayıtların verilerini oku
    READ ENTITIES OF ZI_TS_RESIDENT IN LOCAL MODE
      ENTITY Resident
        FIELDS ( BlockId ApartmentNo FirstName LastName ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_residents).

    IF lt_residents IS INITIAL.
      EXIT.
    ENDIF.

    " 2. Veritabanındaki tüm mevcut kayıtları çekerek çakışma taraması yap
    SELECT FROM zts_resident
      FIELDS resident_id, block_id, apartment_no
      INTO TABLE @DATA(lt_existing_residents).

    LOOP AT lt_residents INTO DATA(ls_resident).
      " Kendi kendini (güncelleme durumunda) çakışma olarak saymaması için ID kontrolü ekliyoruz
      READ TABLE lt_existing_residents INTO DATA(ls_existing)
        WITH KEY block_id     = ls_resident-BlockId
                 apartment_no = ls_resident-ApartmentNo.

      IF sy-subrc = 0 AND ls_existing-resident_id <> ls_resident-ResidentId.
        " Çakışma tespit edildi! Hata fırlat ve kaydı engelle.
        APPEND VALUE #( %tky = ls_resident-%tky ) TO failed-resident.
        APPEND VALUE #( %tky = ls_resident-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = |Bu blok ve daire numarasına ({ ls_resident-BlockId } / { ls_resident-ApartmentNo }) zaten kayıtlı bir sakin bulunuyor!| )
                        %element-BlockId   = if_abap_behv=>mk-on
                        %element-ApartmentNo = if_abap_behv=>mk-on ) TO reported-resident.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD setActive.
    " 1. Butona basıldığında seçili olan kayıtların (keys) mevcut durumunu oku
    READ ENTITIES OF ZI_TS_RESIDENT IN LOCAL MODE
      ENTITY Resident
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_residents).

    " 2. Veritabanını güncellemek için bir değişiklik paketi (Modify Table) hazırla
    DATA lt_update TYPE TABLE FOR UPDATE ZI_TS_RESIDENT.

    LOOP AT lt_residents INTO DATA(ls_resident).
      APPEND VALUE #(
        %tky                  = ls_resident-%tky
        PortalStatus          = 'AKTİF' " <--- Durumu AKTİF olarak ez
        %control-PortalStatus = if_abap_behv=>mk-on " Bu alanın güncelleneceğini sisteme bildir
      ) TO lt_update.
    ENDLOOP.

    " 3. Hazırlanan değişiklik paketini veritabanına kaydet (Modify)
    MODIFY ENTITIES OF ZI_TS_RESIDENT IN LOCAL MODE
      ENTITY Resident
        UPDATE FROM lt_update
      FAILED failed
      REPORTED reported.

    " 4. Güncellenmiş veriyi tekrar oku ve ekrana (Fiori) geri gönder ki tablo yenilensin
    READ ENTITIES OF ZI_TS_RESIDENT IN LOCAL MODE
      ENTITY Resident
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT lt_residents.

    " 5. Sonucu (result) dışarı aktar
    result = VALUE #( FOR resident IN lt_residents
                      ( %tky   = resident-%tky
                        %param = resident ) ).
  ENDMETHOD.

ENDCLASS.
