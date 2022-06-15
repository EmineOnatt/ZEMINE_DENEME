*&---------------------------------------------------------------------*
*& Include          ZVKT_RAP_0064_CLS
*&---------------------------------------------------------------------*
CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    METHODS:
      screen_output,
      start_of_selection,
      get_data,
      "Toplam
      toplam,
      add_message IMPORTING iv_msg_type TYPE bapi_mtype
                            iv_msg_numb TYPE syst_msgno
                            iv_msg_id   TYPE syst_msgid
                            iv_par1     TYPE syst_msgv
                            iv_par2     TYPE syst_msgv
                            iv_par3     TYPE syst_msgv
                            iv_par4     TYPE syst_msgv
                  CHANGING  ct_return   TYPE bapirettab,
      prepare_alv,
      display_alv CHANGING cs_alvgird TYPE REF TO cl_gui_alv_grid
                           cs_layout  TYPE lvc_s_layo
                           cs_variant TYPE disvariant
                           ct_output  TYPE ANY TABLE
                           ct_fielcat TYPE lvc_t_fcat
                           ct_sort    TYPE lvc_t_sort,
      refresh_alv CHANGING cs_alvgird TYPE REF TO cl_gui_alv_grid,
      refresh_alv_2,
      get_selected_rows,
      print_adobe,
      print_smartform.

  PROTECTED SECTION.
    "ALV Tanımlamaları
    DATA: lv_cc            TYPE scrfname VALUE 'CC',
          lo_container     TYPE REF TO cl_gui_custom_container,
          lo_alvgrid       TYPE REF TO cl_gui_alv_grid,
          lt_fc            TYPE lvc_t_fcat,
          ls_layout        TYPE lvc_s_layo,
          ls_variant       TYPE disvariant,
          ls_stable        TYPE lvc_s_stbl,
          lt_exclude       TYPE ui_functions,
          lt_sort          TYPE lvc_t_sort,
          lt_selected_rows TYPE lvc_t_row,
          ls_selected_rows TYPE lvc_s_row,
          lv_lines         TYPE i.

  PRIVATE SECTION.
    METHODS:
      handle_data_changed  FOR EVENT data_changed   OF cl_gui_alv_grid IMPORTING er_data_changed,
      handle_hotspot_click FOR EVENT hotspot_click  OF cl_gui_alv_grid IMPORTING e_row_id
                                                                                   e_column_id
                                                                                   es_row_no,
      handle_toolbar       FOR EVENT toolbar        OF cl_gui_alv_grid IMPORTING e_object
                                                                                   e_interactive,
      handle_user_command  FOR EVENT user_command   OF cl_gui_alv_grid IMPORTING e_ucomm,
      clear_all,
      create_container    IMPORTING iv_cont_name TYPE scrfname
                          CHANGING  cs_container TYPE REF TO cl_gui_custom_container
                                    cs_alv_grid  TYPE REF TO cl_gui_alv_grid,
      create_container2   CHANGING  cs_alv_grid     TYPE REF TO cl_gui_alv_grid,
      create_layout       IMPORTING iv_title  TYPE lvc_title
                          EXPORTING es_layout TYPE lvc_s_layo,
      create_variant      IMPORTING iv_handle  TYPE slis_handl
                          EXPORTING es_variant TYPE disvariant,
      create_fcat         EXPORTING et_fc           TYPE lvc_t_fcat,
      modify_fcat         IMPORTING iv_field TYPE lvc_fname
                                    iv_text  TYPE string
                          CHANGING  ct_fc    TYPE lvc_t_fcat,
      modify_fcat_edit    IMPORTING iv_field TYPE lvc_fname
                          CHANGING  ct_fc    TYPE lvc_t_fcat,
      modify_fcat_no_out  IMPORTING iv_field TYPE lvc_fname
                          CHANGING  ct_fc    TYPE lvc_t_fcat,
      modify_fcat_hotspot IMPORTING iv_field TYPE lvc_fname
                          CHANGING  ct_fc    TYPE lvc_t_fcat,
      modify_fcat_chkbox  IMPORTING iv_field TYPE lvc_fname
                          CHANGING  ct_fc    TYPE lvc_t_fcat,
      modify_fcat_color   IMPORTING iv_field TYPE lvc_fname
                                    iv_color TYPE lvc_emphsz
                          CHANGING  ct_fc    TYPE lvc_t_fcat,
      exclude             IMPORTING iv_statu   TYPE char1
                          EXPORTING et_exclude TYPE ui_functions,
      sort_filter         IMPORTING iv_field       TYPE lvc_fname
                                    it_fc          TYPE lvc_t_fcat
                          CHANGING  ct_sort_filter TYPE lvc_t_sort,
      event_receiver      CHANGING cs_alvgird       TYPE REF TO cl_gui_alv_grid,
      get_tabname         IMPORTING iv_tabname      TYPE tabname.
