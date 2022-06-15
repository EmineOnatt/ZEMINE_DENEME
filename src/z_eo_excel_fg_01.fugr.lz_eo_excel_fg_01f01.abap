*----------------------------------------------------------------------*
***INCLUDE LZ_EO_EXCEL_FG_01F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CLEAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear .
  CLEAR: gv_filename,
         gv_cell1,
         gv_cell2,
         gv_excel,
         gv_sheets,
         gv_sheet,
         gv_cell,
         gv_worksheet,
         gv_color,
         gv_range,
         gv_borders,
         gv_sheet1,
         gv_font,
         gt_sheet1[],
         gv_data,
         gv_sheet_name,
         gv_col_number,
         gv_error,
         gv_col_name.
ENDFORM. "clear

FORM get_file_name USING uv_subject.
  CLEAR: gv_filename.
  DATA: lv_desktop  TYPE string.

  CALL METHOD cl_gui_frontend_services=>get_desktop_directory
    CHANGING
      desktop_directory = lv_desktop.

  CALL METHOD cl_gui_cfw=>flush.

  CONCATENATE lv_desktop '\' uv_subject '_' sy-datum '_' sy-uzeit '.xlsx' INTO gv_filename.

  IF gv_filename IS INITIAL.
    MESSAGE s064(zsd_0001)  DISPLAY LIKE 'E'. "Lütfen dosyanın kaydedileceği yeri seçiniz!
    gv_error = abap_true.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM. "get_file_name

FORM get_build_excel  USING ut_components  TYPE ltr_t_dd03l
                            ut_tablo_tanim TYPE gtt_tablo_tanim
                            ut_title       TYPE zem_str01_t.
  "excel başlığı
  PERFORM get_build_header USING ut_components
                                 ut_tablo_tanim
                                 ut_title.
  "excel kalemi
  PERFORM get_build_item USING ut_components.
ENDFORM. "get_build_excel

FORM get_build_header USING ut_components    TYPE ltr_t_dd03l
                            ut_tablo_tanim   TYPE gtt_tablo_tanim
                            ut_title         TYPE zem_str01_t.
  CLEAR:  gv_data,
          gt_sheet1.

* Başlık bilgisi
  LOOP AT ut_components INTO DATA(ls_comp).
    READ TABLE ut_title INTO DATA(ls_title) WITH KEY rollname = ls_comp-rollname.
    IF sy-subrc EQ 0.
      CONCATENATE gv_data ls_title-reptext gv_deli INTO gv_data.
    ELSE.
      READ TABLE ut_tablo_tanim INTO DATA(ls_tablo_tanim) WITH KEY rollname   = ls_comp-rollname
                                                                   ddlanguage = sy-langu.
      IF sy-subrc EQ 0.
        CONCATENATE gv_data ls_tablo_tanim-reptext gv_deli INTO gv_data.
      ELSE.
        READ TABLE ut_tablo_tanim INTO ls_tablo_tanim WITH KEY rollname   = ls_comp-rollname
                                                               ddlanguage = 'T'.
        IF sy-subrc EQ 0.
          CONCATENATE gv_data ls_tablo_tanim-reptext gv_deli INTO gv_data.
        ELSE.
          READ TABLE ut_tablo_tanim INTO ls_tablo_tanim WITH KEY rollname   = ls_comp-rollname.
          IF sy-subrc EQ 0.
            CONCATENATE gv_data ls_tablo_tanim-reptext gv_deli INTO gv_data.
          ELSE.
            CONCATENATE gv_data ls_comp-fieldname gv_deli INTO gv_data.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.
  APPEND gv_data TO gt_sheet1.
ENDFORM. "get_build_header

