*&---------------------------------------------------------------------*
*& Report ZVKT_RAP_E_012
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZVKT_RAP_E_012.

DATA : LR_PROXY TYPE REF TO ZPRE_CO_CALCULATOR_SOAP2,
       INPUT    TYPE ZPRE_ADD_SOAP_IN2,
       OUTPUT   TYPE ZPRE_ADD_SOAP_OUT2.



INPUT-INT_A = 10.
INPUT-INT_B = 5.


"""Portu tanımladığımız yer

CREATE OBJECT LR_PROXY
  EXPORTING
    LOGICAL_PORT_NAME = 'ZPORT_EO_CALC'.

CALL METHOD LR_PROXY->ADD
  EXPORTING
    INPUT  = INPUT
  IMPORTING
    OUTPUT = OUTPUT.

DATA(LV_ADD) = 'ADD METHOD => ' && OUTPUT-ADD_RESULT.


TRY.
CLEAR OUTPUT.
CALL METHOD LR_PROXY->DIVIDE
  EXPORTING
    INPUT              = INPUT
  IMPORTING
    OUTPUT             = OUTPUT.
  catch CX_AI_SYSTEM_FAULT.    "
ENDTRY.

DATA(LV_DIVIDE) = 'DIVIDE METHOD => ' && OUTPUT-ADD_RESULT.


CALL METHOD LR_PROXY->SUBTRACT
  EXPORTING
    INPUT              = INPUT
  IMPORTING
    OUTPUT             = OUTPUT.

DATA(LV_SUBSTRACT) = 'SUBTRACT METHOD => ' && OUTPUT-ADD_RESULT.

CLEAR OUTPUT.
CALL METHOD LR_PROXY->MULTIPLY
  EXPORTING
    INPUT              = INPUT
  IMPORTING
    OUTPUT             = OUTPUT.

DATA(LV_MULTIPLY) = 'MULTIPLY METHOD => ' && OUTPUT-ADD_RESULT.

DATA(NUMBERS) = 'Sayılarımız :(' && INPUT-INT_A && ')  (' && INPUT-INT_B && ')'.
WRITE /: NUMBERS.
WRITE /: LV_ADD.
WRITE /: LV_DIVIDE.
WRITE /: LV_SUBSTRACT.
WRITE /: LV_MULTIPLY.
