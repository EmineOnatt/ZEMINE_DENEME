FUNCTION ZEO_FM_MAIL_ATT_PDF.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_SUBJECT) TYPE  CHAR255 OPTIONAL
*"     VALUE(IS_PDF) TYPE  FPFORMOUTPUT
*"  EXPORTING
*"     VALUE(ET_ATTACHMENTS) TYPE  RMPS_T_POST_CONTENT
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
* " Bülent Özen / 30.03.2022 14:55:44 / Mail Gönderimi için pdf dosya eki oluşturma
*&---------------------------------------------------------------------*

  DATA: ls_attachments LIKE LINE OF et_attachments.
  CLEAR: ls_attachments.

  ls_attachments-objtp = 'PDF'.
  IF iv_subject IS NOT INITIAL.
    ls_attachments-subject = iv_subject.
  ELSE.
    CONCATENATE sy-datum sy-timlo INTO ls_attachments-subject.
  ENDIF.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer     = is_pdf-pdf
    TABLES
      binary_tab = ls_attachments-cont_hex.

  APPEND ls_attachments TO et_attachments.



ENDFUNCTION.