ENDCLASS. "lcl_report DEFINITION

*----------------------------------------------------------------------*
* CLASS gcl_report IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_report IMPLEMENTATION.
  METHOD handle_data_changed.
*    DATA: ls_mod_cell  TYPE lvc_s_modi.
*    LOOP AT er_data_changed->mt_mod_cells INTO ls_mod_cell.
*      READ TABLE gt_output ASSIGNING FIELD-SYMBOL(<lfs_output>) INDEX ls_mod_cell-row_id.
*      IF sy-subrc = 0.
*        ASSIGN COMPONENT ls_mod_cell-fieldname OF STRUCTURE <lfs_output> TO FIELD-SYMBOL(<lfs_value>).
*        IF <lfs_value> IS ASSIGNED.
*          TRY .
*              <lfs_value> = ls_mod_cell-value.
*              IF  ls_mod_cell-fieldname EQ 'OMENG_S' AND
*                  <lfs_value> GT <lfs_output>-omeng.
*                MESSAGE i009(zsd_order) WITH <lfs_value> <lfs_output>-omeng DISPLAY LIKE 'E'.
*                <lfs_value>       = <lfs_output>-omeng.
*                LEAVE LIST-PROCESSING.
*              ENDIF.
*              UNASSIGN <lfs_value>.
*            CATCH cx_root INTO DATA(lo_root).
*          ENDTRY.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD. "handle_data_changed

  METHOD handle_hotspot_click.
*    DATA: lv_vbeln_va TYPE vbeln_va.
*
*    CLEAR: lv_vbeln_va.
*
*    CASE e_column_id.
*      WHEN 'VBELN'.
**        READ TABLE gt_output INTO gs_output INDEX e_row_id.
**        IF sy-subrc EQ 0.
**
**        ENDIF.
*        lv_vbeln_va =  VALUE #( gt_output[ e_row_id ]-vbeln OPTIONAL ).
*        SET PARAMETER ID: 'AUN' FIELD lv_vbeln_va.
*        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
*    ENDCASE.
  ENDMETHOD. "handle_hotspot_click

  METHOD handle_toolbar.
*    DATA: ls_toolbar  TYPE stb_button.
*    CLEAR ls_toolbar.
*
*    IF gv_tabname EQ gc_output.
*      MOVE   3          TO ls_toolbar-butn_type.
*      APPEND ls_toolbar TO e_object->mt_toolbar.
*
*      CLEAR ls_toolbar.
*      MOVE 'INS'            TO ls_toolbar-function.
*      MOVE icon_insert_row  TO ls_toolbar-icon.
*      MOVE TEXT-034         TO ls_toolbar-quickinfo.
*      MOVE TEXT-034         TO ls_toolbar-text.
*      MOVE ' '              TO ls_toolbar-disabled.
*      APPEND ls_toolbar     TO e_object->mt_toolbar.
*
*      CLEAR ls_toolbar.
*      MOVE 'DEL'            TO ls_toolbar-function.
*      MOVE icon_delete_row  TO ls_toolbar-icon.
*      MOVE  TEXT-035        TO ls_toolbar-quickinfo.
*      MOVE  TEXT-035        TO ls_toolbar-text.
*      MOVE ' '              TO ls_toolbar-disabled.
*      APPEND ls_toolbar     TO e_object->mt_toolbar.
*    ENDIF.
  ENDMETHOD. "handle_toolbar

  METHOD handle_user_command.
