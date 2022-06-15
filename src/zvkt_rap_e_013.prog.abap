*&---------------------------------------------------------------------*
*& Report ZVKT_RAP_E_013
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zvkt_rap_e_013.

INCLUDE : zvkt_rap_e_013_top,
          zvkt_rap_e_013_cls,
          zvkt_rap_e_013_frm,
          zvkt_rap_e_013_pbo,
          zvkt_rap_e_013_pai.

AT SELECTION-SCREEN OUTPUT.

  PERFORM secenek.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_user.
*
*  SELECT id INTO CORRESPONDING FIELDS OF TABLE gt_kullanici
*
*  FROM zvkt_eo_t004.
**  WHERE .
*  IF sy-subrc = 0.
*
*    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*      EXPORTING
*        retfield        = 'ID'
*        dynpprog        = sy-cprog
*        dynpnr          = sy-dynnr
*        dynprofield     = 'P_USER'
*        value_org       = 'S'
*      TABLES
*        value_tab       = gt_kullanici
*      EXCEPTIONS
*        parameter_error = 1
*        no_values_found = 2
*        OTHERS          = 3.
*    IF sy-subrc <> 0.
*      REFRESH gt_kullanici.
*    ENDIF.
*  ENDIF.

START-OF-SELECTION.

  PERFORM start_of_selection.
