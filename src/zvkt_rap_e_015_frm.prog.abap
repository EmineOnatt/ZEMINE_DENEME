*&---------------------------------------------------------------------*
*& Include          ZVKT_RAP_E_013_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form GAYIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM start_of_selection .

**  LOOP AT SCREEN.
  CASE 'X'.
    WHEN r_basvr.
      CALL SCREEN 0100.
**        MODIFY SCREEN.
    WHEN r_yonet.
      PERFORM login.
      PERFORM display_alv.
*      PERFORM display_alv2 .
      CALL SCREEN 0200.

**        MODIFY SCREEN.
    WHEN OTHERS.
  ENDCASE.
**  ENDLOOP.

ENDFORM.
FORM gayit .

  DATA: ls_table TYPE zvkt_eo_t003.
  DATA: lv_ans(1).

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZEO_NR_R'
*     QUANTITY    = '1'
*     SUBOBJECT   = ' '
*     TOYEAR      = '0000'
*     IGNORE_BUFFER                 = ' '
    IMPORTING
      number      = gs_data-id.

  SELECT COUNT(*)
   FROM zvkt_eo_t003
   WHERE adi EQ @gs_data-adi AND
         soyadi EQ @gs_data-soyadi.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'İşlem gerçekleştiriliyor...'
      text_question         = 'Emin misiniz?'
      text_button_1         = 'Tamam'
      icon_button_1         = 'ICON_CHECKED'
      text_button_2         = 'İptal'
      icon_button_2         = 'ICON_CANCEL'
      default_button        = '1'
      display_cancel_button = ' '
      popup_type            = 'ICON_MESSAGE_ERROR'
    IMPORTING
      answer                = lv_ans.
  IF lv_ans EQ '1'.
    IF sy-subrc EQ 0.
      MESSAGE 'Daha önce oluşturulmuş Başvuru 2.Ekrana yönlendiriliyorsunuz' TYPE 'I'.
      SELECT SINGLE *
        FROM zvkt_eo_t003
        INTO CORRESPONDING FIELDS OF @gs_data
        WHERE adi EQ @gs_data-adi AND
           soyadi EQ @gs_data-soyadi.
      gv_flag = abap_false.
    ENDIF.
  ELSEIF lv_ans EQ '2'.
    IF sy-subrc NE 0.
      gs_data-pb = 'TRY'.
      APPEND gs_data TO  gt_table.
*    INSERT zvkt_eo_t003 FROM TABLE LT_TABLE.
      LOOP AT gt_table INTO DATA(ls_tab).
        MOVE-CORRESPONDING ls_tab TO ls_table.
        MODIFY zvkt_eo_t003 FROM ls_table.
      ENDLOOP.

      MESSAGE 'Başvuru Tamamlanmıştır.' TYPE 'I'.

      gv_flag = abap_true.

    ENDIF.
  ENDIF.




ENDFORM.
FORM guncelle.
  DATA: ls_table TYPE zvkt_eo_t003.
  APPEND gs_data TO  gt_table.
*  MODIFY zvkt_eo_t003 FROM TABLE gt_table.
  LOOP AT gt_table INTO DATA(ls_tab).
    MOVE-CORRESPONDING ls_tab TO ls_table.
    MODIFY zvkt_eo_t003 FROM ls_table.
  ENDLOOP.

  MESSAGE 'Başvuru Güncenlenmiştir.' TYPE 'I'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form LOGIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM login .
  DATA lv_exist TYPE xfeld.

  SELECT SINGLE @abap_true
    FROM zvkt_eo_t004
    INTO @lv_exist
    WHERE id EQ @p_user
    AND passw EQ @p_passw.

  IF lv_exist EQ abap_true.
*    MESSAGE 'Giriş başarılı.' TYPE 'S'.
    MESSAGE s002(zeo_001) DISPLAY LIKE 'E'.
*    CALL SCREEN 0200.
*    PERFORM display_alv.
  ELSE.
    MESSAGE 'Giriş başarısız.' TYPE 'E'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  SELECT *
    FROM zvkt_eo_t003
    INTO CORRESPONDING FIELDS OF TABLE @gt_table.

  SORT gt_table ASCENDING BY id.
