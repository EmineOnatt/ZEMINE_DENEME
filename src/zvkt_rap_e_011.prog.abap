*&---------------------------------------------------------------------*
*& Report ZVKT_RAP_E_011
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvkt_rap_e_011.

INCLUDE: zvkt_rap_e_011_top,
         zvkt_rap_e_011_cls,
         zvkt_rap_e_011_mdl.

START-OF-SELECTION.

  go_oo_alv = NEW lcl_odev( ) .

  go_oo_alv->get_data( ).
  go_oo_alv->set_layout( ).
  go_oo_alv->set_fcat( ).
  go_oo_alv->display_alv( ).



  CALL SCREEN 0100.
