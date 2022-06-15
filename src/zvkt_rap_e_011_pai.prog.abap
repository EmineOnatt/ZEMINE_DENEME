*&---------------------------------------------------------------------*
*& Include          ZVKT_RAP_E_011_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN '&BACK'.
      LEAVE TO SCREEN 0.
    WHEN '&EXIT' .
      LEAVE TO SCREEN 0.
    WHEN '&YENILE' .
      IF go_oo_alv IS NOT INITIAL.
        go_oo_alv->start_of_selection( ).
        go_oo_alv->refresh_alv( ).
      ENDIF.
    WHEN '&ADOBE' .
      go_oo_alv->print_adobe( ).
    WHEN '&SMART' .
      go_oo_alv->print_smarform( ).
    WHEN '&MAIL' .
      go_oo_alv->send_mail( ).
    WHEN '&EXCEL' .
      go_oo_alv->excel_indir( ).
    WHEN '&NOT' .
      go_oo_alv->kaydet( ).
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
