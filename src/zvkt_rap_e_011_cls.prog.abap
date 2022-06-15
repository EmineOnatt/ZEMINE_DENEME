*&---------------------------------------------------------------------*
*& Include          ZVKT_RAP_E_011_CLS
*&---------------------------------------------------------------------*

CLASS lcl_odev DEFINITION.
  PUBLIC SECTION.

*    TYPES: BEGIN OF gty_table,
*             vbeln TYPE vbeln_va,
*             erdat TYPE erdat,
*             ernam TYPE ernam,
*             auart TYPE auart,
*             vkorg TYPE vkorg,
*             vtweg TYPE vtweg,
*             spart TYPE spart,
*             netwr TYPE netwr_ak,
*             waerk TYPE waerk,
*             znot  TYPE znot_eo_de,
*           END OF gty_table.
*
*    DATA: gt_table TYPE REF TO gty_table,
*          gs_table TYPE gty_table.

    DATA: gt_fcat   TYPE lvc_t_fcat,
          gs_fcat   TYPE lvc_s_fcat,
          gs_layout TYPE lvc_s_layo,
          gs_stable TYPE lvc_s_stbl.

    DATA: lt_selected_rows TYPE lvc_t_row,
          ls_selected_rows TYPE lvc_s_row,
          lv_lines         TYPE i.



    DATA: gt_popfcat TYPE TABLE OF slis_fieldcat_alv,
          gs_poplayo TYPE slis_layout_alv.

    DATA : go_alv  TYPE REF TO cl_gui_alv_grid.

    METHODS:
      get_data,
      set_fcat,
      set_layout,
      display_alv,
      clear_all,
      start_of_selection,
      refresh_alv,
      get_selected_rows,
      get_data_popup,
      set_popfcat,
      set_poplayo,
      display_popup,
      print_adobe,
      print_adobe2,
      excel_indir,
      kaydet,
      send_mail,
      print_smarform.

    METHODS:      handle_hotspot_click FOR EVENT hotspot_click
                        OF cl_gui_alv_grid IMPORTING e_column_id
                                                     e_row_id
                                                     es_row_no,

                  handle_data_changed FOR EVENT data_changed
                        OF cl_gui_alv_grid IMPORTING er_data_changed.




ENDCLASS.

CLASS lcl_odev IMPLEMENTATION.

  METHOD get_data.

    SELECT vb~vbeln,
           vb~erdat,
           vb~ernam,
           vb~auart,
           vb~vkorg,
           vb~vtweg,
           vb~spart,
           vb~netwr,
           vb~waerk,
           eo~znot
      FROM vbak AS vb
      LEFT OUTER JOIN zvkt_eo_t002 AS eo
      ON vb~vbeln EQ eo~vbeln
      INTO TABLE @gt_outtable
      WHERE vb~vbeln IN @s_vbeln.

    SORT gt_outtable ASCENDING BY vbeln.


  ENDMETHOD.

  METHOD get_data_popup.

    DATA(lv_vbeln2) = sy-ucomm.
    SELECT
      vp~vbeln,
      vp~posnr,
      lk~vbeln ,
      lp~posnr,
      lp~matnr,
      mk~maktx,
      lp~lfimg,
      lp~vrkme
      FROM vbap AS vp

      LEFT OUTER JOIN lips AS lp
      ON vp~vbeln EQ lp~vgbel
      AND vp~posnr  EQ lp~vgpos


      LEFT OUTER JOIN likp AS lk
      ON lp~vbeln EQ lk~vbeln

      LEFT OUTER JOIN makt AS mk
      ON mk~matnr EQ lp~matnr
      AND mk~spras EQ @sy-langu

      INTO TABLE @gt_outpoptable
      WHERE vp~vbeln EQ @gv_vbeln.

    SORT gt_outpoptable ASCENDING BY vbeln.




  ENDMETHOD.


  METHOD set_fcat.
*
*    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
*      EXPORTING
*        i_structure_name = 'ZVKT_EO_S002'
*      CHANGING
*        ct_fieldcat      = gt_fcat.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
*       I_BUFFER_ACTIVE        =
        i_structure_name       = 'ZVKT_EO_S002'
*       I_CLIENT_NEVER_DISPLAY = 'X'
*       I_BYPASSING_BUFFER     =
*       I_INTERNAL_TABNAME     =
      CHANGING
        ct_fieldcat            = gt_fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.


    LOOP AT gt_fcat ASSIGNING FIELD-SYMBOL(<lfs_fcat>).

      CASE <lfs_fcat>-fieldname .
        WHEN 'VBELN'.
          <lfs_fcat>-hotspot = abap_true.
        WHEN 'ZNOT'.
          <lfs_fcat>-edit = abap_true.
      ENDCASE.

    ENDLOOP.
  ENDMETHOD.

  METHOD set_layout.

    gs_layout-zebra = abap_true .
    gs_layout-cwidth_opt = abap_true .
    gs_layout-col_opt = abap_true .