*  FIELD-SYMBOLS <gfs_table> TYpe gt_table.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fcat .

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZVKT_EO_S006'
    CHANGING
      ct_fieldcat            = gt_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  LOOP AT  gt_fcat ASSIGNING FIELD-SYMBOL(<lfs_fcat>).
    IF <lfs_fcat>-fieldname = 'ACIKLAMA'.
      <lfs_fcat>-edit = abap_true.
      <lfs_fcat>-scrtext_l = 'Aciklama'.
      <lfs_fcat>-scrtext_m = 'Acıklama'.
*      <lfs_fcat>-hotspot = abap_true.

    ENDIF.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout.

  gs_layout-zebra = abap_true.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-edit = abap_true.
  gs_layout-sel_mode = 'A'.
  gs_layout-info_fname = 'COLOR'. "renk ayarları için oluşturduk.stc içinde
*  gs_layout-no_toolbar = abap_true.
  gs_layout-stylefname = 'CELLSTYL'.




*  FIELD-SYMBOLS: <fs_out> TYPE lvc_s_layo.
*  APPEND INITIAL LINE TO <fs_out>-cellstyles ASSIGNING FIELD-SYMBOL(<fs_stylerow>).
*  <fs_stylerow>-fieldname = 'ACIKLAMA' .
*  <fs_stylerow>-style = cl_gui_alv_grid=>mc_style_disabled.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv .

  PERFORM get_data.
  PERFORM set_fcat.
  PERFORM set_layout.
  PERFORM set_color.


  DATA: ls_variant TYPE disvariant.
  ls_variant-report = sy-repid.
  ls_variant-username = sy-uname.
*  ls_variant-handle = '001'. " HER ALV İÇİN AYRI VARYANT


  IF go_alv IS INITIAL.

    CREATE OBJECT go_cust
      EXPORTING
        container_name = 'CC_CONT'.


    CREATE OBJECT go_split
      EXPORTING
        parent  = go_cust
        rows    = 2   "satır olarak ikiye böler
        columns = 1. "sütun olarak 2ye böler
*          align = 15.

    go_split->get_container(
         EXPORTING
           row       =  1
           column    =   1
         RECEIVING
           container =  graphic_parent1   ).

    go_split->get_container(
        EXPORTING
          row       =  2
          column    =   1
        RECEIVING
          container =  graphic_parent2   ).

    CREATE OBJECT go_alv
      EXPORTING
        i_parent = graphic_parent1.

    CREATE OBJECT go_alv2
      EXPORTING
        i_parent = graphic_parent2.

    PERFORM set_fcat .
    PERFORM set_layout.
    PERFORM set_display.


*PERFORM prepare_field_catalog1 CHANGING gt_fcat2 .
*PERFORM prepare_layout1 CHANGING gs_layout2.

    PERFORM display_alv2.
    PERFORM get_data2.
    PERFORM set_layout2.
    PERFORM set_fcat2.

*    CREATE OBJECT go_alv
*      EXPORTING
*        i_parent = cl_gui_container=>screen0.  " Parent Container

    CREATE OBJECT go_event.

    SET HANDLER go_event->handle_data_changed FOR go_alv.
    SET HANDLER : go_event->handle_toolbar_alv FOR go_alv ,
                        go_event->handle_user_command FOR go_alv .

    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZVKT_EO_S004'   " Internal Output Table Structure Name
        i_save           = 'A'   " Save Layout
        is_layout        = gs_layout    " Layout
        is_variant       = ls_variant
      CHANGING
        it_outtab        = gt_table   " Output Table
        it_fieldcatalog  = gt_fcat.   " Field Catalog


    CALL METHOD go_alv->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.   " Event ID


*  APPEND INITIAL LINE TO <gfs_table>-cellstyle ASSIGNING FIELD-SYMBOL(<fs_stylerow>).
*  <fs_stylerow>-fieldname = 'ACIKLAMA' .
*  <fs_stylerow>-style = cl_gui_alv_grid=>mc_style_disabled.
*  append gs_cellstyle to <gfs_table>-cellstyle.


    CALL METHOD go_alv2->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZVKT_EO_S004'   " Internal Output Table Structure Name
