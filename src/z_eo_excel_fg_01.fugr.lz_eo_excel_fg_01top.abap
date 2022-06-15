FUNCTION-POOL Z_EO_EXCEL_FG_01.             "MESSAGE-ID ..



* INCLUDE LZEM_FG1D...                       " Local class definition

TYPES: BEGIN OF gty_tablo_tanim,
         rollname   TYPE rollname,
         ddlanguage TYPE ddlanguage,
         reptext    TYPE reptext,
       END OF gty_tablo_tanim,
       gtt_tablo_tanim TYPE TABLE OF gty_tablo_tanim.

FIELD-SYMBOLS: <gt_itab>   TYPE table,
               <gfs_struc> TYPE any,
               <gfs_field> TYPE any.

*  "Excel Tanımlamaları
TYPES: gty_data1(1500) TYPE c,
    gty_t_data      TYPE TABLE OF gty_data1.

DATA: gv_filename       TYPE string,
      gv_error          TYPE char1,
      gv_cell1          TYPE ole2_object,
      gv_cols          TYPE ole2_object,
      gv_validation     TYPE ole2_object,
      gv_cell2          TYPE ole2_object,
      gv_excel          TYPE ole2_object,"Excel object
      gv_sheets         TYPE ole2_object,"list of workbooks
      gv_sheet          TYPE ole2_object,"workbook
      gv_cell           TYPE ole2_object,"cell
      gv_worksheet      TYPE ole2_object,"Worksheet
      gv_color          TYPE ole2_object,"Color
      gv_range          TYPE ole2_object,"Range
      gv_int          TYPE ole2_object,"interior
      gv_borders        TYPE ole2_object,"Borders
      gv_sheet1         TYPE ole2_object,"First sheet
      gv_font           TYPE ole2_object,"Font
      gt_sheet1         TYPE gty_t_data,
      gv_data           TYPE gty_data1,
      gv_deli(1)        TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
      gv_sheet_name(20) TYPE c,
      gv_color_white    TYPE i VALUE 2, "Beyaz
      gv_color_blue     TYPE i VALUE 37, "Açık mavi
      gv_color_grup     TYPE i VALUE 4, "grup için kullanılan renk
      gv_col_number     TYPE i,
      gv_col_name       TYPE string.

data: gv_num_of_row type i,
      gv_num_of_col type i.
* INCLUDE LZ_EO_EXCEL_FG_01D...              " Local class definition