FORM get_build_item  USING ut_components  TYPE ltr_t_dd03l.

  DATA: lv_string      TYPE string,
        lv_string_tmp  TYPE string,
        lv_string_tmp2 TYPE string,
        lv_datum       TYPE datum,
        lv_date        TYPE char10,
        lv_tims        TYPE uzeit,
        lv_time        TYPE char8.

  LOOP AT <gt_itab> ASSIGNING <gfs_struc>.
    CLEAR: gv_data.
    LOOP AT ut_components INTO DATA(ls_comp).
      CLEAR: lv_string_tmp,
             lv_string_tmp2,
             lv_datum,
             lv_date,
             lv_tims,
             lv_time.

      ASSIGN COMPONENT ls_comp-fieldname OF STRUCTURE <gfs_struc> TO <gfs_field>.
      lv_string_tmp = <gfs_field>.
      IF ls_comp-rollname EQ 'VRKME' OR
         ls_comp-rollname EQ 'MEINS' OR
         ls_comp-rollname EQ 'MEINH' .
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
          EXPORTING
            input          = lv_string_tmp
          IMPORTING
            output         = lv_string_tmp2
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ELSE.
          lv_string_tmp = lv_string_tmp2.
        ENDIF.
      ENDIF.

      "---------------------
      "-----SAAT TARİH VS HANGİ TİPTE GELİRSE ONLARIN TANIMLMASI YAPILIYOR.
      IF ls_comp-inttype EQ 'D'.
        lv_datum = <gfs_field>.
        WRITE lv_datum TO lv_date DD/MM/YYYY.
        lv_string_tmp = lv_date.
      ELSEIF ls_comp-inttype EQ 'T'.
        lv_tims = <gfs_field>.
        CONCATENATE lv_tims(2) ':' lv_tims+2(2) ':' lv_tims+4(2) INTO lv_time.
        lv_string_tmp = lv_time.
      ELSEIF ls_comp-inttype EQ 'P'.
        TRANSLATE lv_string_tmp USING ', '.
        CONDENSE  lv_string_tmp NO-GAPS.
        TRANSLATE lv_string_tmp USING '.,'.
      ENDIF.

      CONCATENATE gv_data lv_string_tmp gv_deli INTO gv_data.

      IF <gfs_field> IS ASSIGNED.
        UNASSIGN <gfs_field>.
      ENDIF.
    ENDLOOP.
    APPEND gv_data TO gt_sheet1.
  ENDLOOP.

  IF <gfs_struc> IS ASSIGNED.
    UNASSIGN <gfs_struc>.
  ENDIF.

ENDFORM. "get_build_item

FORM create_sheet  USING    ut_components  TYPE ltr_t_dd03l
                            ut_sheet        TYPE gty_t_data
                            uv_subject      TYPE char50
                            uv_sheet        TYPE ole2_object
                            uv_sheet_number TYPE i.
  DATA: lv_count      TYPE i,
        lv_col_number TYPE i,
        lv_rc         TYPE i,
        lv_sheet      TYPE ole2_object,
        lt_sheet      TYPE gty_t_data.

  gv_sheet_name = uv_subject.
  lv_sheet      = uv_sheet.
  lt_sheet      = ut_sheet.

  IF uv_sheet_number EQ 1.
    lv_col_number = gv_col_number. "kolon sayısı
  ENDIF.

  IF uv_sheet_number NE 1.
    GET PROPERTY OF gv_excel 'SHEETS' = lv_sheet.
    CALL METHOD OF gv_sheet 'ADD' = lv_sheet.
    SET PROPERTY OF gv_sheet 'NAME'   = gv_sheet_name .
    GET PROPERTY OF gv_excel 'ACTIVESHEET' = gv_worksheet.
  ELSE.
    GET PROPERTY OF gv_excel 'ACTIVESHEET' = gv_worksheet.
    SET PROPERTY OF gv_worksheet 'NAME'    = gv_sheet_name .
  ENDIF.


  "-------- SHEETİ KOPYALADIK.
  CALL METHOD cl_gui_frontend_services=>clipboard_export
    IMPORTING
      data                 = lt_sheet
    CHANGING
      rc                   = lv_rc
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  """"""">>>> range konumlandırma """""""""""""""""""""""
  """""""">>>> cell konumlandırma """"""""""""""""""""""
