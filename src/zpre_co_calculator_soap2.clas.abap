class ZPRE_CO_CALCULATOR_SOAP2 definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods ADD
    importing
      !INPUT type ZPRE_ADD_SOAP_IN2
    exporting
      !OUTPUT type ZPRE_ADD_SOAP_OUT2
    raising
      CX_AI_SYSTEM_FAULT .
  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods DIVIDE
    importing
      !INPUT type ZPRE_DIVIDE_SOAP_IN2
    exporting
      !OUTPUT type ZPRE_DIVIDE_SOAP_OUT2
    raising
      CX_AI_SYSTEM_FAULT .
  methods MULTIPLY
    importing
      !INPUT type ZPRE_MULTIPLY_SOAP_IN2
    exporting
      !OUTPUT type ZPRE_MULTIPLY_SOAP_OUT2
    raising
      CX_AI_SYSTEM_FAULT .
  methods SUBTRACT
    importing
      !INPUT type ZPRE_SUBTRACT_SOAP_IN2
    exporting
      !OUTPUT type ZPRE_SUBTRACT_SOAP_OUT2
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZPRE_CO_CALCULATOR_SOAP2 IMPLEMENTATION.


  method ADD.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'ADD'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZPRE_CO_CALCULATOR_SOAP2'
    logical_port_name   = logical_port_name
  ).

  endmethod.


  method DIVIDE.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'DIVIDE'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method MULTIPLY.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'MULTIPLY'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SUBTRACT.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SUBTRACT'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
