class ZCL_ZVKT_ODATA_EO_001_DPC_EXT definition
  public
  inheriting from ZCL_ZVKT_ODATA_EO_001_DPC
  create public .

public section.
protected section.

  methods HEADERSET_GET_ENTITY
    redefinition .
  methods HEADERSET_GET_ENTITYSET
    redefinition .
  methods ITEMSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZVKT_ODATA_EO_001_DPC_EXT IMPLEMENTATION.


  METHOD headerset_get_entity.

    DATA lv_ebeln TYPE ebeln.

    READ TABLE it_key_tab INTO DATA(ls_key) WITH KEY name = 'Ebeln'.
    IF sy-subrc EQ 0.
    lv_ebeln = ls_key-value.
    ENDIF.

    lv_ebeln = |{ lv_ebeln ALPHA = IN }|.

    SELECT SINGLE *
      FROM zodata_t_header INTO CORRESPONDING FIELDS OF er_entity
      WHERE ebeln = lv_ebeln.
  ENDMETHOD.


  method HEADERSET_GET_ENTITYSET.

  endmethod.


  METHOD itemset_get_entityset.

    DATA r_ebeln TYPE RANGE OF ebeln.
    LOOP AT  it_filter_select_options INTO DATA(ls_filter).
      CASE ls_filter-property.
        WHEN 'Ebeln'.
          MOVE-CORRESPONDING ls_filter-select_options TO r_ebeln.
      ENDCASE.

    ENDLOOP.

    SELECT *
      FROM zodata_t_item
      INTO CORRESPONDING FIELDS OF TABLE et_entityset
      WHERE (iv_filter_string).



  ENDMETHOD.
ENDCLASS.
