*&---------------------------------------------------------------------*
*& Report ZVKT_RAP_E_009
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvkt_rap_e_009.

INCLUDE: zvkt_rap_e_009_top,
         zvkt_rap_e_009_cls.

INITIALIZATION.
  go_obj = NEW lcl_mail( ).
  go_obj->set_kaydet_button( ).

*
*AT SELECTION-SCREEN.
*  CASE sy-ucomm.
*    WHEN 'UC1'.
*      go_obj->mail( ).
*    WHEN OTHERS.
*  ENDCASE.


  START-OF-SELECTION.
   go_obj->mail( ).
