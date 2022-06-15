*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZEO_FG_LOG_TM
*   generation date: 12.04.2022 at 16:31:49
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZEO_FG_LOG_TM      .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