*    WAIT UP TO 1 SECONDS.
*    CASE e_ucomm.
*      WHEN 'INS'.
*        "Satır Ekle
*        me->add_order_get_data( ).
*      WHEN 'DEL'.
*        "Satır Sil
*        CLEAR:  lt_selected_rows,
*                ls_selected_rows,
*                lv_lines.
*
*        CALL METHOD lo_alvgrid->get_selected_rows
*          IMPORTING
*            et_index_rows = lt_selected_rows.
*
*        lv_lines = lines( lt_selected_rows ).
*        IF lv_lines EQ 0.
*          MESSAGE e010(zsd_order).
*        ENDIF.
*
*        LOOP AT lt_selected_rows INTO ls_selected_rows.
*          DELETE gt_output INDEX ls_selected_rows-index.
*        ENDLOOP.
*        me->refresh_alv_2( ).
*    ENDCASE.
  ENDMETHOD. "handle_user_command
  METHOD screen_output.
*    LOOP AT SCREEN.
*      IF p_rb1 EQ abap_true.
*        CASE screen-group1.
*          WHEN 'M' OR 'M1'.
*            screen-active = 1.
*          WHEN 'M2' OR 'M3' OR 'M4'.
*            screen-active = 0.
*        ENDCASE.
*      ELSEIF p_rb2 EQ abap_true.
*        CASE screen-group1.
*          WHEN 'M2'.
*            screen-active = 1.
*          WHEN 'M' OR 'M1' OR 'M3' OR 'M4'.
*            screen-active = 0.
*        ENDCASE.
*      ELSEIF p_rb3 EQ abap_true.
*        CASE screen-group1.
*          WHEN 'M' OR 'M3' OR 'M4'.
*            screen-active = 1.
*          WHEN 'M1' OR 'M2'.
*            screen-active = 0.
*        ENDCASE.
*      ELSEIF p_rb4 EQ abap_true.
*        CASE screen-group1.
*          WHEN 'M4'.
*            screen-active = 1.
*          WHEN 'M' OR 'M1'  OR 'M2' OR 'M3'.
*            screen-active = 0.
*        ENDCASE.
*      ENDIF.
*      MODIFY SCREEN.
*    ENDLOOP.
  ENDMETHOD. "screen_output

  METHOD clear_all.
    CLEAR:    gv_tabname,
              gs_output,
              gv_error,
              gs_return.
    REFRESH:  gt_output,
              gt_return.
  ENDMETHOD."clear_all

  METHOD start_of_selection.
    me->clear_all( ).
    me->get_data( ).
    me->toplam( ).
  ENDMETHOD. "start_of_selection

  METHOD get_data.
    SELECT vbeln,
           erdat,
           ernam,
           audat,
           auart,
           vkorg,
           vtweg
      FROM vbak
      INTO TABLE @gt_output
      WHERE vbeln IN @s_vbeln.
  ENDMETHOD. "get_data

  METHOD add_message.
    DATA: ls_return TYPE bapiret2.
    CLEAR:  ls_return.
    CALL FUNCTION 'FS_BAPI_BAPIRET2_FILL'
      EXPORTING
        type   = iv_msg_type
        cl     = iv_msg_id
        number = iv_msg_numb
        par1   = iv_par1
        par2   = iv_par2
        par3   = iv_par3
        par4   = iv_par4
      IMPORTING
        return = ls_return.
    APPEND ls_return TO ct_return.
  ENDMETHOD. "add_message

  METHOD prepare_alv.
    IF lo_alvgrid IS INITIAL.
      me->get_tabname( iv_tabname = gc_output ).
      me->create_container( EXPORTING iv_cont_name = lv_cc
                            CHANGING  cs_container = lo_container
                                      cs_alv_grid  = lo_alvgrid ).