*       i_save           = 'A'   " Save Layout
        is_layout        = gs_layout2    " Layout
      CHANGING
        it_outtab        = gt_alvtable   " Output Table
        it_fieldcatalog  = gt_fcat2.   " Field Catalog


  ELSE.
    CALL METHOD go_alv->refresh_table_display .
    CALL METHOD go_alv2->refresh_table_display .
    CALL METHOD cl_gui_cfw=>flush .
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_COLOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_color .
*  DATA    : ls_data  TYPE zvkt_eo_s004.
  SELECT *
     FROM zvkt_eo_t005
     INTO TABLE @DATA(lt_data).

  SORT gt_fcat BY fieldname.

  LOOP AT gt_table INTO DATA(ls_data).
    READ TABLE lt_data INTO DATA(ls_veri) WITH KEY id = ls_data-id.
    CASE sy-subrc.
      WHEN 0.
        REFRESH: gt_cellstyle.
        ls_data-color = 'C500'.

        LOOP AT gt_fcat INTO DATA(ls_fcat).

          gs_cellstyle-fieldname = ls_fcat-fieldname."'ACIKLAMA'.
          CONDENSE gs_cellstyle-fieldname NO-GAPS.        "Boşlukları kaldırır.
          TRANSLATE gs_cellstyle-fieldname TO UPPER CASE. "Yazıları büyük harfe çevirir.
          gs_cellstyle-style = cl_gui_alv_grid=>mc_style_disabled.
          APPEND gs_cellstyle TO gt_cellstyle.
          CLEAR: gs_cellstyle.

        ENDLOOP.

        ls_data-cellstyl[] = gt_cellstyle[].

        MODIFY gt_table FROM ls_data.
      WHEN OTHERS.
*        ls_data-color = 'C600'.
*        MODIFY gt_table FROM ls_data.
    ENDCASE.
  ENDLOOP.


  SELECT *
    FROM zvkt_eo_t006
    INTO TABLE @DATA(lt_redtab).

  LOOP AT gt_table INTO DATA(ls_redtab).
    READ TABLE lt_redtab INTO DATA(ls_redveri) WITH KEY id = ls_redtab-id.
    CASE  sy-subrc.
      WHEN 0.
        ls_redtab-color = 'C600'.
        MODIFY gt_table FROM ls_redtab.
      WHEN OTHERS.
*         ls_redtab-color = 'C600'.
*          MODIFY gt_table from ls_redtab.
    ENDCASE.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ONAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM onay .

  DATA: lt_selected_rows TYPE lvc_t_row, "stnd.
        ls_selected_rows LIKE LINE OF lt_selected_rows, "tablodakileri tek tek al
        ls_kayit         TYPE zvkt_eo_t003,
        lv_lines         TYPE i..

  CLEAR:  lt_selected_rows,
        ls_selected_rows,
        gt_cellstyle[].


  CALL METHOD go_alv->get_selected_rows
    IMPORTING
      et_index_rows = lt_selected_rows.


  LOOP AT lt_selected_rows INTO ls_selected_rows.
    READ TABLE gt_table ASSIGNING FIELD-SYMBOL(<fs_data>) INDEX ls_selected_rows.
    IF sy-subrc EQ 0.
      CLEAR: ls_kayit, gt_cellstyle[].
      MOVE-CORRESPONDING <fs_data> TO ls_kayit.
      INSERT zvkt_eo_t005 FROM ls_kayit.
      <fs_data>-color = 'C500'.

      gs_cellstyle-fieldname = 'ACIKLAMA'.
      gs_cellstyle-style = cl_gui_alv_grid=>mc_style_disabled.
      APPEND gs_cellstyle TO gt_cellstyle.

      <fs_data>-cellstyl[] = gt_cellstyle[].
    ENDIF.
  ENDLOOP.

*  MODIFY zvkt_eo_t005 FROM gs_data.

  IF sy-subrc EQ 0 AND <fs_data>-color EQ 'C500'.
*    MODIFY zvkt_eo_t005 FROM ls_kayit.
*    MODIFY zvkt_eo_t003 FROM ls_kayit.
    MESSAGE 'Kayıt Değiştirildi...' TYPE 'I'.
  ELSE.
