*&---------------------------------------------------------------------*
*& Include          ZVKT_RAP_E_013_CLS
*&---------------------------------------------------------------------*

CLASS cl_event DEFINITION.
  PUBLIC SECTION.
    METHODS handle_data_changed                 " DATA_CHANGED
          FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING
          er_data_changed
          e_onf4
          e_onf4_before
          e_onf4_after
          e_ucomm.


    METHODS handle_toolbar_alv
          FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING
          e_object
          e_interactive.


    METHODS handle_user_command
          FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING
          e_ucomm
          sender .

    METHODS save.
ENDCLASS.

CLASS cl_event IMPLEMENTATION.
  METHOD handle_data_changed .
    DATA: ls_modi TYPE lvc_s_modi.

    LOOP AT er_data_changed->mt_good_cells INTO ls_modi.

      READ TABLE gt_table INTO DATA(ls_data) INDEX ls_modi-row_id.
      CLEAR gs_data.
      gs_data-adi = ls_data-adi.
      gs_data-aciklama = ls_modi-value.

    ENDLOOP.

  ENDMETHOD.
  METHOD handle_toolbar_alv.
    DATA: ls_toolbar TYPE stb_button.

    IF go_alv IS NOT INITIAL.

      CLEAR ls_toolbar.
      MOVE 5 TO ls_toolbar-butn_type.
      APPEND ls_toolbar TO e_object->mt_toolbar.
      CLEAR ls_toolbar.
      MOVE '&KAYDET' TO ls_toolbar-function.
      MOVE icon_save_as_template TO ls_toolbar-icon.
      MOVE 'Kaydet' TO ls_toolbar-text.
      APPEND ls_toolbar TO e_object->mt_toolbar.

    ENDIF.

  ENDMETHOD.

  METHOD handle_user_command.

    CASE e_ucomm.
      WHEN '&KAYDET'.
        me->save( ).
*      WHEN '&SIL'.
*        me->delete( ).
    ENDCASE.

    go_alv->refresh_table_display( ).

  ENDMETHOD.
  METHOD save.
    DATA: LS_STR TYPE zvkt_eo_t006.

    CALL METHOD go_alv->get_selected_rows(
      IMPORTING
        et_index_rows = DATA(lt_selected_rows)   " Indexes of Selected Rows
*       et_row_no     =     " Numeric IDs of Selected Rows
                        ).


    IF lt_selected_rows IS INITIAL.
      MESSAGE 'En az bir satır seçiniz.' TYPE 'I'.
    ELSE.
      LOOP AT lt_selected_rows INTO DATA(ls_selected_rows).
        READ TABLE gt_table ASSIGNING FIELD-SYMBOL(<fs_out>) INDEX ls_selected_rows-index.

*        PERFORM save.

        IF sy-subrc EQ 0 AND <fs_out>-color = 'C600'.
          MOVE-CORRESPONDING <fs_out> TO LS_STR.
          MODIFY zvkt_eo_t006 FROM LS_STR.
          MODIFY zvkt_eo_t003 FROM LS_STR.
          MESSAGE 'Açıklama Kaydedildi !' TYPE 'I' DISPLAY LIKE 'S'.
        ELSEIF  <fs_out>-color = 'C500'.
          MESSAGE 'Onaylanan Başvuruya Açıklama Eklenemez !' TYPE 'I' DISPLAY LIKE 'E'.
          CONTINUE.
        ELSE.
          MESSAGE 'Başvuru durumunu belirleyin !' TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
      ENDLOOP.
    ENDIF.


    CALL METHOD go_alv->refresh_table_display .

  ENDMETHOD.
ENDCLASS.