*    gs_layout-sel_mode = 'A'.

  ENDMETHOD.

  METHOD display_alv.
    DATA: go_container TYPE REF TO cl_gui_custom_container.
    IF go_alv IS INITIAL.


*      go_alv = NEW cl_gui_alv_grid(
*      i_parent          = cl_gui_container=>screen0 ).


      CREATE OBJECT go_container
        EXPORTING
          container_name = 'CC_CONT'.

      CREATE OBJECT go_alv
        EXPORTING
          i_parent = go_container.

      SET HANDLER me->handle_hotspot_click FOR go_alv.
      SET HANDLER me->handle_data_changed FOR go_alv.

      CALL METHOD go_alv->set_table_for_first_display
        EXPORTING
          is_layout       = gs_layout
        CHANGING
          it_outtab       = gt_outtable
          it_fieldcatalog = gt_fcat.

      CALL METHOD go_alv->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_modified    " Event ID
*        EXCEPTIONS
*         error      = 1
*         others     = 2
        .
      IF sy-subrc <> 0.
*       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.


    ELSE.
      go_alv->refresh_table_display( ).
    ENDIF.

  ENDMETHOD.


  METHOD clear_all.

    CLEAR: gs_outtable.
    REFRESH: gt_outtable.

  ENDMETHOD.

  METHOD start_of_selection.

    me->clear_all( ).
    me->get_data( ).

  ENDMETHOD.

  METHOD refresh_alv.
    CLEAR: gs_stable.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.

    CALL METHOD go_alv->refresh_table_display
      EXPORTING
        i_soft_refresh = ''
        is_stable      = gs_stable.

  ENDMETHOD.

  METHOD handle_hotspot_click.

    READ TABLE gt_outtable ASSIGNING FIELD-SYMBOL(<lfs_vbak>) INDEX e_row_id."index e göre alırken row yazman gerek.
    IF e_column_id-fieldname = 'VBELN'.
      gv_vbeln = <lfs_vbak>-vbeln.
      me->get_data_popup( ).
      me->set_poplayo( ).
      me->set_popfcat( ).
      me->display_popup( ).
    ENDIF.


  ENDMETHOD.

  METHOD set_popfcat.

    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_program_name   = sy-repid
*       i_internal_tabname = 'GT_TABLE'
        i_inclname       = sy-repid
        i_structure_name = 'ZVKT_EO_S003'
      CHANGING
        ct_fieldcat      = gt_popfcat.


    LOOP AT gt_fcat ASSIGNING FIELD-SYMBOL(<gfs_fcat>).
      CASE <gfs_fcat>-fieldname.
        WHEN 'NOT'.
          <gfs_fcat>-outputlen = 500.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_poplayo.

    gs_poplayo-zebra = abap_true .
    gs_poplayo-colwidth_optimize = abap_true .

  ENDMETHOD.

  METHOD display_popup.

    go_alv->register_edit_event(
        EXPORTING
          i_event_id =    cl_gui_alv_grid=>mc_evt_modified " Event ID
      ).

*    SET HANDLER me->handle_hotspot_click FOR go_alv.

