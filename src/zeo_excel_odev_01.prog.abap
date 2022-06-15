*&---------------------------------------------------------------------*
*& Report ZEO_EXCEL_ODEV_01
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zeo_excel_odev_01.

INCLUDE: zeo_excel_odev_01_top,
         zeo_excel_odev_01_cls,
         zeo_excel_odev_01_pbo,
         zeo_excel_odev_01_pai.

INITIALIZATION.
  go_ealv = NEW lcl_alv2( ).
  go_ealv->set_excel_button( ).
  go_ealv->set_xls_header( ).
  go_ealv->buton_ekle( ).

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'FC01'.
      go_ealv->veri_aktar( ).
    WHEN 'UC1'.
      go_ealv->download_excel( ).
    WHEN OTHERS.
  ENDCASE.

START-OF-SELECTION.


  go_ealv->veri_yukle( ).
  go_ealv->get_data( ).
  go_ealv->set_fcat( ).
  go_ealv->set_layout( ).
  go_ealv->display_alv( ).

  CALL SCREEN 0100.
