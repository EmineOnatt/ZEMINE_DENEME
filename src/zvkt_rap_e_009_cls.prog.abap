*&---------------------------------------------------------------------*
*& Include          ZVKT_RAP_E_009_CLS
*&---------------------------------------------------------------------*

CLASS lcl_mail DEFINITION.
  PUBLIC SECTION.

    METHODS: set_kaydet_button,
      get_data,
      mail.

    DATA: gv_sender          TYPE uname,
          gv_recipient_email TYPE ad_smtpadr,
*          gv_subject         TYPE string,
          gv_message         TYPE string.

    DATA:
      gv_mlrec         TYPE so_obj_nam,
      gv_sent_to_all   TYPE os_boolean,
      gv_email         TYPE adr6-smtp_addr,
      gv_mail          TYPE adr6-smtp_addr,
      gv_subject       TYPE so_obj_des,
      gv_text          TYPE bcsy_text,
      gr_send          TYPE REF TO cl_bcs,
      gr_bcs_exception TYPE REF TO cx_bcs,
      gr_recipient     TYPE REF TO if_recipient_bcs,
      it_content       TYPE STANDARD TABLE OF soli,
*      gr_sender        TYPE REF TO cl_sapuser_bcs, "if_recipient_bcs,"
      gr_sender        TYPE REF TO if_sender_bcs,
      gr_document      TYPE REF TO cl_document_bcs.



ENDCLASS.

CLASS lcl_mail IMPLEMENTATION.

  METHOD set_kaydet_button.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        name   = icon_okay
        text   = TEXT-002
        info   = TEXT-002
      IMPORTING
        result = gv_exclb
      EXCEPTIONS
        OTHERS = 0.
  ENDMETHOD.

  METHOD get_data.

*    gv_sender = p_sender.
    gv_email = p_recp.
    gv_subject = p_subj.
*    gv_message = p_mess.


  ENDMETHOD.

  METHOD mail.
    go_obj->get_data( ).


    CONSTANTS:
      gc_subject TYPE so_obj_des VALUE 'BASLIK',
      gc_raw     TYPE char03 VALUE 'RAW'.

    TRY.
        "Create send request
        gr_send = cl_bcs=>create_persistent( ).

        IF p_sender IS NOT INITIAL.
          gv_mail = p_sender.
          gr_sender = cl_cam_address_bcs=>create_internet_address(
                i_address_string = gv_mail
                i_address_name = gv_mail ).
          CALL METHOD gr_send->set_sender
            EXPORTING
              i_sender = gr_sender.
        ELSE.
          gr_sender = cl_sapuser_bcs=>create( sy-uname ).
          CALL METHOD gr_send->set_sender
            EXPORTING
              i_sender = gr_sender.
        ENDIF.
        " gv_mail = p_sender.
        "Email FROM...
*        gr_sender = cl_sapuser_bcs=>create( sy-ucomm ).
**              CATCH cx_address_bcs.  " ( sy-ucomm ).
*        "gr_sender = cl_cam_address_bcs=>create_internet_address( gv_mail ).
*        "Add sender to send request
*        CALL METHOD gr_send->set_sender
*          EXPORTING
*            i_sender = gr_sender.
        "  i_express   = 'X'.

        "Email Gönderilen
*        gv_email = p_recp.
        gr_recipient = cl_cam_address_bcs=>create_internet_address( gv_email ).
        "Add recipient to send request
        CALL METHOD gr_send->add_recipient
          EXPORTING
            i_recipient = gr_recipient
            i_express   = 'X'.


       " Email BODY
       " APPEND 'MAIL DENEMEEEE!' TO gv_text.
        APPEND p_mess TO gv_text.

        gr_document = cl_document_bcs=>create_document(
                      i_type    = 'HTM'
                      i_subject = gv_subject
                      i_text    = gv_text ).
        CALL METHOD gr_send->set_document( gr_document ).


        "Send email
        CALL METHOD gr_send->send(
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

*    DATA(it_body_txt) = cl_document_bcs=>string_to_soli( ip_string = gv_message ).

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
*


  ENDMETHOD.

ENDCLASS.
