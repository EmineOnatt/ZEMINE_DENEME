*&---------------------------------------------------------------------*
*& Include          ZVKT_RAP_E_013_TOP
*&---------------------------------------------------------------------*
CLASS cl_event DEFINITION DEFERRED.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS: r_basvr RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND u1,
            r_yonet RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS: p_user  TYPE char30 MODIF ID us OBLIGATORY MATCHCODE OBJECT ZVKT_RAP_E_013_SH,
            p_passw TYPE char30 MODIF ID us OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b2.


DATA: gt_cellstyle TYPE lvc_t_styl.
DATA: gs_cellstyle TYPE lvc_s_styl.

DATA: "gt_data TYPE TABLE OF zvkt_eo_t003,
      gs_data TYPE zvkt_eo_s005."zvkt_eo_t003.

DATA: gt_kullanici TYPE TABLE OF zvkt_eo_t004,
      gs_kullanici TYPE zvkt_eo_t004.

DATA: gv_user TYPE char30,
      gv_pw   TYPE char30.

DATA: gt_fcat   TYPE lvc_t_fcat, "stnd.
      gs_fcat   TYPE lvc_s_fcat, "stnd.
      gs_layout TYPE lvc_s_layo.


DATA: gt_table TYPE TABLE OF zvkt_eo_s005, "zvkt_eo_t003,
      go_alv   TYPE REF TO cl_gui_alv_grid,
      go_cust  TYPE REF TO cl_gui_custom_container..

DATA : gv_flag TYPE xfeld VALUE 'X'.

DATA: go_event TYPE REF TO cl_event.

FIELD-SYMBOLS <gfs_table> TYPE zvkt_eo_t003.
