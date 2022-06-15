*&---------------------------------------------------------------------*
*& Include          ZVKT_RAP_E_013_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm .
    WHEN '&BACK' .
      LEAVE TO SCREEN 0.
    WHEN '&EXIT'.
      LEAVE PROGRAM.
    WHEN 'BSVR'.
      PERFORM gayit.
    WHEN '&GNC'.
      PERFORM guncelle.
    WHEN 'YNT'.
*      CALL SCREEN 0200.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE sy-ucomm .
    WHEN '&BACK' .
      LEAVE TO SCREEN 0.
    WHEN '&EXIT'.
      LEAVE PROGRAM.
    WHEN '&LGN'.
      PERFORM login.
    WHEN '&KYT'.
      PERFORM onay.
    WHEN '&MAIL'.
      PERFORM send_mail.
    WHEN '&RED'.
      PERFORM reddet.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
