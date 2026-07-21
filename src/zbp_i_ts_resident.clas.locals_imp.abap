CLASS lhc_resident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR resident RESULT result.

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

ENDCLASS.
