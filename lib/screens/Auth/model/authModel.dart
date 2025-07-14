class AuthModel {
  final DataResponse dataResponse;
  final AuthData data;

  AuthModel({
    required this.dataResponse,
    required this.data,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      dataResponse: DataResponse.fromJson(json['dataResponse']),
      data: AuthData.fromJson(json['data']),
    );
  }
}

class DataResponse {
  final int returnCode;
  final DateTime responseDateTime;
  final String description;

  DataResponse({
    required this.returnCode,
    required this.responseDateTime,
    required this.description,
  });

  factory DataResponse.fromJson(Map<String, dynamic> json) {
    return DataResponse(
      returnCode: json['returnCode'],
      responseDateTime: DateTime.parse(json['responseDateTime']),
      description: json['description'],
    );
  }
}

class AuthData {
  final NewUser newUser;
  final NewUserDetails newUserDetails;

  AuthData({
    required this.newUser,
    required this.newUserDetails,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      newUser: NewUser.fromJson(json['newUser']),
      newUserDetails: NewUserDetails.fromJson(json['newUserDetails']),
    );
  }
}

class NewUser {
  final int userType;
  final int isMaster;
  final DateTime createdOn;
  final int isDeleted;
  final int id;
  final String fullName;
  final int roleId;
  final String emailId;
  final String mobileNumber;
  final String password;

  NewUser({
    required this.userType,
    required this.isMaster,
    required this.createdOn,
    required this.isDeleted,
    required this.id,
    required this.fullName,
    required this.roleId,
    required this.emailId,
    required this.mobileNumber,
    required this.password,
  });

  factory NewUser.fromJson(Map<String, dynamic> json) {
    return NewUser(
      userType: json['userType'],
      isMaster: json['isMaster'],
      createdOn: DateTime.parse(json['createdOn']),
      isDeleted: json['isDeleted'],
      id: json['id'],
      fullName: json['fullName'],
      roleId: json['roleId'],
      emailId: json['emailId'],
      mobileNumber: json['mobileNumber'],
      password: json['password'],
    );
  }
}

class NewUserDetails {
  final DateTime createdOn;
  final int isDeleted;
  final int id;
  final int userId;
  final String fullName;
  final String emailId;
  final String mobileNumber;

  NewUserDetails({
    required this.createdOn,
    required this.isDeleted,
    required this.id,
    required this.userId,
    required this.fullName,
    required this.emailId,
    required this.mobileNumber,
  });

  factory NewUserDetails.fromJson(Map<String, dynamic> json) {
    return NewUserDetails(
      createdOn: DateTime.parse(json['createdOn']),
      isDeleted: json['isDeleted'],
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'],
      emailId: json['emailId'],
      mobileNumber: json['mobileNumber'],
    );
  }
}


class AuthToken {
  final String token;

  AuthToken({required this.token});

  factory AuthToken.fromJson(dynamic json) {
    return AuthToken(token: json as String);
  }
}