*      me->create_container2( CHANGING  cs_alv_grid  = lo_alvgrid ).
      me->create_layout(  EXPORTING iv_title   = TEXT-000
                          IMPORTING es_layout  = ls_layout ).
      me->create_variant( EXPORTING iv_handle  = 'A'
                          IMPORTING es_variant = ls_variant ).
      me->create_fcat(    IMPORTING et_fc      = lt_fc ).
      me->exclude(        EXPORTING iv_statu   = abap_false
                          IMPORTING et_exclude = lt_exclude ).
      me->event_receiver( CHANGING  cs_alvgird = lo_alvgrid ).
      me->sort_filter( EXPORTING iv_field      = 'VBELN'
                                 it_fc         = lt_fc
                       CHANGING ct_sort_filter = lt_sort ).
      me->display_alv(    CHANGING  cs_alvgird = lo_alvgrid
                                    cs_layout  = ls_layout
                                    cs_variant = ls_variant
                                    ct_output  = gt_output
                                    ct_fielcat = lt_fc
                                    ct_sort    = lt_sort ).
    ELSE .
      me->refresh_alv( CHANGING  cs_alvgird = lo_alvgrid ).
    ENDIF.
  ENDMETHOD. "prepare_alv

  METHOD create_container.
*    CREATE OBJECT co_alv_grid
*      EXPORTING
*        i_parent = cl_gui_custom_container=>screen0.

    CREATE OBJECT cs_container
      EXPORTING
        container_name = iv_cont_name.

    CREATE OBJECT cs_alv_grid
      EXPORTING
        i_parent = cs_container.

  ENDMETHOD. "create_container

  METHOD create_container2.
    CREATE OBJECT cs_alv_grid
      EXPORTING
        i_parent = cl_gui_custom_container=>screen0.
  ENDMETHOD. "create_container2

  METHOD create_layout.
    es_layout-zebra       = abap_true.
    es_layout-smalltitle  = abap_true.
    es_layout-cwidth_opt  = abap_true.
    es_layout-sel_mode    = 'D'.
    es_layout-grid_title  = iv_title.
    es_layout-info_fname  = 'COLOR'."Style

  ENDMETHOD. "create_layout

  METHOD create_variant.
    es_variant-handle = iv_handle.
    es_variant-report = sy-repid.
  ENDMETHOD. "create_variant

  METHOD create_fcat.
    DATA: lv_text TYPE string,
          ls_fcat TYPE lvc_s_fcat.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = gv_tabname
      CHANGING
        ct_fieldcat            = et_fc
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc EQ 0.
      "field catalog ekranda göstermeme işlemi
*      me->modify_fcat_no_out( EXPORTING iv_field = 'LIGHT'  CHANGING  ct_fc    = et_fc ).

      "field catalog hotspot
      me->modify_fcat_hotspot( EXPORTING iv_field = 'VBELN' CHANGING  ct_fc    = et_fc ).

      "field catalog tanım değiştirme işlemi
*      lv_text = TEXT-003.
*      me->modify_fcat( EXPORTING iv_field ='EDATU'
*                                 iv_text  = lv_text
*                       CHANGING  ct_fc    = et_fc ).
      "field catalog edite açma işlemi
*      me->modify_fcat_edit( EXPORTING iv_field = 'DURUM' CHANGING  ct_fc    = et_fc ).
      "field catalog checkbox olarak gösterme işlemi
*      me->modify_fcat_chkbox( EXPORTING iv_field = 'DURUM' CHANGING  ct_fc    = et_fc ).
      "field catalog hücre renklendirme