*    MODIFY zvkt_eo_t005 FROM ls_kayit.
    MESSAGE 'Kayıt Eklendi...' TYPE 'I'.
  ENDIF.

  IF lt_selected_rows IS INITIAL.
    MESSAGE 'En az bir satır seçiniz.' TYPE 'I'.
  ENDIF.

  CALL METHOD go_alv->refresh_table_display .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEND_MAIL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_mail .

  DATA: lt_selected_rows TYPE lvc_t_row, "stnd.
        ls_selected_rows LIKE LINE OF lt_selected_rows, "tablodakileri tek tek al
        ls_kayit         TYPE zvkt_eo_t003,
        lv_lines         TYPE i.

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


  CLEAR:  lt_selected_rows,
          ls_selected_rows,
          lv_lines.

  CALL METHOD go_alv->get_selected_rows
    IMPORTING
      et_index_rows = lt_selected_rows.

  lv_lines = lines( lt_selected_rows ).

  IF lv_lines EQ 0.
    MESSAGE 'Satır Seçiniz !' TYPE 'I'.
  ENDIF.

  LOOP AT lt_selected_rows INTO ls_selected_rows.

    READ TABLE gt_table ASSIGNING FIELD-SYMBOL(<lfs_table>) INDEX ls_selected_rows-index.

    IF sy-subrc EQ 0.
      CLEAR lt_body_text.
      IF <lfs_table>-color EQ 'C500' .
        INSERT: VALUE #( line = 'Selamlar,' ) INTO TABLE lt_body_text.
        INSERT: VALUE #( line = '<br>' ) INTO TABLE lt_body_text.
        INSERT: VALUE #( line = '<br>' ) INTO TABLE lt_body_text.
        INSERT: VALUE #( line = ' BAŞVURUNUZ OLUMLU SONUÇLANMIŞTIR.' ) INTO TABLE lt_body_text.
        INSERT: VALUE #( line = '<br>' ) INTO TABLE lt_body_text.
        INSERT: VALUE #( line = '<br>' ) INTO TABLE lt_body_text.
        INSERT: VALUE #( line = 'İyi çalışmalar.' ) INTO TABLE lt_body_text.

      ELSEIF <lfs_table>-color EQ 'C600'.
        INSERT: VALUE #( line = 'Selamlar,' ) INTO TABLE lt_body_text.
        INSERT: VALUE #( line = '<br>' ) INTO TABLE lt_body_text.
        INSERT: VALUE #( line = '<br>' ) INTO TABLE lt_body_text.
        INSERT: VALUE #( line = ' Başvurunuz OLUMSUZ sonuçlanmıştır.' ) INTO TABLE lt_body_text.
        INSERT: VALUE #( line = '<br>' ) INTO TABLE lt_body_text.
        INSERT: VALUE #( line = '<br>' ) INTO TABLE lt_body_text.
        INSERT: VALUE #( line = 'Hoşçakalın.' ) INTO TABLE lt_body_text.
      ENDIF.
      lv_subject = 'Başvuru Durumu'.
      lv_sender = 'INFO@VEKTORA.COM'.
      lv_recipient = <lfs_table>-mail.


      CALL FUNCTION 'ZEO_MAIL_SEND'
        EXPORTING
          subject        = lv_subject
          message_type   = 'HTM'
          message_body   = lt_body_text
*         attachments    = lt_attachments
          sender_mail    = lv_sender
          recipient_mail = lv_recipient
*         recipients     = lv_recipient
        IMPORTING
          result         = lv_result.
      IF lv_result EQ abap_true.
        MESSAGE 'Mail Gönderimi Başarılı.' TYPE 'S'.
      ELSE.
        MESSAGE  'Mail Gönderimi Başarısız !' TYPE 'E'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_screen .
  LOOP AT SCREEN.
    IF gv_flag = abap_false.
      IF  screen-group1 EQ 'G1'.
        screen-active = 0.
        screen-invisible = 1.
        MODIFY SCREEN.
      ELSEIF screen-group4 EQ 'Z4'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSE.
      IF screen-group2 EQ 'G2'.
        screen-active = 0.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REDDET
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM reddet .
  DATA: lt_selected_rows TYPE lvc_t_row, "stnd.
        ls_selected_rows LIKE LINE OF lt_selected_rows, "tablodakileri tek tek al
        ls_kayit         TYPE zvkt_eo_t006.

  CLEAR:  lt_selected_rows,
        ls_selected_rows.


  CALL METHOD go_alv->get_selected_rows
    IMPORTING
      et_index_rows = lt_selected_rows.

  LOOP AT lt_selected_rows INTO ls_selected_rows.
    READ TABLE gt_table INTO gs_data INDEX ls_selected_rows.
    IF sy-subrc EQ 0.
      IF gs_data-color EQ 'C500'.
        MESSAGE 'Onaylanan kayıt REDDEDİLEMEZ!'TYPE 'I' DISPLAY LIKE 'E'.
        EXIT.
      ELSEIF gs_data-color EQ 'C600'.
        MESSAGE 'Kayıt Zaten Red Listesinde !' TYPE 'E'.
      ELSE.
        CLEAR ls_kayit.
        MOVE-CORRESPONDING gs_data TO ls_kayit.
        INSERT zvkt_eo_t006 FROM ls_kayit.
        IF  sy-subrc EQ 0.
          MESSAGE 'Red Kaydı Başarılı.' TYPE 'S'.
        ELSE.
          MESSAGE 'Red Kaydı Başarısız.' TYPE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

