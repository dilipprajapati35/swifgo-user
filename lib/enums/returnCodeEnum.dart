enum ReturnCodes {
  R_SUCCESS,
  R_DB_ERROR,
  R_NOT_FOUND,
  R_AUTHENTICATION_FAILED,
  R_DUPLICATE_DATA,
  R_UNAUTHORIZED,
  R_CREATED,
  R_INVALID_VALUE,
  R_ALREADY_EXIST,
  R_PROMOTION_TYPE,
  R_STARTDATE,
  R_INVALID_PASSWORD,
}

extension ReturnCodesExtension on ReturnCodes {
  int get value {
    switch (this) {
      case ReturnCodes.R_SUCCESS:
        return 0;
      case ReturnCodes.R_DB_ERROR:
        return 1;
      case ReturnCodes.R_NOT_FOUND:
        return 2;
      case ReturnCodes.R_AUTHENTICATION_FAILED:
        return 3;
      case ReturnCodes.R_DUPLICATE_DATA:
        return 4;
      case ReturnCodes.R_UNAUTHORIZED:
        return 5;
      case ReturnCodes.R_CREATED:
        return 6;
      case ReturnCodes.R_INVALID_VALUE:
        return 7;
      case ReturnCodes.R_ALREADY_EXIST:
        return 8;
      case ReturnCodes.R_PROMOTION_TYPE:
        return 9;
      case ReturnCodes.R_STARTDATE:
        return 10;
      case ReturnCodes.R_INVALID_PASSWORD:
        return 11;
    }
  }
}