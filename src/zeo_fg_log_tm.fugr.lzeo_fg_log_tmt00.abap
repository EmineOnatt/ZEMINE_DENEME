*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVKT_EO_T004....................................*
DATA:  BEGIN OF STATUS_ZVKT_EO_T004                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZVKT_EO_T004                  .
CONTROLS: TCTRL_ZVKT_EO_T004
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZVKT_EO_T004                  .
TABLES: ZVKT_EO_T004                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
