FUNCTION ZEO_OLE_DOWNLOAD.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_SUBJECT) TYPE  CHAR50
*"     VALUE(IT_DATA) TYPE  ANY TABLE
*"     VALUE(IT_TITLE) TYPE  ZEM_STR01_T OPTIONAL
*"     VALUE(IT_COMPONENTS) TYPE  LTR_T_DD03L OPTIONAL
*"----------------------------------------------------------------------

  DATA: lo_struct        TYPE REF TO cl_abap_structdescr,
        lo_table         TYPE REF TO cl_abap_tabledescr,
        ldo_data         TYPE REF TO data,
        lt_comp          TYPE abap_compdescr_tab, "Fieldcat
        ls_comp_a        LIKE LINE OF lt_comp,    "Fieldcat
        ld_type          TYPE abap_typekind,
        lv_absolute_name TYPE abap_abstypename.

  DATA: lo_oref  TYPE REF TO cx_root.

  DATA: lt_components  TYPE ltr_t_dd03l,
        lt_tablo_tanim  TYPE gtt_tablo_tanim.


  PERFORM clear.
  PERFORM get_file_name USING iv_subject.
  CHECK gv_error EQ abap_false.

  GET REFERENCE OF it_data INTO ldo_data.
  ASSIGN ldo_data->* TO <gt_itab>.

  lo_table  ?= cl_abap_structdescr=>describe_by_data_ref( ldo_data ).
  lo_struct ?= lo_table->get_table_line_type( ).
  lt_comp = lo_struct->components.
  lv_absolute_name = lo_struct->absolute_name.
  SPLIT lv_absolute_name AT '=' INTO DATA(lv_dummy) DATA(lv_abs_name).

  IF lv_abs_name IS NOT INITIAL.
********-----başlıkların standart isimleri getirilir-----************
    SELECT *
      FROM dd03l
      INTO TABLE @lt_components
      WHERE tabname EQ @lv_abs_name.

    IF lt_components IS NOT INITIAL.
      SELECT  rollname,
              ddlanguage,
              reptext
        FROM dd04t
        INTO TABLE @lt_tablo_tanim
        FOR ALL ENTRIES IN @lt_components
        WHERE rollname EQ @lt_components-rollname
          AND as4local EQ 'A'.
    ENDIF.
  ENDIF.

  IF lt_components IS INITIAL.
    lt_components = it_components.

    IF lt_components IS NOT INITIAL.
      SELECT  rollname,
              ddlanguage,
              reptext
        FROM dd04t
        INTO TABLE @lt_tablo_tanim
        FOR ALL ENTRIES IN @lt_components
        WHERE rollname EQ @lt_components-rollname
          AND as4local EQ 'A'.                     "#EC CI_NO_TRANSFORM
    ENDIF.
  ENDIF.

  ">>>> seçenek 1 components ve itabın satır sayısına göre,
  "excelde ilk son hücre bulma
  DESCRIBE TABLE lt_components LINES gv_num_of_col.
  DESCRIBE TABLE IT_DATA LINES gv_num_of_row.
  "<<<< seçenek 1

  ">>>> seçenek 2 fonksiyonla kolon sayısını bulma
  gv_col_number = lines( lt_components[] ).
  IF gv_col_number EQ 0.
    gv_col_number = 100.
  ENDIF.

  "kolon sayısına göre kolon adını bulma
  CALL FUNCTION 'ZEO_GET_COLUMN_NAME'
    EXPORTING
      iv_column_number = gv_col_number
    IMPORTING
      ev_column_name   = gv_col_name.
  "<<<< seçenek 2

  TRY.
      PERFORM get_build_excel  USING lt_components
                                     lt_tablo_tanim
                                     it_title.
      "ole nesnesini excel uygulaması şeklinde oluşturur.
      CREATE OBJECT gv_excel 'EXCEL.APPLICATION'.

      "görünürlük 1 seçildiğinde excel açılır böylece hangi hücreye ne yazdığımızı daha kolay görürüz.
      SET PROPERTY OF gv_excel 'VISIBLE' = 1.
      CALL METHOD OF gv_excel 'WORKBOOKS' = gv_sheets.

      "sheetin oluşturulması
      CALL METHOD OF gv_sheets 'ADD' = gv_sheet.

      PERFORM create_sheet USING lt_components
                                 gt_sheet1
                                 iv_subject
                                 gv_sheet1
                                 1.
      PERFORM save_excel.
      MESSAGE s001(zem). "Excel dosyası kaydedildi!
    CATCH cx_root INTO lo_oref.
      MESSAGE s002(zem) DISPLAY LIKE 'E'. "Excel dosyası kaydedilmedi!
      gv_error = abap_true.
      LEAVE LIST-PROCESSING.
  ENDTRY.



ENDFUNCTION.
