*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZEGT_EO_T002....................................*
DATA:  BEGIN OF STATUS_ZEGT_EO_T002                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZEGT_EO_T002                  .
CONTROLS: TCTRL_ZEGT_EO_T002
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZEO_CT_MAIL.....................................*
DATA:  BEGIN OF STATUS_ZEO_CT_MAIL                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZEO_CT_MAIL                   .
CONTROLS: TCTRL_ZEO_CT_MAIL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZEGT_EO_T002                  .
TABLES: *ZEO_CT_MAIL                   .
TABLES: ZEGT_EO_T002                   .
TABLES: ZEO_CT_MAIL                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