*    CALL METHOD go_alv->set
*      EXPORTING
*        start_column = 10
*        end_column   = 130
*        start_line   = 5
*        end_line     = 15 ).

    CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
      EXPORTING
        i_title          = 'POP-UP ALV'
        i_zebra          = 'X'
        i_tabname        = 1 "burada tablo için rakam verildi fakat tablo adı da yazılabilir.
        i_structure_name = 'ZVKT_EO_S003'
      TABLES
        t_outtab         = gt_outpoptable.





  ENDMETHOD.

  METHOD get_selected_rows.
    CLEAR:  lt_selected_rows,
            ls_selected_rows,
            lv_lines.

    CALL METHOD go_alv->get_selected_rows
      IMPORTING
        et_index_rows = lt_selected_rows.

  ENDMETHOD.

  METHOD print_adobe.

    me->get_selected_rows( ).

    lv_lines = lines( lt_selected_rows ).

    IF lv_lines EQ 0.
      MESSAGE 'Satır Seçiniz !' TYPE 'I'.
    ELSEIF lv_lines GT 1.
      MESSAGE 'Yalnız Bir Satır Seçiniz !' TYPE 'I'.
    ELSE.

      LOOP AT lt_selected_rows INTO ls_selected_rows.
        READ TABLE gt_outtable ASSIGNING FIELD-SYMBOL(<lfs_outtable>) INDEX ls_selected_rows-index.
        IF sy-subrc EQ 0.
          DATA(lv_vbeln) = <lfs_outtable>-vbeln. "Seçili satırın VBELN'i.
        ENDIF.
      ENDLOOP.

      SELECT SINGLE  vb~vbeln,
                     vb~erdat,
                     vb~ernam,
                     vb~auart,
                     vb~vkorg,
                     vb~vtweg,
                     vb~spart,
                     vb~netwr,
                     vb~waerk,
                     eo~znot
            FROM vbak AS vb
            LEFT OUTER JOIN zvkt_eo_t002 AS eo
            ON vb~vbeln EQ eo~vbeln
            INTO @gs_header
            WHERE vb~vbeln EQ @lv_vbeln.

      IF sy-subrc EQ 0.

        SELECT vb~vbeln,
                 vb~erdat,
                 vb~ernam,
                 vb~auart,
                 vb~vkorg,
                 vb~vtweg,
                 vb~spart,
                 vb~netwr,
                 vb~waerk,
                 eo~znot
        FROM vbak AS vb
        LEFT OUTER JOIN zvkt_eo_t002 AS eo
        ON vb~vbeln EQ eo~vbeln
        INTO TABLE @gt_items
        WHERE vb~vbeln EQ @gs_header-vbeln.
      ENDIF.

*
      fp_outputparams-device      = 'PRINTER'.
      fp_outputparams-nodialog    = 'X'.
      fp_outputparams-preview     = 'X'.
*    fp_outputparams-nopreview     = 'X'.
      fp_outputparams-dest        = 'LP01'.

      DATA gv_logo TYPE xstring.
      CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
        EXPORTING
          p_object       = 'GRAPHICS'
          p_name         = 'ZEO_SAPLOGO' "Logonun ismi se78
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
          i_name     = 'ZVKT_EO_AF_002'
        IMPORTING
          e_funcname = fm_name.

      "adobe interface ye gönderilecek veriler.
      CALL FUNCTION fm_name
        EXPORTING
          /1bcdwb/docparams = fp_docparams
          is_header         = gs_header
          it_items          = gt_items
          iv_logo           = gv_logo
