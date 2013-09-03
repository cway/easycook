#encoding: utf-8
#author andy 2013-08-20

class Constant

#HTTP_STATUS
  HTTP_REQUEST_SUCCESS  =   200

  HTTP_CREATE_SUCCESS   =   201

  HTTP_REQUEST_ERROR    =   400

  HTTP_NOT_FOUND        =   404

  HTTP_SERVER_ERROR     =   500

  HTTP_BAD_GATEWAY      =   502

  HTTP_CONFLICT         =   409

  HTTP_FORBIDDEN        =   403

#params value
  DATA_SIZE_HEAVY       =   2

  DATA_SIZE_LIGHT       =   1

  PARAM_VALUE_LIMIT     =   10

  PARAM_VALUE_LIMIT_MAX =   50
#params name
  PARAM_NAME_SINCE      =   "since"

  PARAM_NAME_MAX        =   "max"

  PARAM_NAME_DATA_SIZE  =   "data_size"

  PARAM_NAME_LIMIT      =   "limit"
end