*  IF gs_data-color EQ 'C600'.
*    MESSAGE 'Kayıt Zaten Onaylandı' TYPE 'I'.
*  ELSE.
*    MESSAGE 'Kayıt Reddedildi...' TYPE 'I'.
*  ENDIF.
*
*  IF lt_selected_rows IS INITIAL.
*    MESSAGE 'En az bir satır seçiniz.' TYPE 'I'.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save .
  DATA: lt_selected_rows TYPE lvc_t_row, "stnd.
        ls_selected_rows LIKE LINE OF lt_selected_rows, "tablodakileri tek tek al
        ls_kayit         TYPE zvkt_eo_t006.

  DATA: ls_table TYPE zvkt_eo_t006 .

  CLEAR:  lt_selected_rows,
        ls_selected_rows.


  CALL METHOD go_alv->get_selected_rows
    IMPORTING
      et_index_rows = lt_selected_rows.

  LOOP AT lt_selected_rows INTO ls_selected_rows.
    READ TABLE gt_table INTO gs_data INDEX ls_selected_rows.

    IF sy-subrc EQ 0 AND gs_data-color = 'C600'.
      MOVE-CORRESPONDING gs_data TO ls_table.
      MODIFY zvkt_eo_t006 FROM ls_table.
      MODIFY zvkt_eo_t003 FROM ls_table.
      MESSAGE 'Açıklama Kaydedildi !' TYPE 'I' DISPLAY LIKE 'S'.
    ELSEIF  gs_data-color = 'C500'.
      MESSAGE 'Onaylanan Başvuruya Açıklama Eklenemez !' TYPE 'I' DISPLAY LIKE 'E'.
      CONTINUE.

    ENDIF.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SECENEK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM secenek .

  LOOP AT SCREEN.
    IF screen-name EQ 'P_PASSW'.
      screen-invisible = 1.
    ENDIF.

    IF r_yonet EQ 'X'.
      IF screen-group1 = 'US'.
        screen-active = 1.
*        screen-required = 1.
*        screen-required = 1.
*        screen-invisible = 0.

      ENDIF.
*      IF screen-group1 = 'PW'.
*        screen-active = 1.
*        screen-invisible = 0.
*        screen-required = 1.
*        MODIFY SCREEN.
*      ENDIF.
    ELSEIF r_basvr EQ 'X'.
      IF screen-group1 = 'US'.
        screen-active = 0.
*        screen-invisible = 1.
*        MODIFY SCREEN.
      ENDIF.
*      IF screen-group1 = 'PW'.
*        screen-active = 0.
*        screen-invisible = 1.
*        MODIFY SCREEN.
*      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_display .



ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv2 .

*  PERFORM get_data2.
*  PERFORM set_layout2.
*  PERFORM set_fcat2.
*
*    CREATE OBJECT go_alv2
*      EXPORTING
*        i_parent = graphic_parent2.
*
*      CALL METHOD go_alv->set_table_for_first_display
*      EXPORTING
*        i_structure_name = 'ZVKT_EO_S004'   " Internal Output Table Structure Name
**        i_save           = 'A'   " Save Layout
*        is_layout        = gs_layout2    " Layout
*      CHANGING
*        it_outtab        = gt_alvtable   " Output Table
*        it_fieldcatalog  = gt_fcat2.   " Field Catalog


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data2 .

  SELECT *
     FROM zvkt_eo_t005
     INTO CORRESPONDING FIELDS OF TABLE @gt_alvtable.

  SORT gt_alvtable ASCENDING BY id.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout2 .
  gs_layout2-zebra = abap_true.
  gs_layout2-cwidth_opt = abap_true.
  gs_layout2-sel_mode = 'A'.
  gs_layout2-info_fname = 'COLOR'. "renk ayarları için oluşturduk.stc içinde
*   gs_layout-no_toolbar = abap_true.
  gs_layout2-stylefname = 'CELLSTYL'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FCAT2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fcat2 .

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZVKT_EO_S006'
    CHANGING
      ct_fieldcat            = gt_fcat2
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
