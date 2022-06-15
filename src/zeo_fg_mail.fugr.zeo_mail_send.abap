FUNCTION ZEO_MAIL_SEND .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(SUBJECT) TYPE  SO_OBJ_DES
*"     VALUE(MESSAGE_TYPE) TYPE  CHAR03
*"     REFERENCE(MESSAGE_BODY) TYPE  W3HTMLTAB OPTIONAL
*"     REFERENCE(ATTACHMENTS) TYPE  RMPS_T_POST_CONTENT OPTIONAL
*"     REFERENCE(SENDER_UID) TYPE  SYUNAME OPTIONAL
*"     REFERENCE(RECIPIENT_UID) TYPE  SYUNAME OPTIONAL
*"     VALUE(SENDER_MAIL) TYPE  AD_SMTPADR
*"     REFERENCE(RECIPIENT_MAIL) TYPE  AD_SMTPADR OPTIONAL
*"     REFERENCE(RECIPIENTS) TYPE  UIYT_IUSR OPTIONAL
*"     REFERENCE(RECIPIENTS_CC) TYPE  UIYT_IUSR OPTIONAL
*"     REFERENCE(RECIPIENT_BCC) TYPE  AD_SMTPADR OPTIONAL
*"     REFERENCE(COMMIT) TYPE  CHAR1 DEFAULT 'X'
*"  EXPORTING
*"     REFERENCE(RESULT) TYPE  BOOLEAN
*"--------------------------------------------------------------------
*&---------------------------------------------------------------------*
* " Bülent Özen / 30.03.2022 14:51:37 / Mail Gönderme Fonksiyonu
*&---------------------------------------------------------------------*


*Data Declaration
*-----------------------------------------------*
* Global data declarations

  DATA: lo_send_request    TYPE REF TO cl_bcs           VALUE IS INITIAL,
        lo_document        TYPE REF TO cl_document_bcs  VALUE IS INITIAL,
        lo_sender          TYPE REF TO if_sender_bcs    VALUE IS INITIAL,
        lo_recipient       TYPE REF TO if_recipient_bcs VALUE IS INITIAL,
        attachment_subject TYPE so_obj_des,
        attachment_size    TYPE so_obj_len,
        ls_recipient       LIKE LINE OF recipients,
        ls_attachment      LIKE LINE OF attachments,
        lv_recipient_uid   TYPE uname,
        lv_recipient_mail  TYPE adr6-smtp_addr.

  DATA: lv_msg(100).
  DATA: lo_ctx TYPE REF TO cx_send_req_bcs.

  CLASS cl_bcs DEFINITION LOAD.

*-----------------------------------------------*
*Prepare Mail Object
*-----------------------------------------------*
  TRY.
      lo_send_request = cl_bcs=>create_persistent( ).
    CATCH cx_send_req_bcs.
      result = ''. RETURN.
  ENDTRY.
* Message body and subject
  TRY.
      lo_document = cl_document_bcs=>create_document( i_type    = message_type
                                                      i_text    = message_body
                                                      i_subject = subject ).
    CATCH cx_document_bcs.
      result = ''. RETURN.
  ENDTRY.
*-----------------------------------------------*
*Send attachment
*-----------------------------------------------*
  LOOP AT attachments INTO ls_attachment.
    attachment_subject = ls_attachment-subject.
    attachment_size    =  ls_attachment-docsize.
    TRY.
        lo_document->add_attachment(
          EXPORTING i_attachment_type    = ls_attachment-objtp
                    i_attachment_subject = attachment_subject
                    i_attachment_size    = attachment_size
                    i_att_content_hex    = ls_attachment-cont_hex ).
      CATCH cx_document_bcs.
        result = ''. RETURN.
    ENDTRY.
  ENDLOOP.
*-----------------------------------------------*
* Pass the document to send request
*-----------------------------------------------*
  TRY.
      lo_send_request->set_document( lo_document ).
    CATCH cx_send_req_bcs.
      result = ''. RETURN.
  ENDTRY.
*-----------------------------------------------*
* Set sender
*-----------------------------------------------*
  TRY.
      IF sender_mail IS NOT INITIAL.
        lo_sender = cl_cam_address_bcs=>create_internet_address( sender_mail ).
      ELSEIF sender_uid IS NOT INITIAL.
        lo_sender = cl_sapuser_bcs=>create( sender_uid ).
      ELSE.
        lo_sender = cl_sapuser_bcs=>create( sy-uname ).
      ENDIF.
    CATCH: cx_address_bcs, cx_send_req_bcs ##NO_HANDLER.
      result = ''. RETURN.
  ENDTRY.
  TRY.
      lo_send_request->set_sender( EXPORTING i_sender = lo_sender ).
    CATCH: cx_address_bcs, cx_send_req_bcs ##NO_HANDLER.
      result = ''. RETURN.
  ENDTRY.