*    CALL METHOD OF gv_excel 'CELLS' = gv_cell1
*      EXPORTING
*      #1 = 1 "Row
*      #2 = 1. "Column
  """"""""<<<< cell konumlandırma """"""""""""""""""""""
*
*    CALL METHOD OF gv_excel 'CELLS' = gv_cell2
*      EXPORTING
*      #1 = 4 "Row
*      #2 = 4. "Column
*
*    CALL METHOD OF gv_excel 'RANGE' = gv_range
*      EXPORTING
*      #1 = gv_cell1
*      #2 = gv_cell2.
  """"""">>>> range konumlandırma """""""""""""""""""""""

  """"""">>>> range performu """""""""""""""""""""
*      perform get_range USING lv_row 1 lv_row gv_num_of_col   "row1 col1 row2 col2
*                        CHANGING gv_range.
  """""""<<<< range performu """"""""""""""""""""""

  """"""">>>>col konumlandırma"""""""""""""""""""
*      CALL METHOD OF gv_excel 'COLUMNS' = gv_cols
*        EXPORTING
*        #1 = lv_tabix.
  """""""<<<<<col konumlandırma"""""""""""""""""""


  ">>>>> worksheete yazdırma(yapıştırma)
  CALL METHOD OF gv_excel 'CELLS' = gv_cell1
    EXPORTING
    #1 = 2 "Row
    #2 = 1. "Column

  CALL METHOD OF gv_excel 'CELLS' = gv_cell2
    EXPORTING
    #1 = 2 "Row
    #2 = gv_num_of_col. "Column

  "Change width of column.
*  SET PROPERTY OF gv_cell1 'COLUMNWIDTH' = 15.

  "Make range from selected cell
  CALL METHOD OF gv_excel 'RANGE' = gv_range
    EXPORTING
    #1 = gv_cell1
    #2 = gv_cell2.

  CALL METHOD OF gv_range 'SELECT'.
  CALL METHOD OF gv_worksheet 'PASTE'.
  "<<<< worksheete yazdırma(yapıştırma)

  PERFORM merge_header.

  ">>>seçenek 1: data element içeriğine göre genişliği ayarlama
  GET PROPERTY OF gv_excel 'COLUMNS' = gv_cols.
  SET PROPERTY OF gv_cols  'AutoFit' = 2.
  "<<<seçenek 1: data element içeriğine göre genişliği ayarlama
*  data: lv_sayac type i VALUE 1.
  LOOP AT ut_components INTO DATA(ls_component).
    DATA(lv_tabix) = sy-tabix.
*   ">>>seçenek 2: data element içeriğine göre genişliği ayarlama
*    CALL METHOD OF gv_excel 'CELLS' = gv_cell1
*      EXPORTING
*      #1 = 1 "Row
*      #2 = lv_tabix. "Column
*
*     SET PROPERTY OF gv_cell1 'COLUMNWIDTH' = LS_COMPONENT-leng.
*   "<<<seçenek 2: data element içeriğine göre genişliği ayarlama

  ENDLOOP.

*   ">>>seçenek 3: sabit genişlik verip shrinktofit yapma
*  data(lv_num_of_row) = GV_NUM_OF_ROW + 1.
*    perform get_range USING 3 1 lv_num_of_row gv_num_of_col   "row1 col1 row2 col2
*                      CHANGING gv_range.
*    SET PROPERTY OF gv_range 'ColumnWidth' = '10' .
*    SET PROPERTY OF gv_range 'ShrinkToFit' = 1 .
*   ">>>seçenek 3: sabit genişlik verip shrinktofit yapma

  LOOP AT ut_components INTO ls_component  .
    lv_tabix = sy-tabix.
    CALL METHOD OF gv_excel 'CELLS' = gv_cell1
      EXPORTING
      #1 = 2 "Row
      #2 = lv_tabix. "Column
    SET PROPERTY OF gv_cell1 'HorizontalAlignment' = lv_tabix.
    "1 to left, 2 to justified, 3 to centered

    SET PROPERTY OF gv_cell1 'VerticalAlignment' = lv_tabix.
    " 1 to top, 2 to center, 3 bottom
    IF ls_component-datatype = 'DATS'.
      CALL METHOD OF gv_excel 'COLUMNS' = gv_cols
        EXPORTING
        #1 = lv_tabix.
      SET PROPERTY OF gv_cols 'NUMBERFORMAT' = 'DD.MM.YYYY'.

      CALL METHOD OF gv_cols 'Validation' = gv_validation.
      CALL METHOD OF gv_validation 'Add'
        EXPORTING
          #1 = 4 "Type       = xlValidateDate
          #2 = 1 "AlertStype = xlValidAlertStop
          #3 = 1 "Operator   = xlBetween
          #4 = '01.01.1970' "Formula1
          #5 = '01.01.2004'. "Formula2

      SET PROPERTY OF gv_validation 'ErrorMessage' = '18 yaşından küçükler kayıt olamaz'.
      SET PROPERTY OF gv_cols 'HorizontalAlignment' = 1.
    ENDIF.
*    if lv_tabix = 7.
*      SET PROPERTY OF gv_cols 'NumberFormat' = '0.0000'.
*    endif.
  ENDLOOP.

*>>> zebra deseni
  DATA(lv_renk) = 8.
  DATA: lv_row TYPE i.
  DO gv_num_of_row TIMES.
    lv_row = sy-index + 2.
*    lv_row = sy-index + 1.
    PERFORM get_range USING lv_row 1 lv_row gv_num_of_col   "row1 col1 row2 col2
                      CHANGING gv_range.
*    IF lv_row = 1 .
*      CLEAR lv_renk.
*      lv_renk = 5.
*      GET PROPERTY OF gv_range 'FONT' = gv_font NO FLUSH.
*      SET PROPERTY OF gv_font 'ITALIC' = 1.
*      SET PROPERTY OF gv_font 'COLORINDEX' = lv_renk.
*      SET PROPERTY OF gv_font 'PATTERN' = 1.
*    ELSE.
    CALL METHOD OF gv_range 'Interior' = gv_int.
    SET PROPERTY OF gv_int 'COLORINDEX' = lv_renk.
    SET PROPERTY OF gv_int 'PATTERN' = 1.
    IF lv_renk = 7.
      lv_renk = 8.
    ELSE.
      lv_renk = 7.
    ENDIF.
    GET PROPERTY OF gv_range 'FONT' = gv_font NO FLUSH.
    SET PROPERTY OF gv_font 'ITALIC' = 1.
    SET PROPERTY OF gv_font 'COLORINDEX' = lv_renk.
    SET PROPERTY OF gv_font 'PATTERN' = 1.
**    ENDIF.
  ENDDO.
*<<< zebra deseni

  "Başlık renk atama lv_col_number kolon sayısıdır
  CLEAR lv_count.
  DO lv_col_number TIMES.
    ADD 1 TO lv_count.

    CALL METHOD OF gv_excel 'CELLS' = gv_cell  NO FLUSH
       EXPORTING #1 = 1
                 #2 = lv_count.

    CALL METHOD OF gv_cell 'INTERIOR' = gv_int .
    SET PROPERTY OF gv_int 'COLORINDEX' = 50 .
    SET PROPERTY OF gv_int 'PATTERN' = 1 .

    GET PROPERTY OF gv_cell 'FONT' = gv_font NO FLUSH.
    SET PROPERTY OF gv_font 'BOLD' = 1 NO FLUSH.
    SET PROPERTY OF gv_font 'ITALIC' = 1.

    SET PROPERTY OF gv_font 'SIZE' = 20 .
    SET PROPERTY OF gv_font 'COLORINDEX' = 24 .
    SET PROPERTY OF gv_font 'PATTERN' = 1 .

  ENDDO.

*  CALL METHOD OF gv_excel 'CELLS' = gv_cell NO FLUSH
*    EXPORTING #1 = 2
*              #2 = 2.
*
*  GET PROPERTY OF gv_cell 'FONT' = gv_font NO FLUSH.
*  SET PROPERTY OF gv_font 'UNDERLINE' = 2.
CLEAR lv_count.
  DO lv_col_number TIMES.
    ADD 1 TO lv_count.

    CALL METHOD OF gv_excel 'CELLS' = gv_cell  NO FLUSH
          EXPORTING #1 = 2
                    #2 = lv_count.

    CALL METHOD OF gv_cell 'INTERIOR' = gv_int .
    SET PROPERTY OF gv_int 'COLORINDEX' = 3 .
    SET PROPERTY OF gv_int 'PATTERN' = 1 .

    GET PROPERTY OF gv_cell 'FONT' = gv_font NO FLUSH.
    SET PROPERTY OF gv_font 'COLORINDEX' = 1 .
    SET PROPERTY OF gv_font 'SIZE' = 12 .
    SET PROPERTY OF gv_font 'BOLD' = 1 NO FLUSH.
    SET PROPERTY OF gv_font 'UNDERLINE' = 2.
  ENDDO.
*   CALL METHOD OF lo_worksheet ‘Cells’ = lo_cell
*EXPORTING
*#1 = 1  “Row
*#2 = 2. “Column
*SET PROPERTY OF lo_cell ‘Value’ = ‘Hello World’.
*CALL METHOD OF lo_cell ‘FONT’ = lo_font.
*
*SET PROPERTY OF lo_font 'Color' = –16776961.
*SET PROPERTY OF lo_font 'TintAndShade' = 0.
*
*SET PROPERTY OF lo_font ‘Bold’ = 1.
*SET PROPERTY OF lo_font ‘Italic’ = 1.
*SET PROPERTY OF lo_font ‘Underline’ = 2. “xlUnderlineStyleSingle
*
*DATA: lo_interior TYPE ole2_object.
*CALL METHOD OF lo_cell 'Interior' = gv_int.
*SET PROPERTY OF lo_interior 'Color' = 15773696.

  FREE OBJECT: gv_sheet.
ENDFORM. "create_sheet

FORM save_excel .
  CALL METHOD OF gv_worksheet 'SAVEAS' EXPORTING #1 = gv_filename.
  CALL METHOD OF gv_worksheet 'CLOSE'.
  CALL METHOD OF gv_excel 'QUIT'.
  FREE OBJECT:  gv_cell,
                gv_sheets,
                gv_sheet,
                gv_excel.
ENDFORM. "save_excel
*&---------------------------------------------------------------------*
*& Form GET_RANGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*      -->P_       text
*      -->P_       text
*      -->P_       text
*      -->P_       text
*      <--P_GV_RANGE  text
*      <--P_CLEAR  text
*      <--P_LV_COUNT  text
*&---------------------------------------------------------------------*
FORM get_range   USING pv_start_row
                       pv_start_col
                       pv_end_row
                       pv_end_col
              CHANGING pv_range TYPE ole2_object.

  CALL METHOD OF gv_excel 'CELLS' = gv_cell1
    EXPORTING
    #1 = pv_start_row "Row
    #2 = pv_start_col. "Column

  CALL METHOD OF gv_excel 'CELLS' = gv_cell2
    EXPORTING
    #1 = pv_end_row "Row
    #2 = pv_end_col. "Column

  CALL METHOD OF gv_excel 'RANGE' = pv_range
    EXPORTING
    #1 = gv_cell1
    #2 = gv_cell2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MERGE_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM merge_header.
  PERFORM get_range USING 1 1 1 gv_num_of_col   "row1 col1 row2 col2
                    CHANGING gv_range.
  CALL METHOD OF gv_range 'SELECT'.
  CALL METHOD OF gv_range 'Merge' .


  CALL METHOD OF gv_excel 'CELLS' = gv_cell1
    EXPORTING
    #1 = 1 "Row
    #2 = 1. "Column

  SET PROPERTY OF gv_cell1 'Value' = 'ÇALIŞAN PERSONEL BİLGİSİ'.
  SET PROPERTY OF gv_cell1 'HorizontalAlignment' = 3.

ENDFORM.
