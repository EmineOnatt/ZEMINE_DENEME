*&---------------------------------------------------------------------*
*& Include          ZVKT_RAP_E_011_TOP
*&---------------------------------------------------------------------*
CLASS lcl_odev DEFINITION DEFERRED.

TABLES: vbak.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_vbeln FOR vbak-vbeln.
SELECTION-SCREEN: END OF BLOCK b1.


DATA: gt_outtable    TYPE TABLE OF zvkt_eo_s002,
      gt_excelout    TYPE TABLE OF zvkt_eo_s002,
      gt_znot        TYPE TABLE OF zvkt_eo_t002,
      gs_znot        TYPE  zvkt_eo_t002,
      gs_outtable    LIKE LINE OF gt_outtable,
      gt_outpoptable TYPE TABLE OF zvkt_eo_s003,
      gs_outpoptable LIKE LINE OF gt_outpoptable.

DATA: go_oo_alv TYPE REF TO lcl_odev.

""-------------------
"ADOBE PARAMETRELERİ

DATA: fm_name         TYPE rs38l_fnam,
      fp_docparams    TYPE sfpdocparams,
      fp_outputparams TYPE sfpoutputparams.

DATA gs_pdf TYPE fpformoutput.

DATA: gs_header TYPE zvkt_eo_s002,
      gt_items  TYPE zvkt_eo_s002_t.


DATA gv_vbeln TYPE vbeln_va.

TYPES: BEGIN OF ty_mod,
         row TYPE i,
       END OF ty_mod.

DATA : gt_mod TYPE STANDARD TABLE OF ty_mod.
