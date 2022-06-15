*&---------------------------------------------------------------------*
*& Include          ZVKT_RAP_0064_TOP
*&---------------------------------------------------------------------*
CLASS lcl_report DEFINITION DEFERRED.

* PARAMETERS: p_vbeln TYPE vbeln_va.

TABLES: vbak, vbap.

DATA: go_report  TYPE REF TO lcl_report,
      gv_tabname TYPE tabname,
      gt_output  TYPE TABLE OF zzy_s0006,
      gs_output  LIKE LINE  OF gt_output,
      gt_return	 TYPE bapirettab,
      gs_return  TYPE bapiret2,
      gv_error   TYPE char1.

"Adobe Tanımlamaları
DATA: fm_name         TYPE rs38l_fnam,
      fp_docparams    TYPE sfpdocparams,
      fp_outputparams TYPE sfpoutputparams.

"Adobe import parametreleri
DATA: gs_header TYPE zzy_s0006,
      "Colom toplam değer
      gv_toplam TYPE netwr_ap,
      gt_items  TYPE zzy_s0007_t.

CONSTANTS: gc_output  TYPE tabname VALUE 'ZZY_S0006'.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001. "Seçim Parametreleri
SELECT-OPTIONS:   s_vbeln   FOR vbak-vbeln.
SELECTION-SCREEN SKIP.

SELECTION-SCREEN END OF BLOCK b1.
