*&---------------------------------------------------------------------*
*& Report ZVKT_RAP_E_SALV2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZVKT_RAP_E_SALV2.

DATA: gt_table TYPE TABLE OF zegt_emine_t001,
      go_salv  TYPE REF TO cl_salv_table. "Hazır fonksiyon kullanıldı.

START-OF-SELECTION.

*  SELECT * FROM zegt_emine_t001
*    INTO TABLE gt_table.

SELECT * UP TO 10 ROWS FROM zegt_emine_t001
    INTO TABLE gt_table.

  cl_salv_table=>factory(
      IMPORTING
      r_salv_table   =  go_salv
    CHANGING
      t_table        =  gt_table
  ).

  " Görüntüdeki başlık kısmı ayarlama
  DATA: lo_display TYPE REF TO cl_salv_display_settings.

  lo_display = go_salv->get_display_settings( ).
  lo_display->set_list_header( value = 'SALV ORNEK' ).
  lo_display->set_striped_pattern( value = 'X' ).

  " Kolon yapısındaki fazla boşluk kısmını ayarlıyor.
  DATA: lo_cols TYPE REF TO cl_salv_columns.

  lo_cols = go_salv->get_columns( ). "classlardaki eşitleme yapıldı.
  lo_cols->set_optimize( value = 'X' ).

  DATA: lo_col TYPE REF TO cl_salv_column.

  "Kodda kontrol alanı sağlıyor.
  TRY.
      lo_col = lo_cols->get_column( columnname = 'DOGUM_TAR' ).
      " Kolonda kolon ismini yeniden adlandırdık.
      lo_col->set_long_text('Yeni Doğum Tarihi').
      lo_col->set_medium_text('Yeni Doğum T.').
      lo_col->set_short_text('Yeni Doğum').
    CATCH cx_salv_not_found.
  ENDTRY.

  TRY.
      lo_col = lo_cols->get_column( columnname = 'B_MAAS' ).
      lo_col->set_visible( "Tabloda görünmesini istemediğimiz kolonu ayarladık.
          value = if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.
  ENDTRY.

  "ALV Ekranını Popup Şeklinde Gösterme
  go_salv->set_screen_popup(
    EXPORTING
      start_column = 10
      end_column   = 90
      start_line   = 5
      end_line     = 20
  ).


  go_salv->display( ).


*cl_salv_table=>factory(
**  EXPORTING
**    list_display   = IF_SALV_C_BOOL_SAP=>FALSE    " ALV Displayed in List Mode
**    r_container    =     " Abstract Container for GUI Controls
**    container_name =
**  IMPORTING
**    r_salv_table   =     " Basis Class Simple ALV Tables
*  CHANGING
*    t_table        =
*).
**  CATCH cx_salv_msg.    "
