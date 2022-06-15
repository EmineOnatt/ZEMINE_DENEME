*&---------------------------------------------------------------------*
*& Include          ZEO_EXCEL_ODEV_01_TOP
*&---------------------------------------------------------------------*
CLASS lcl_alv2 DEFINITION DEFERRED.

INCLUDE ole2incl.
DATA : gs_ole_excel    TYPE ole2_object,
       gs_ole_workbook TYPE ole2_object,
       gs_ole_sheet    TYPE ole2_object,
       gs_ole_cell     TYPE ole2_object,
       gs_ole_font     TYPE ole2_object.

TABLES: zegt_eo_t001,
        sscrfields.

DATA: BEGIN OF gt_header OCCURS 0,
        header TYPE char100,
      END OF gt_header.

DATA: go_ealv TYPE REF TO lcl_alv2.
DATA: gs_emine_button TYPE smp_dyntxt.

DATA: gt_emine TYPE TABLE OF zegt_eo_t001,
      gs_emine TYPE zegt_eo_t001.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

SELECTION-SCREEN SKIP.  "boş satır bırakma.
PARAMETERS p_file TYPE localfile.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN SKIP.

SELECTION-SCREEN PUSHBUTTON 30(45) gv_exclb USER-COMMAND uc1.

SELECTION-SCREEN: END OF BLOCK b1.

SELECTION-SCREEN FUNCTION KEY 1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file. "yardımcı oluşturabilmek için.

  "hangi excelden geldiğini bilmek için yapıldı.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'P_FILE'
    IMPORTING
      file_name  = p_file.


*CALL FUNCTION 'ZEM_OLE_EXCEL_DOWNLOAD'
*  EXPORTING
*    IV_SUBJECT          = 'Sayfa'
*    IT_DATA             = lt_table.
**   IT_TITLE            =
**   IT_COMPONENTS       =.