*   IMPORTING
*         /1BCDWB/FORMOUTPUT       =
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
    ENDIF.


  ENDMETHOD.

  METHOD print_adobe2.

    me->get_selected_rows( ).

    lv_lines = lines( lt_selected_rows ).

    IF lv_lines EQ 0.
      MESSAGE 'Satır Seçiniz !' TYPE 'I'.
    ELSEIF lv_lines GT 1.
      MESSAGE 'Yalnız Bir Satır Seçiniz !' TYPE 'I'.
    ELSE.

      LOOP AT lt_selected_rows INTO ls_selected_rows.
        READ TABLE gt_outtable ASSIGNING FIELD-SYMBOL(<lfs_outtable>) INDEX ls_selected_rows-index.
        IF sy-subrc EQ 0.
          DATA(lv_vbeln) = <lfs_outtable>-vbeln. "Seçili satırın VBELN'i.
        ENDIF.
      ENDLOOP.

      SELECT SINGLE  vb~vbeln,
                     vb~erdat,
                     vb~ernam,
                     vb~auart,
                     vb~vkorg,
                     vb~vtweg,
                     vb~spart,
                     vb~netwr,
                     vb~waerk,
                     eo~znot
            FROM vbak AS vb
            LEFT OUTER JOIN zvkt_eo_t002 AS eo
            ON vb~vbeln EQ eo~vbeln
            INTO @gs_header
            WHERE vb~vbeln EQ @lv_vbeln.

      IF sy-subrc EQ 0.

        SELECT vb~vbeln,
                 vb~erdat,
                 vb~ernam,
                 vb~auart,
                 vb~vkorg,
                 vb~vtweg,
                 vb~spart,
                 vb~netwr,
                 vb~waerk,
                 eo~znot
        FROM vbak AS vb
        LEFT OUTER JOIN zvkt_eo_t002 AS eo
        ON vb~vbeln EQ eo~vbeln
        INTO TABLE @gt_items
        WHERE vb~vbeln EQ @gs_header-vbeln.
      ENDIF.


      fp_outputparams-nodialog    = 'X'.
      fp_outputparams-getpdf = 'X'.

      DATA gv_logo TYPE xstring.
      CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
        EXPORTING
          p_object       = 'GRAPHICS'
          p_name         = 'ZEO_SAPLOGO' "Logonun ismi se78
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
          i_name     = 'ZVKT_EO_AF_002'
        IMPORTING
          e_funcname = fm_name.

      "adobe interface ye gönderilecek veriler.
      CALL FUNCTION fm_name
        EXPORTING
          /1bcdwb/docparams  = fp_docparams
          is_header          = gs_header
          it_items           = gt_items
          iv_logo            = gv_logo
        IMPORTING
          /1bcdwb/formoutput = gs_pdf
        EXCEPTIONS
          usage_error        = 1
          system_error       = 2
          internal_error     = 3.
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
    ENDIF.


  ENDMETHOD.


  METHOD excel_indir.

    me->get_selected_rows( ).

    lv_lines = lines( lt_selected_rows ).

    LOOP AT lt_selected_rows INTO ls_selected_rows.
      READ TABLE gt_outtable ASSIGNING FIELD-SYMBOL(<lfs_output>) INDEX ls_selected_rows-index.
      IF sy-subrc EQ 0.
        APPEND <lfs_output> TO gt_excelout.
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'ZEO_EXCEL_DOWNLOAD_2'
      EXPORTING
        iv_subject = 'Sayfa'
        it_data    = gt_excelout.

  ENDMETHOD.

  METHOD print_smarform.
    DATA: lv_fm_name TYPE rs38l_fnam.


    me->get_selected_rows( ).

    lv_lines = lines( lt_selected_rows ).

    IF lv_lines EQ 0.
      MESSAGE 'Satır Seçiniz !' TYPE 'I'.
    ELSEIF lv_lines GT 1.
      MESSAGE 'Yalnız Bir Satır Seçiniz !' TYPE 'I'.
    ELSE.

      LOOP AT lt_selected_rows INTO ls_selected_rows.
        READ TABLE gt_outtable ASSIGNING FIELD-SYMBOL(<lfs_outtable>) INDEX ls_selected_rows-index.
        IF sy-subrc EQ 0.
          DATA(lv_vbeln) = <lfs_outtable>-vbeln. "Seçili satırın VBELN'i.
        ENDIF.
      ENDLOOP.

      SELECT SINGLE  vb~vbeln,
                     vb~erdat,
                     vb~ernam,
                     vb~auart,
                     vb~vkorg,
                     vb~vtweg,
                     vb~spart,
                     vb~netwr,
                     vb~waerk,
                     eo~znot
            FROM vbak AS vb
            LEFT OUTER JOIN zvkt_eo_t002 AS eo
            ON vb~vbeln EQ eo~vbeln
            INTO @gs_header
            WHERE vb~vbeln EQ @lv_vbeln.

      IF sy-subrc EQ 0.

        SELECT vb~vbeln,
                 vb~erdat,
                 vb~ernam,
                 vb~auart,
                 vb~vkorg,
                 vb~vtweg,
                 vb~spart,
                 vb~netwr,
                 vb~waerk,
                 eo~znot
        FROM vbak AS vb
        LEFT OUTER JOIN zvkt_eo_t002 AS eo
        ON vb~vbeln EQ eo~vbeln
        INTO TABLE @gt_items
        WHERE vb~vbeln EQ @gs_header-vbeln.
      ENDIF.


      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          formname           = 'ZVKT_EO_SF_002'