*      me->modify_fcat_color( EXPORTING  iv_field = 'ZTERM'
*                                        iv_color = 'C500'
*                             CHANGING   ct_fc    =  et_fc ).

    ENDIF.
  ENDMETHOD. "create_fcat
  METHOD modify_fcat.
    READ TABLE ct_fc ASSIGNING FIELD-SYMBOL(<lfs_fc>) WITH KEY fieldname = iv_field.
    IF sy-subrc EQ 0.
      <lfs_fc>-scrtext_s = iv_text.
      <lfs_fc>-scrtext_m = iv_text.
      <lfs_fc>-scrtext_l = iv_text.
      <lfs_fc>-reptext   = iv_text.
      <lfs_fc>-coltext   = iv_text.
      <lfs_fc>-col_opt   = abap_true.
    ENDIF.
  ENDMETHOD. "modify_fcat

  METHOD modify_fcat_edit.
    READ TABLE ct_fc ASSIGNING FIELD-SYMBOL(<lfs_fc>) WITH KEY fieldname = iv_field.
    IF sy-subrc EQ 0.
      <lfs_fc>-edit = abap_true.
    ENDIF.
  ENDMETHOD. "modify_fcat_edit

  METHOD modify_fcat_no_out.
    READ TABLE ct_fc ASSIGNING FIELD-SYMBOL(<lfs_fc>) WITH KEY fieldname = iv_field.
    IF sy-subrc EQ 0.
      <lfs_fc>-no_out = abap_true.
    ENDIF.
  ENDMETHOD. "modify_fcat_no_out

  METHOD modify_fcat_hotspot.
    READ TABLE ct_fc ASSIGNING FIELD-SYMBOL(<lfs_fc>) WITH KEY fieldname = iv_field.
    IF sy-subrc EQ 0.
      <lfs_fc>-hotspot = abap_true.
    ENDIF.
  ENDMETHOD. "modify_fcat_no_out

  METHOD modify_fcat_chkbox.
    READ TABLE ct_fc ASSIGNING FIELD-SYMBOL(<lfs_fc>) WITH KEY fieldname = iv_field.
    IF sy-subrc EQ 0.
      <lfs_fc>-checkbox = abap_true.
    ENDIF.
  ENDMETHOD. "modify_fcat_chkbox

  METHOD modify_fcat_color.
    READ TABLE ct_fc ASSIGNING FIELD-SYMBOL(<lfs_fc>) WITH KEY fieldname = iv_field.
    IF sy-subrc EQ 0.
      <lfs_fc>-emphasize = iv_color.
    ENDIF.
  ENDMETHOD. "modify_fcat_color

  METHOD exclude.
    REFRESH: et_exclude.

    IF iv_statu IS INITIAL.
      APPEND: cl_gui_alv_grid=>mc_fc_loc_insert_row         TO et_exclude,
              cl_gui_alv_grid=>mc_fc_loc_delete_row         TO et_exclude,
              cl_gui_alv_grid=>mc_fc_loc_move_row           TO et_exclude,
              cl_gui_alv_grid=>mc_fc_loc_move_row           TO et_exclude,
              cl_gui_alv_grid=>mc_fc_loc_cut                TO et_exclude,
              cl_gui_alv_grid=>mc_fc_loc_copy_row           TO et_exclude,
              cl_gui_alv_grid=>mc_fc_loc_copy               TO et_exclude,
              cl_gui_alv_grid=>mc_fc_loc_paste              TO et_exclude,
              cl_gui_alv_grid=>mc_fc_loc_paste_new_row      TO et_exclude,
              cl_gui_alv_grid=>mc_fc_loc_undo               TO et_exclude.
    ENDIF.
    APPEND: cl_gui_alv_grid=>mc_fc_loc_append_row           TO et_exclude,
            cl_gui_alv_grid=>mc_fc_views                    TO et_exclude,
            cl_gui_alv_grid=>mc_fc_view_crystal             TO et_exclude,
            cl_gui_alv_grid=>mc_fc_view_excel               TO et_exclude,
            cl_gui_alv_grid=>mc_fc_view_grid                TO et_exclude,
            cl_gui_alv_grid=>mc_fc_view_lotus               TO et_exclude,
            cl_gui_alv_grid=>mc_fc_col_invisible            TO et_exclude,
            cl_gui_alv_grid=>mc_fc_print                    TO et_exclude,
            cl_gui_alv_grid=>mc_fc_graph                    TO et_exclude,
            cl_gui_alv_grid=>mc_fc_info                     TO et_exclude.
  ENDMETHOD. "exclude

  METHOD sort_filter.
    REFRESH: ct_sort_filter.
    READ TABLE it_fc INTO DATA(ls_fc) WITH KEY fieldname = iv_field.
    IF sy-subrc EQ 0.
      ct_sort_filter = VALUE #( ( fieldname = ls_fc-fieldname spos = ls_fc-col_pos up = 'X') ).
    ENDIF.
  ENDMETHOD.  "sort_filter

  METHOD event_receiver.
    SET HANDLER me->handle_data_changed  FOR cs_alvgird.
    SET HANDLER me->handle_hotspot_click FOR cs_alvgird.
    SET HANDLER me->handle_toolbar       FOR cs_alvgird.
    SET HANDLER me->handle_user_command  FOR cs_alvgird.
  ENDMETHOD. "event_receiver

  METHOD display_alv.
    CALL METHOD cs_alvgird->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.

    CALL METHOD cs_alvgird->set_table_for_first_display
      EXPORTING
        is_layout            = cs_layout
        is_variant           = cs_variant
        i_save               = 'A'
        it_toolbar_excluding = lt_exclude
      CHANGING
        it_outtab            = ct_output
        it_fieldcatalog      = ct_fielcat
        it_sort              = lt_sort.

  ENDMETHOD. "display_alv

  METHOD refresh_alv.
    CLEAR: ls_stable.
    ls_stable-row = 'X'.
    ls_stable-col = 'X'.

    CALL METHOD cs_alvgird->refresh_table_display
      EXPORTING
        i_soft_refresh = ''
        is_stable      = ls_stable.
  ENDMETHOD. "refresh_alv

  METHOD refresh_alv_2.
    CLEAR: ls_stable.
    ls_stable-row = 'X'.
    ls_stable-col = 'X'.

    CALL METHOD lo_alvgrid->refresh_table_display
      EXPORTING
        i_soft_refresh = ''
        is_stable      = ls_stable.
  ENDMETHOD. "refresh_alv_2
  METHOD get_selected_rows.
    CLEAR:  lt_selected_rows,
            ls_selected_rows,
            lv_lines.

    CALL METHOD lo_alvgrid->get_selected_rows
      IMPORTING
        et_index_rows = lt_selected_rows.

  ENDMETHOD.
  METHOD print_adobe.

    me->get_selected_rows( ).

    lv_lines = lines( lt_selected_rows ).
    IF lv_lines EQ 0.
      MESSAGE s002(zzy_0001) DISPLAY LIKE 'E'.
    ENDIF.

    LOOP AT lt_selected_rows INTO ls_selected_rows.
      READ TABLE gt_output ASSIGNING FIELD-SYMBOL(<lfs_output>) INDEX ls_selected_rows-index.
      IF sy-subrc EQ 0.
        DATA(lv_vbeln) = <lfs_output>-vbeln.
      ENDIF.
    ENDLOOP.

    SELECT SINGLE vbeln,
                  erdat,
                  ernam,
                  audat,
                  auart,
                  vkorg,
                  vtweg
      FROM vbak
      INTO @gs_header
      WHERE vbak~vbeln EQ @lv_vbeln.
    IF sy-subrc EQ 0.
      SELECT vbeln,
             posnr,
             matnr,
             charg,
             netwr,
             waerk,
             werks
        FROM vbap
        INTO TABLE @gt_items
        WHERE vbap~vbeln EQ @gs_header-vbeln.
    ENDIF.

    "Toplam işlemini selected rows yüzünden burda yaptır.
    "Seçilen satırların vbeln'ine göre select atıcaz.

    SELECT SUM( netwr )"bu D.E. içeren sütunu topla.
      FROM vbap
      INTO @gv_toplam
      WHERE vbap~vbeln EQ @lv_vbeln. "neye göre toplam yapsın

    fp_outputparams-device      = 'PRINTER'.
    fp_outputparams-nodialog    = 'X'.
    fp_outputparams-preview     = 'X'.
