*&---------------------------------------------------------------------*
*& Include          ZVKT_RAP_E_007_CLS
*&---------------------------------------------------------------------*

CLASS lcl_alv2 DEFINITION.
  PUBLIC SECTION.

    TYPES: BEGIN OF gty_mara,
             matnr TYPE matnr,
             ernam TYPE ernam,
             laeda TYPE laeda,
             matkl TYPE matkl,
             ntgew TYPE ntgew,
             gewei TYPE gewei,
           END OF gty_mara.

    DATA: gs_mara2 TYPE gty_mara,
          gt_mara2 TYPE TABLE OF gty_mara.

    DATA: gt_fcat   TYPE lvc_t_fcat,
          gs_fcat   TYPE lvc_s_fcat,
          gs_layout TYPE lvc_s_layo.

    DATA : go_alv  TYPE REF TO cl_gui_alv_grid.
    DATA : go_konti TYPE REF TO cl_gui_custom_container.

    DATA: go_split    TYPE REF TO cl_gui_splitter_container,
          go_subcont1 TYPE REF TO cl_gui_container,
          go_subcont2 TYPE REF TO cl_gui_container.

    METHODS : get_data,
      set_fcat,
      set_layo,
      display_alv.

    METHODS: handle_hotspot_click FOR EVENT hotspot_click
            OF cl_gui_alv_grid IMPORTING e_column_id
                                          e_row_id
                                          es_row_no,
    handle_data_changed FOR EVENT data_changed
          OF cl_gui_alv_grid IMPORTING er_data_changed,

    handle_data_toolbar FOR EVENT toolbar
          OF cl_gui_alv_grid IMPORTING e_interactive
                                       e_object,

    handle_user_command FOR EVENT user_command
          OF cl_gui_alv_grid IMPORTING e_ucomm.



ENDCLASS.

CLASS lcl_alv2 IMPLEMENTATION.

  METHOD get_data.
    SELECT  matnr,
            ernam,
            laeda,
            matkl,
            ntgew,
            gewei
      FROM mara
      INTO TABLE @gt_mara2.
  ENDMETHOD.

  METHOD set_fcat.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = 'ZVKT_S0047'
      CHANGING
        ct_fieldcat      = gt_fcat.

    LOOP AT  gt_fcat ASSIGNING FIELD-SYMBOL(<lfs_fcat>).
      CASE <lfs_fcat>-fieldname.
        WHEN 'MATNR'.
          <lfs_fcat>-hotspot = abap_true.
        WHEN 'MATKL'.
          <lfs_fcat>-edit = abap_true.
*       WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_layo.
    gs_layout-zebra = abap_true .
    gs_layout-cwidth_opt = abap_true .
    gs_layout-col_opt = abap_true .
  ENDMETHOD.

  METHOD display_alv.
*    go_alv = NEW cl_gui_alv_grid(
*        i_parent          = cl_gui_container=>screen0 ).
*
*    CALL METHOD go_alv->set_table_for_first_display
*      EXPORTING
*        is_layout       = gs_layout  " Layout
*      CHANGING
*        it_outtab       = gt_mara2   " Output Table
*        it_fieldcatalog = gt_fcat.  " Field Catalog

    go_konti = NEW cl_gui_custom_container(
        container_name              = 'CC_EMINE' ).

    go_alv = NEW cl_gui_alv_grid(
     i_parent          = go_konti ).

    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout  " Layout
      CHANGING
        it_outtab       = gt_mara2   " Output Table
        it_fieldcatalog = gt_fcat.  " Field Catalog

  ENDMETHOD.

  METHOD handle_hotspot_click.

    DATA: lv_date TYPE datum.

    READ TABLE gt_mara2 ASSIGNING FIELD-SYMBOL(<lfs_mara2>) INDEX e_row_id-index.

    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal = <lfs_mara2>-laeda
      IMPORTING
        date_external = lv_date.


    DATA(lv_message) = |Bu malzeme | & | | & |{ <lfs_mara2>-ernam }| & | | & |tarafından | & | | &
    |{ <lfs_mara2>-laeda }| & |tarihinde oluşturulmuştur. |.

    MESSAGE lv_message TYPE 'I'.
  ENDMETHOD.

  METHOD handle_data_changed.

  ENDMETHOD.

  METHOD handle_data_toolbar.

  ENDMETHOD.

  METHOD handle_user_command.
  ENDMETHOD.

ENDCLASS.