*         VARIANT            = ' '
*         DIRECT_CALL        = ' '
        IMPORTING
          fm_name            = lv_fm_name
        EXCEPTIONS
          no_form            = 1
          no_function_module = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.


      CALL FUNCTION lv_fm_name
        EXPORTING
          is_header        = gs_header
          it_items         = gt_items
          iv_vbeln         = s_vbeln
        EXCEPTIONS
          formatting_error = 1
          internal_error   = 2
          send_error       = 3
          user_canceled    = 4
          OTHERS           = 5.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD handle_data_changed.
    DATA: ls_modi TYPE lvc_s_modi.

    LOOP AT er_data_changed->mt_mod_cells INTO ls_modi.
      READ TABLE gt_outtable INTO DATA(ls_outtab) INDEX ls_modi-row_id.

      CLEAR gs_znot.
      gs_znot-vbeln = ls_outtab-vbeln.
      gs_znot-znot   = ls_modi-value.

    ENDLOOP.
  ENDMETHOD.

  METHOD kaydet.

    me->get_selected_rows( ).

    lv_lines = lines( lt_selected_rows ).

    IF lv_lines EQ 0.
      MESSAGE 'Satır Seçiniz !' TYPE 'I'.
    ELSE.

      LOOP AT lt_selected_rows INTO ls_selected_rows.
        READ TABLE gt_outtable ASSIGNING FIELD-SYMBOL(<lfs_outtable>) INDEX ls_selected_rows-index.
        IF sy-subrc EQ 0.
          DATA(lv_vbeln) = <lfs_outtable>-vbeln. "Seçili satırın VBELN'i.
        ENDIF.
      ENDLOOP.

      MODIFY zvkt_eo_t002 FROM gs_znot.

      IF sy-subrc EQ 0.
        MESSAGE 'Not Kaydedildi.' TYPE 'I'.
        COMMIT WORK AND WAIT.
      ELSE.
        MESSAGE 'Not Kaydedilemedi !' TYPE 'E'.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD send_mail.
    me->print_adobe2( ).
    me->get_selected_rows( ).

    lv_lines = lines( lt_selected_rows ).

    IF lv_lines EQ 0.
      MESSAGE 'Satır Seçiniz !' TYPE 'I'.
    ELSEIF lv_lines GT 1.
      MESSAGE 'Yalnız Bir Satır Seçiniz !' TYPE 'I'.
    ELSE.

      LOOP AT lt_selected_rows INTO ls_selected_rows.
        READ TABLE gt_outtable ASSIGNING FIELD-SYMBOL(<lfs_outtable>) INDEX ls_selected_rows-index.
        IF sy-subrc EQ 0.
          DATA(lv_vbeln) = <lfs_outtable>-vbeln. "Seçili satırın VBELN'i.
        ENDIF.
      ENDLOOP.

      DATA: lv_subject         TYPE so_obj_des,
            lt_body_text       TYPE w3htmltab,
            lv_subject_attach  TYPE char255,
            lt_attachments     TYPE rmps_t_post_content,
            lt_attachments_tmp TYPE rmps_t_post_content,
            lv_sender          TYPE ad_smtpadr,
            lv_recipient       TYPE ad_smtpadr,
            lt_recipients      TYPE uiyt_iusr,
            lv_result          TYPE boolean,
*            lv_pdf             TYPE fpformoutput,
            lv_text            TYPE char255.

      DATA: lt_where TYPE dmc_where_clause_tab.
      REFRESH: lt_where.

      CLEAR:  lv_subject,
              lv_subject_attach,
              lv_sender,
              lv_recipient,
              lv_result,
              lv_text.

      REFRESH:  lt_body_text,
                lt_attachments,
                lt_attachments_tmp,
                lt_recipients.

      lv_subject = lv_vbeln.
      lv_sender = 'INFO@VEKTORA.COM'.

      INSERT: VALUE #( line = 'Selamlar,' ) INTO TABLE lt_body_text.
      INSERT: VALUE #( line = '<br>' ) INTO TABLE lt_body_text.
      INSERT: VALUE #( line = '<br>' ) INTO TABLE lt_body_text.
      INSERT: VALUE #( line = lv_vbeln ) INTO TABLE lt_body_text.
      INSERT: VALUE #( line = ' Seçilen siparişe ait bilgiler ektedir.' ) INTO TABLE lt_body_text.
      INSERT: VALUE #( line = '<br>' ) INTO TABLE lt_body_text.
      INSERT: VALUE #( line = '<br>' ) INTO TABLE lt_body_text.
      INSERT: VALUE #( line = 'İyi çalışmalar.' ) INTO TABLE lt_body_text.

      SELECT
                mandt,
                email
      FROM zeo_ct_mail
      INTO CORRESPONDING FIELDS OF TABLE @lt_recipients.

      IF lt_recipients IS INITIAL.
        MESSAGE 'Gönderilecek mail bulunamadı !' TYPE 'I' DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.

      CALL FUNCTION 'ZEO_FM_MAIL_ATT_PDF'
        EXPORTING
          iv_subject     = 'Teslimat Belgesi'
          is_pdf         = gs_pdf
        IMPORTING
          et_attachments = lt_attachments_tmp.

      IF lt_attachments_tmp IS NOT INITIAL.
        INSERT LINES OF lt_attachments_tmp INTO TABLE lt_attachments.
        REFRESH: lt_attachments_tmp.
      ENDIF.



      "send Mail
      CALL FUNCTION 'ZEO_MAIL_SEND'
        EXPORTING
          subject      = lv_subject
          message_type = 'HTM'
          message_body = lt_body_text
          attachments  = lt_attachments
          sender_mail  = lv_sender
          recipients   = lt_recipients
        IMPORTING
          result       = lv_result.
      IF lv_result EQ abap_true.
        MESSAGE 'Mail Gönderimi Başarılı.' TYPE 'S'.
      ELSE.
        MESSAGE  'Mail Gönderimi Başarısız !' TYPE 'E'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