*    fp_outputparams-nopreview     = 'X'.
    fp_outputparams-dest        = 'LP01'.

    "lOGO Ekleme :
    "AI de içe aktar yapmak için değişkeni programda tanımladık.
    "p_bmp de ne yazıyorsa onu aktaracak.
    DATA gv_logo TYPE xstring.
    CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
      EXPORTING
        p_object       = 'GRAPHICS'
        p_name         = 'ZSAP_E' "Logonun ismi se78
        p_id           = 'BMAP'
        p_btype        = 'BCOL'
      RECEIVING
        p_bmp          = gv_logo
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.


    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = fp_outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


    CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
      EXPORTING
        i_name     = 'ZVKT_EO_AF_001'
      IMPORTING
        e_funcname = fm_name.

    "adobe interface ye gönderilecek veriler.
    CALL FUNCTION fm_name
      EXPORTING
        /1bcdwb/docparams = fp_docparams
        is_header         = gs_header
        it_items          = gt_items
        iv_logo           = gv_logo
        iv_toplam         = gv_toplam
*   IMPORTING
*       /1BCDWB/FORMOUTPUT       =
      EXCEPTIONS
        usage_error       = 1
        system_error      = 2
        internal_error    = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


    CALL FUNCTION 'FP_JOB_CLOSE'
