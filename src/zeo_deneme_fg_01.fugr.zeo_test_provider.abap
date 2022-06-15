FUNCTION zeo_test_provider.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATNR) TYPE  MATNR
*"  EXPORTING
*"     VALUE(ES_DETAIL) TYPE  MARA
*"----------------------------------------------------------------------

  DATA : lv_matnr TYPE char10.


CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
  EXPORTING
    input              = iv_matnr
 IMPORTING
   OUTPUT             = lv_matnr
 EXCEPTIONS
   LENGTH_ERROR       = 1
   OTHERS             = 2
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.


  SELECT SINGLE *
    FROM mara
    INTO es_detail
    WHERE matnr EQ iv_matnr.






ENDFUNCTION.
