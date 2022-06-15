FUNCTION ZEO_COLUMN_NAME_2.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_COLUMN_NUMBER) TYPE  I
*"  EXPORTING
*"     REFERENCE(EV_COLUMN_NAME) TYPE  STRING
*"--------------------------------------------------------------------

 DATA: lv_col_temp  TYPE i,
       lv_mod       TYPE i.

  CLEAR: ev_column_name.
  CHECK iv_column_number > 0.
  lv_col_temp = iv_column_number.

  WHILE lv_col_temp > 0.
    lv_mod = ( lv_col_temp - 1 ) MOD 26.
    ev_column_name = sy-abcde+lv_mod(1) && ev_column_name.
    lv_col_temp = ( lv_col_temp - lv_mod ) / 26.
  ENDWHILE.




ENDFUNCTION.
