*&---------------------------------------------------------------------*
*& Report ZVKT_RAP_E_007
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvkt_rap_e_007.

INCLUDE: zvkt_rap_e_007_top,
         zvkt_rap_e_007_cls,
         zvkt_rap_e_007_pbo,
         zvkt_rap_e_007_pai.

START-OF-SELECTION.

  go_ealv = NEW lcl_alv2( ).

  go_ealv->get_data( ).
  go_ealv->set_fcat( ).
  go_ealv->set_layo( ).
  go_ealv->display_alv( ).

  CALL SCREEN 0100.