*   IMPORTING
*     E_RESULT             =
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDMETHOD.

  METHOD print_smartform.


    DATA: lv_fm_name TYPE rs38l_fnam.


    me->get_selected_rows( ).

    lv_lines = lines( lt_selected_rows ).
    IF lv_lines EQ 0.
      MESSAGE s002(zzy_0001) DISPLAY LIKE 'E'.
    ENDIF.

    LOOP AT lt_selected_rows INTO ls_selected_rows.
      READ TABLE gt_output ASSIGNING FIELD-SYMBOL(<lfs_output>) INDEX ls_selected_rows-index.
      IF sy-subrc EQ 0.
        DATA(lv_vbeln) = <lfs_output>-vbeln.
      ENDIF.
    ENDLOOP.

CLEAR: gs_header, gt_items.

    SELECT SINGLE vbeln,
                  erdat,
                  ernam,
                  audat,
                  auart,
                  vkorg,
                  vtweg
      FROM vbak
      INTO @gs_header
      WHERE vbak~vbeln EQ @lv_vbeln.
    IF sy-subrc EQ 0.
      SELECT vbeln,
             posnr,
             matnr,
             charg,
             netwr,
             waerk,
             werks
        FROM vbap
        INTO TABLE @gt_items
        WHERE vbap~vbeln EQ @gs_header-vbeln.
    ENDIF.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = 'ZVKT_EO_SF_001'
*       VARIANT            = ' '
*       DIRECT_CALL        = ' '
      IMPORTING
        fm_name            = lv_fm_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


    CALL FUNCTION lv_fm_name          "'/1BCDWB/SF00000125'
      EXPORTING
*       ARCHIVE_INDEX    =
*       ARCHIVE_INDEX_TAB          =
*       ARCHIVE_PARAMETERS         =
*       CONTROL_PARAMETERS         =
*       MAIL_APPL_OBJ    =
*       MAIL_RECIPIENT   =
*       MAIL_SENDER      =
*       OUTPUT_OPTIONS   =
*       USER_SETTINGS    = 'X'
        is_header        = gs_header
        it_items         = gt_items
        iv_vbeln         = s_vbeln
* IMPORTING
*       DOCUMENT_OUTPUT_INFO       =
*       JOB_OUTPUT_INFO  =
*       JOB_OUTPUT_OPTIONS         =
      EXCEPTIONS
        formatting_error = 1
        internal_error   = 2
        send_error       = 3
        user_canceled    = 4
        OTHERS           = 5.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDMETHOD.

  METHOD get_tabname.
    gv_tabname = iv_tabname.
  ENDMETHOD. "get_tabname
  METHOD toplam.
*    SELECT SUM( netwr )
*      FROM vbap
*      INTO @gv_toplam
*      WHERE vbap~vbeln EQ @gv_vbeln.
  ENDMETHOD.
ENDCLASS. "lcl_report IMPLEMENTATION
*&---------------------------------------------------------------------*
*& Form CALL_SMARTFORM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_smartform .





ENDFORM.
