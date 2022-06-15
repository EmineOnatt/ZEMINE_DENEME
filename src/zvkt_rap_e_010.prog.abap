*&---------------------------------------------------------------------*
*& Report ZVKT_RAP_E_010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZVKT_RAP_E_010.


CONSTANTS:
    gc_subject TYPE so_obj_des VALUE 'DENEME',
    gc_raw     TYPE char03 VALUE 'RAW'.

  DATA:
    gv_mlrec         TYPE so_obj_nam,
    gv_sent_to_all   TYPE os_boolean,
    gv_email         TYPE adr6-smtp_addr,
    gv_subject       TYPE so_obj_des,
    gv_text          TYPE bcsy_text,
    gr_send_request  TYPE REF TO cl_bcs,
    gr_bcs_exception TYPE REF TO cx_bcs,
    gr_recipient     TYPE REF TO if_recipient_bcs,
    gr_sender        TYPE REF TO cl_sapuser_bcs,
    gr_document      TYPE REF TO cl_document_bcs.



  TRY.
      "Create send request
      gr_send_request = cl_bcs=>create_persistent( ).


      "Email FROM...
      gr_sender = cl_sapuser_bcs=>create( sy-uname ).
      "Add sender to send request
      CALL METHOD gr_send_request->set_sender
        EXPORTING
          i_sender = gr_sender.


      "Email TO...
      gv_email = 'emine.onat@vektora.com'.
      gr_recipient = cl_cam_address_bcs=>create_internet_address( gv_email ).
      "Add recipient to send request
      CALL METHOD gr_send_request->add_recipient
        EXPORTING
          i_recipient = gr_recipient
          i_express   = 'X'.


      "Email BODY
      APPEND 'MAIL DENEMEEEE!' TO gv_text.
      gr_document = cl_document_bcs=>create_document(
                      i_type    = gc_raw
                      i_text    = gv_text
                      i_length  = '12'
                      i_subject = gc_subject ).
      "Add document to send request
      CALL METHOD gr_send_request->set_document( gr_document ).


      "Send email
      CALL METHOD gr_send_request->send(
        EXPORTING
          i_with_error_screen = 'X'
        RECEIVING
          result              = gv_sent_to_all ).
      IF gv_sent_to_all = 'X'.
        WRITE 'Email sent!'.
      ENDIF.

      "Commit to send email
      COMMIT WORK.


      "Exception handling
    CATCH cx_bcs INTO gr_bcs_exception.
      WRITE:
        'Error!',
        'Error type:',
        gr_bcs_exception->error_type.
  ENDTRY.

*
* DATA:    gv_sender          TYPE uname,
*          gv_recipient_email TYPE ad_smtpadr,
*          gv_subject         TYPE string,
*          gv_message         TYPE string.
*
* gv_sender = 'EGT_EMINE'.
* gv_recipient_email = 'emine.onat@vektora.com'.
* gv_subject = 'DENEME'.
* gv_message = 'DENEME MESAJIII'.
*
*  DATA(it_body_txt) = cl_document_bcs=>string_to_soli( ip_string = gv_message ).
*
*    TRY.
*
*        "create document email
*        DATA(o_document) = cl_document_bcs=>create_document( i_type = 'RAW'
*                                                             i_text = it_body_txt
*                                                             i_subject = CONV so_obj_des( gv_subject )   ).
*
*        "create send request
*        DATA(o_send_request) = cl_bcs=>create_persistent( ).
*        o_send_request->set_message_subject( ip_subject = gv_subject ).
*        o_send_request->set_document( o_document ).
*
*
*        "-SAP_USER request
*        DATA(o_sender) = cl_sapuser_bcs=>create( gv_sender ).
*        o_send_request->set_sender( o_sender ).
*
*
*        "set recipient
*        DATA(o_recipient) = cl_cam_address_bcs=>create_internet_address( gv_recipient_email ).
*        o_send_request->add_recipient( i_recipient = o_recipient
*                                       i_express = abap_true ).
*
*        o_send_request->set_send_immediately( abap_true ).
*
*        "sent document mail
*        o_send_request->send( i_with_error_screen = abap_true ).
*        COMMIT WORK.
*
*        IF sy-subrc = 0.
*          WRITE: / 'Email gönderildi! '.
*
*        ENDIF.
*
*      CATCH cx_root INTO DATA(e_text).
*
*    ENDTRY.
