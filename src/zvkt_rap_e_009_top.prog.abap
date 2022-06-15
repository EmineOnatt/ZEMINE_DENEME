*&---------------------------------------------------------------------*
*& Include          ZVKT_RAP_E_009_TOP
*&---------------------------------------------------------------------*
CLASS lcl_mail DEFINITION DEFERRED.

TABLES sscrfields.

DATA: go_obj TYPE REF TO lcl_mail.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_sender       TYPE string,
            p_recp         TYPE ad_smtpadr,
            p_subj         TYPE string,
            p_mess         TYPE string.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN SKIP.

SELECTION-SCREEN PUSHBUTTON 20(30) gv_exclb USER-COMMAND uc1.


SELECTION-SCREEN: END OF BLOCK b1.