*-----------------------------------------------*
* Set recipients
*-----------------------------------------------*
  IF recipients[] IS INITIAL.
    TRY.
        IF recipient_mail IS NOT INITIAL.
          lo_recipient = cl_cam_address_bcs=>create_internet_address( recipient_mail ).
        ELSEIF recipient_uid IS NOT INITIAL.
          lo_recipient = cl_sapuser_bcs=>create( recipient_uid ).
        ELSE.
          lo_recipient = cl_sapuser_bcs=>create( sy-uname ).
        ENDIF.
      CATCH cx_address_bcs.
        result = ''. RETURN.
    ENDTRY.
    TRY.
        lo_send_request->add_recipient( EXPORTING i_recipient = lo_recipient
                                                  i_express = 'X' ).
      CATCH cx_send_req_bcs.
        result = ''. RETURN.
    ENDTRY.
  ELSE.
    LOOP AT recipients INTO ls_recipient.
      TRY.
          IF ls_recipient-email IS NOT INITIAL.
            lv_recipient_mail = ls_recipient-email .
            lo_recipient = cl_cam_address_bcs=>create_internet_address( lv_recipient_mail ).
          ELSEIF ls_recipient-iusrid IS NOT INITIAL.
            lv_recipient_uid = ls_recipient-iusrid.
            lo_recipient = cl_sapuser_bcs=>create( lv_recipient_uid ).
          ELSE.
            lo_recipient = cl_sapuser_bcs=>create( sy-uname ).
          ENDIF.
        CATCH cx_address_bcs.
          result = ''. RETURN.
      ENDTRY.
      TRY.
          lo_send_request->add_recipient( EXPORTING i_recipient = lo_recipient
                                                    i_express   = 'X' ).

        CATCH cx_send_req_bcs.
          result = ''. RETURN.
      ENDTRY.
    ENDLOOP.
  ENDIF.
*-----------------------------------------------*
* Set CC recipient
*-----------------------------------------------*
  IF recipients_cc[] IS NOT INITIAL.
    LOOP AT recipients_cc INTO ls_recipient.
      TRY.
          IF ls_recipient-email IS NOT INITIAL.
            lv_recipient_mail = ls_recipient-email .
            lo_recipient = cl_cam_address_bcs=>create_internet_address( lv_recipient_mail ).
          ELSEIF ls_recipient-iusrid IS NOT INITIAL.
            lv_recipient_uid = ls_recipient-iusrid.
            lo_recipient = cl_sapuser_bcs=>create( lv_recipient_uid ).
          ELSE.
            lo_recipient = cl_sapuser_bcs=>create( sy-uname ).
          ENDIF.
        CATCH cx_address_bcs.
          result = ''. RETURN.
      ENDTRY.
      TRY.
          lo_send_request->add_recipient( EXPORTING i_recipient  = lo_recipient
                                                    i_express    = 'X'
                                                    i_blind_copy = 'X' ).
        CATCH cx_send_req_bcs.
          result = ''. RETURN.
      ENDTRY.
    ENDLOOP.
  ENDIF.
*-----------------------------------------------*
* Set BCC recipient
*-----------------------------------------------*
  IF recipient_bcc IS NOT INITIAL.
    TRY.
        lo_recipient = cl_cam_address_bcs=>create_internet_address( recipient_bcc ).
      CATCH cx_address_bcs.
    ENDTRY.
    TRY.
        lo_send_request->add_recipient( EXPORTING i_recipient  = lo_recipient
                                                  i_express    = 'X'
                                                  i_blind_copy = 'X' ).
      CATCH cx_send_req_bcs.
        result = ''. RETURN.
    ENDTRY.
  ENDIF.
*-----------------------------------------------*
* Send email
*-----------------------------------------------*
  TRY.
      lo_send_request->send( EXPORTING i_with_error_screen = 'X'
                             RECEIVING result = result ).
      IF commit EQ abap_true.
        COMMIT WORK.
      ENDIF.

      WAIT UP TO 1 SECONDS.
* SUBMIT rsconn01 WITH mode = 'INT' AND RETURN. "sost'a girmeden otomatik olarak göndermek için.
    CATCH cx_send_req_bcs INTO lo_ctx.

      lv_msg =  lo_ctx->if_message~get_text( ).

      result = ''. RETURN.
  ENDTRY.



ENDFUNCTION.
