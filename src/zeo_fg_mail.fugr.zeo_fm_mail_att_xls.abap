FUNCTION ZEO_FM_MAIL_ATT_XLS.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_SUBJECT) TYPE  CHAR50 OPTIONAL
*"     VALUE(IT_ATTACHMENTS_DATA) TYPE  ANY TABLE
*"  EXPORTING
*"     REFERENCE(ET_ATTACHMENTS) TYPE  RMPS_T_POST_CONTENT
*"--------------------------------------------------------------------
*&---------------------------------------------------------------------*
* " Bülent Özen / 30.03.2022 14:54:30 / Mail Gönderimi için excel dosya eki oluşturma
*&---------------------------------------------------------------------*

* Global data declarations


  CONSTANTS: gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
             gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.

  DATA: gs_attachments TYPE rmps_post_content,
        gv_string      TYPE string,
        gv_string_tmp  TYPE string,
        gv_string_tmp2 TYPE string,
        gv_size        TYPE so_obj_len,
        gv_datum       TYPE datum,
        gv_date        TYPE char10,
        gv_tims        TYPE uzeit,
        gv_time        TYPE char8.

  DATA: gt_comp          TYPE abap_compdescr_tab, "Fieldcat
        gs_comp_a        LIKE LINE OF gt_comp,    "Fieldcat
        gd_type          TYPE abap_typekind,
        gv_absolute_name TYPE abap_abstypename.

  DATA: go_struct TYPE REF TO cl_abap_structdescr,
        go_table  TYPE REF TO cl_abap_tabledescr,
        gdo_data  TYPE REF TO data.

  FIELD-SYMBOLS: <gt_itab>   TYPE table,
                 <lfs_struc> TYPE any,
                 <lfs_field> TYPE any.

  GET REFERENCE OF it_attachments_data INTO gdo_data.
  ASSIGN gdo_data->* TO <gt_itab>.

  go_table  ?= cl_abap_structdescr=>describe_by_data_ref( gdo_data ).
  go_struct ?= go_table->get_table_line_type( ).
  gt_comp = go_struct->components.
  gv_absolute_name = go_struct->absolute_name.
  SPLIT gv_absolute_name AT '=' INTO DATA(lv_dummy) DATA(lv_abs_name).

  CLEAR:   gs_attachments, gv_string.
  REFRESH: et_attachments.

  IF lv_abs_name IS NOT INITIAL.
    "başlıkların standart isimleri getirilir
    SELECT *
      FROM dd03l
      INTO TABLE @DATA(lt_components)
      WHERE tabname EQ @lv_abs_name.

    IF lt_components IS NOT INITIAL.
      SELECT  rollname,
              ddlanguage,
              reptext
        FROM dd04t
        INTO TABLE @DATA(lt_tablo_tanim)
        FOR ALL ENTRIES IN @lt_components
        WHERE rollname EQ @lt_components-rollname
          AND as4local EQ 'A'.                     "#EC CI_NO_TRANSFORM
    ENDIF.
  ENDIF.

* Başlık bilgisi
  LOOP AT lt_components INTO DATA(ls_comp).
    READ TABLE lt_tablo_tanim INTO DATA(ls_tablo_tanim) WITH KEY rollname   = ls_comp-rollname
                                                                 ddlanguage = sy-langu.
    IF sy-subrc EQ 0.
      CONCATENATE gv_string ls_tablo_tanim-reptext  gc_tab INTO gv_string.
    ELSE.
      READ TABLE lt_tablo_tanim INTO ls_tablo_tanim WITH KEY rollname   = ls_comp-rollname
                                                             ddlanguage = 'T'.
      IF sy-subrc EQ 0.
        CONCATENATE gv_string ls_tablo_tanim-reptext  gc_tab INTO gv_string.
      ELSE.
        READ TABLE lt_tablo_tanim INTO ls_tablo_tanim WITH KEY rollname   = ls_comp-rollname.
        IF sy-subrc EQ 0.
          CONCATENATE gv_string ls_tablo_tanim-reptext  gc_tab INTO gv_string.
        ELSE.
          CONCATENATE gv_string ls_comp-fieldname  gc_tab INTO gv_string.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  CONCATENATE gv_string gc_crlf INTO gv_string.

* Kalem bilgisi
  LOOP AT <gt_itab> ASSIGNING <lfs_struc>.
    LOOP AT lt_components INTO ls_comp.
      CLEAR: gv_string_tmp,gv_string_tmp2,gv_datum,gv_date.
      ASSIGN COMPONENT ls_comp-fieldname OF STRUCTURE <lfs_struc> TO <lfs_field>.
      gv_string_tmp = <lfs_field>.
      IF ls_comp-rollname EQ 'VRKME' OR
         ls_comp-rollname EQ 'MEINS' OR
         ls_comp-rollname EQ 'MEINH' .
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
          EXPORTING
            input          = gv_string_tmp
          IMPORTING
            output         = gv_string_tmp2
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ELSE.
          gv_string_tmp = gv_string_tmp2.
        ENDIF.
      ENDIF.
      IF ls_comp-inttype EQ 'D'.
        gv_datum = <lfs_field>.
        WRITE gv_datum TO gv_date DD/MM/YYYY.
        gv_string_tmp = gv_date.
      ELSEIF ls_comp-inttype EQ 'T'.
        gv_tims = <lfs_field>.
        CONCATENATE gv_tims(2) ':' gv_tims+2(2) ':' gv_tims+4(2) INTO gv_time.
        gv_string_tmp = gv_time.
      ELSEIF ls_comp-inttype EQ 'P'.
        TRANSLATE gv_string_tmp USING ', '.
        CONDENSE gv_string_tmp NO-GAPS.
        TRANSLATE gv_string_tmp USING '.,'.
      ENDIF.
      CONCATENATE gv_string gv_string_tmp  gc_tab INTO gv_string.
      IF <lfs_field> IS ASSIGNED.
        UNASSIGN <lfs_field>.
      ENDIF.
    ENDLOOP.
    CONCATENATE gv_string gc_crlf INTO gv_string.
  ENDLOOP.
  IF <lfs_struc> IS ASSIGNED.
    UNASSIGN <lfs_struc>.
  ENDIF.

  CONCATENATE iv_subject sy-datum sy-timlo INTO gs_attachments-subject SEPARATED BY '_'.
  gs_attachments-objtp = 'XLS'.

  TRY.
      cl_bcs_convert=>string_to_solix(
        EXPORTING
          iv_string   = gv_string
          iv_codepage = '4103'  "suitable for MS Excel, leave empty
          iv_add_bom  = 'X'     "for other doc types
        IMPORTING
          et_solix  = gs_attachments-cont_hex
          ev_size   = gv_size ).
    CATCH cx_bcs.
      MESSAGE e445(so).
  ENDTRY.

  APPEND gs_attachments TO et_attachments.


ENDFUNCTION.
