class ZCL_ZVKT_ODATA_EO_006_DPC_EXT definition
  public
  inheriting from ZCL_ZVKT_ODATA_EO_006_DPC
  create public .

public section.
protected section.

  methods HEADERSET_CREATE_ENTITY
    redefinition .
  methods HEADERSET_DELETE_ENTITY
    redefinition .
  methods HEADERSET_GET_ENTITY
    redefinition .
  methods HEADERSET_UPDATE_ENTITY
    redefinition .
  methods ITEMSET_CREATE_ENTITY
    redefinition .
  methods ITEMSET_DELETE_ENTITY
    redefinition .
  methods ITEMSET_GET_ENTITY
    redefinition .
  methods ITEMSET_GET_ENTITYSET
    redefinition .
  methods ITEMSET_UPDATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZVKT_ODATA_EO_006_DPC_EXT IMPLEMENTATION.


  METHOD headerset_create_entity.
    DATA: lt_entity TYPE TABLE OF zvkt_eo_t007,
          ls_entity LIKE LINE OF lt_entity.

    TRY.
        io_data_provider->read_entry_data(
          IMPORTING
            es_data                      = ls_entity
        ).
      CATCH /iwbep/cx_mgw_tech_exception.

    ENDTRY.

    IF ls_entity IS NOT INITIAL.
      SELECT SINGLE COUNT(*)
        FROM zvkt_eo_t007
        WHERE vbeln = @ls_entity-vbeln
        INTO @DATA(ls_count).
      IF sy-subrc NE 0.
        INSERT zvkt_eo_t007 FROM ls_entity.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.
        ROLLBACK WORK.
      ENDIF.

     ELSE.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            textid                 = /iwbep/cx_mgw_busi_exception=>business_error
            message                = 'Yapılacak olan insert işleminde veriler tabloda bulunuyor.'
       .
    ENDIF.
  ENDMETHOD.


  METHOD headerset_delete_entity.
    DATA lv_vbeln TYPE vbeln.

    READ TABLE it_key_tab INTO DATA(ls_key) WITH KEY name = 'Vbeln'.
    IF sy-subrc EQ 0.
      lv_vbeln = ls_key-value.
    ENDIF.

    lv_vbeln = |{ lv_vbeln ALPHA = IN }|.

    DELETE FROM zvkt_eo_t007
    WHERE vbeln = lv_vbeln.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDMETHOD.


  METHOD headerset_get_entity.
    DATA lv_vbeln TYPE vbeln_va.

    READ TABLE it_key_tab INTO DATA(ls_key) WITH KEY name = 'Vbeln'.
    IF sy-subrc EQ 0.
      lv_vbeln = ls_key-value.
    ENDIF.

    lv_vbeln = |{ lv_vbeln ALPHA = IN }|.

    SELECT SINGLE *
      FROM zvkt_eo_t007
      INTO CORRESPONDING FIELDS OF er_entity
      WHERE vbeln = lv_vbeln.

  ENDMETHOD.


  METHOD headerset_update_entity.
    DATA : lt_entity TYPE TABLE OF zvkt_eo_t007,
           ls_entity LIKE LINE OF lt_entity.

    TRY.
        io_data_provider->read_entry_data(
          IMPORTING
            es_data                      = ls_entity
        ).
      CATCH /iwbep/cx_mgw_tech_exception.

    ENDTRY.

    IF ls_entity IS NOT INITIAL.

      SELECT SINGLE COUNT(*)
        FROM zvkt_eo_t007
        WHERE vbeln = @ls_entity-vbeln
        INTO @DATA(ls_count).

      IF sy-subrc EQ 0.
        UPDATE zvkt_eo_t007 FROM ls_entity.
        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.

      ENDIF.
    ELSE.

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = 'UPDATE Yapılacak olan veri tabloda bulunmuyor.'.

    ENDIF.
    MOVE-CORRESPONDING ls_entity TO er_entity.

  ENDMETHOD.


  METHOD itemset_create_entity.
    DATA :lt_entity TYPE TABLE OF zvkt_eo_t008,
          ls_entity LIKE LINE OF lt_entity.

    TRY.
        io_data_provider->read_entry_data(
          IMPORTING
            es_data                      = ls_entity
        ).
      CATCH /iwbep/cx_mgw_tech_exception.

    ENDTRY.

    IF  ls_entity IS NOT INITIAL.

      SELECT SINGLE COUNT(*)
        FROM zvkt_eo_t008
        WHERE vbeln = @ls_entity-vbeln
        INTO @DATA(ls_count).

      IF sy-subrc NE 0.

        INSERT zvkt_eo_t008 FROM ls_entity.

        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.
        ROLLBACK WORK.
      ENDIF.

    ELSE.
      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid  = /iwbep/cx_mgw_busi_exception=>business_error
          message = 'Kayıt edilecek olan veriler tabloda bulunuyor.'.
    ENDIF.
  ENDMETHOD.


  METHOD itemset_delete_entity.
    DATA: lv_vbeln TYPE vbeln,
          lv_posnr TYPE posnr.

    READ TABLE it_key_tab INTO DATA(ls_key) WITH KEY name = 'Vbeln'.
    IF sy-subrc EQ 0.
      lv_vbeln = ls_key-value.
    ENDIF.

    READ TABLE it_key_tab INTO ls_key WITH KEY name = 'Posnr'.
    IF sy-subrc EQ 0.
      lv_posnr = ls_key-value.
    ENDIF.


    lv_vbeln = |{ lv_vbeln ALPHA = IN }|.
    lv_posnr = |{ lv_posnr ALPHA = IN }|.

    DELETE FROM zvkt_eo_t008
    WHERE vbeln = lv_vbeln and
          posnr = lv_posnr.
    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDMETHOD.


  METHOD itemset_get_entity.
    DATA: lv_vbeln TYPE vbeln,
          lv_posnr TYPE posnr.

    READ TABLE it_key_tab INTO DATA(ls_key) WITH KEY name = 'Vbeln'.
    IF sy-subrc EQ 0.
      lv_vbeln = ls_key-value.
    ENDIF.
    lv_vbeln = |{ lv_vbeln ALPHA = IN }|.

    READ TABLE it_key_tab INTO ls_key WITH KEY name = 'Posnr'.
    IF sy-subrc EQ 0.
      lv_posnr = ls_key-value.
    ENDIF.
    lv_posnr = |{ lv_posnr ALPHA = IN }|.

    SELECT SINGLE *
      FROM zvkt_eo_t008
      INTO CORRESPONDING FIELDS OF er_entity
      WHERE vbeln = lv_vbeln AND
            posnr = lv_posnr.
  ENDMETHOD.


  METHOD itemset_get_entityset.

    DATA r_vbeln TYPE RANGE OF vbeln_va.

    LOOP AT it_filter_select_options INTO DATA(ls_filter).
      CASE ls_filter-property.
        WHEN 'Vbeln'.
          MOVE-CORRESPONDING ls_filter-select_options TO r_vbeln.
      ENDCASE.
    ENDLOOP.

    SELECT *
      FROM zvkt_eo_t008
      INTO CORRESPONDING FIELDS OF TABLE et_entityset
      WHERE (iv_filter_string).

    SELECT *
      FROM zvkt_eo_t008
      INTO TABLE @DATA(lt_item)
      WHERE vbeln IN @r_vbeln.

  ENDMETHOD.


  METHOD itemset_update_entity.
    DATA : lt_entity TYPE TABLE OF zvkt_eo_t008,
           ls_entity LIKE LINE OF lt_entity.

    TRY.
        io_data_provider->read_entry_data(
          IMPORTING
            es_data                      = ls_entity
        ).
      CATCH /iwbep/cx_mgw_tech_exception.

    ENDTRY.

    IF ls_entity IS NOT INITIAL.

      SELECT SINGLE COUNT(*)
        FROM zvkt_eo_t008
        WHERE vbeln = @ls_entity-vbeln
        AND posnr = @ls_entity-posnr
        INTO @DATA(ls_count).

      IF sy-subrc EQ 0.
        UPDATE zvkt_eo_t008 FROM ls_entity.

        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
        ENDIF.

      ENDIF.
      MOVE-CORRESPONDING ls_entity TO er_entity.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
