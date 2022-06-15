*&---------------------------------------------------------------------*
*& Include          ZEO_EXCEL_ODEV_01_CLS
*&---------------------------------------------------------------------*

CLASS lcl_alv2 DEFINITION.
  PUBLIC SECTION.


    TYPES: BEGIN OF gty_table,
             mandt          TYPE mandt,
             tc             TYPE zegt_emine_tc_de,
             adi            TYPE zegt_emine_adi_de,
             soyadi         TYPE zegt_emine_soyadi_de,
             cins           TYPE zegt_emine_cins_de,
             dogum_tar      TYPE zegt_emine_tarih_de,
             askerlik_durum TYPE zegt_emine_de6,
             sirket_adi     TYPE zegt_emine_sadi_de,
             email          TYPE zegt_emine_mail_de,
           END OF gty_table.

    DATA: gt_table TYPE TABLE OF gty_table,
          gs_table TYPE gty_table.


    DATA: gt_fcat   TYPE lvc_t_fcat,
          gs_fcat   TYPE lvc_s_fcat,
          gs_layout TYPE lvc_s_layo.

    DATA : go_alv  TYPE REF TO cl_gui_alv_grid.



    METHODS :
      set_excel_button,
      set_xls_header,
      veri_yukle,
      download_excel,
      get_data,
      set_fcat,
      set_layout,
      display_alv,
      buton_ekle,
      veri_aktar.

ENDCLASS.


CLASS lcl_alv2 IMPLEMENTATION.

  METHOD set_excel_button.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name   = icon_okay
        text   = TEXT-019
        info   = TEXT-019
      IMPORTING
        result = gv_exclb
      EXCEPTIONS
        OTHERS = 0.
  ENDMETHOD. "set_excel_button

  METHOD set_xls_header.
    REFRESH: gt_header.
    APPEND TEXT-002 TO gt_header. "mandtli alan
    APPEND TEXT-003 TO gt_header. "tc
    APPEND TEXT-004 TO gt_header. "adi
    APPEND TEXT-005 TO gt_header. "soyadi
    APPEND TEXT-006 TO gt_header. "cinsiyet
    APPEND TEXT-007 TO gt_header. "Doğum Tarihi
    APPEND TEXT-008 TO gt_header. "Askerlik Durumu
    APPEND TEXT-009 TO gt_header. "Şirket Adı
    APPEND TEXT-010 TO gt_header. "E-mail

  ENDMETHOD.


  METHOD veri_yukle.
    DATA: lt_raw   TYPE truxs_t_text_data,
          lv_flag  TYPE c VALUE 'F',
          lv_flag2 TYPE c VALUE 'F'.

    "excelden veri çekme için kullanılıyor.
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_line_header        = abap_true "başlık olup olmaması.
        "abap true olduğu zaman başlık var diye 2.satırdan devam eder.
        i_tab_raw_data       = lt_raw
        i_filename           = p_file
      TABLES
        i_tab_converted_data = gt_emine
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    LOOP AT gt_emine INTO DATA(ls_table). "Excelden gelen verileri bu itabda tutuyoruz.Loop da tek tek dönüyoruz.
      MOVE-CORRESPONDING ls_table TO gs_table. "loop içinde gelen veriyi tanımladığımız gs ye aktarıyoruz.
      MODIFY zegt_eo_t001 FROM gs_table.
    ENDLOOP.


  ENDMETHOD.

  METHOD download_excel.
    DATA: lv_i        TYPE i VALUE 1,
          lv_date(10).

    DATA: lv_selected_folder TYPE string,
          lv_complete_path   TYPE char256,
          lv_titulo          TYPE string.

    DEFINE ole_excel.
      CALL METHOD OF
       gs_ole_excel
       'CELLS' = gs_ole_cell
       EXPORTING
       #1 = &1
       #2 = &2.
     GET PROPERTY OF gs_ole_cell 'Font'  = gs_ole_font.
     SET PROPERTY OF gs_ole_font 'Bold'  = &3.
     SET PROPERTY OF gs_ole_cell 'Value' = &4.
    END-OF-DEFINITION.

    CREATE OBJECT gs_ole_excel 'Excel.Application'.
    SET PROPERTY OF gs_ole_excel 'Visible' = 1.
    CALL METHOD OF
      gs_ole_excel
        'WORKBOOKS' = gs_ole_workbook.
    CALL METHOD OF
      gs_ole_workbook
      'ADD'.
    "2.Excel Sheet eklemek için kullanılıyor.
*    CALL METHOD OF
*      gs_ole_excel
*        'WORKSHEETS' = gs_ole_sheet.
*    CALL METHOD OF
*      gs_ole_sheet
*      'ADD'.

    LOOP AT gt_header INTO DATA(ls_header).
      ole_excel 1 lv_i 1 ls_header-header.
      ADD 1 TO lv_i.
    ENDLOOP.

    FREE OBJECT gs_ole_cell.
    FREE OBJECT gs_ole_font.
  ENDMETHOD. "download_excel

  METHOD get_data.
    CLEAR: gt_table.
    SELECT mandt,
           tc,
           adi,
           soyadi,
           cins,
           dogum_tar,
           askerlik_durum,
           sirket_adi,
           email
      FROM zegt_eo_t001
      INTO TABLE @gt_table.


  ENDMETHOD.

  METHOD set_fcat.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = 'ZEGT_EO_S001'
      CHANGING
        ct_fieldcat            = gt_fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.

  ENDMETHOD.

  METHOD set_layout.
    gs_layout-zebra = 'X'.
    gs_layout-cwidth_opt = abap_true .
    gs_layout-col_opt = abap_true .
  ENDMETHOD.



  METHOD display_alv.

    go_alv = NEW cl_gui_alv_grid(
        i_parent          = cl_gui_container=>screen0 ).

    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout  " Layout
      CHANGING
        it_outtab       = gt_table   " Output Table
        it_fieldcatalog = gt_fcat.  " Field Catalog

  ENDMETHOD.

  METHOD buton_ekle .
    gs_emine_button-icon_id = icon_save_as_template.
    gs_emine_button-icon_text = |Template|.
    gs_emine_button-quickinfo = 'Template Download'.
    sscrfields-functxt_01 = gs_emine_button.
  ENDMETHOD.

  METHOD veri_aktar.

    SELECT *
    FROM zegt_eo_t001
    INTO TABLE gt_emine.

    CALL FUNCTION 'ZEO_OLE_DOWNLOAD'
      EXPORTING
        iv_subject = 'Sayfa'
        it_data    = gt_emine.
*   IT_TITLE            =
*   IT_COMPONENTS       =.

  ENDMETHOD.

ENDCLASS.
