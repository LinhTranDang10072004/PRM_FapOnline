class AdminDashboardModel {
  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;
  final int totalSubjects;

  const AdminDashboardModel({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClasses,
    required this.totalSubjects,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      totalStudents: _asInt(json['totalStudents']),
      totalTeachers: _asInt(json['totalTeachers']),
      totalClasses: _asInt(json['totalClasses']),
      totalSubjects: _asInt(json['totalSubjects']),
    );
  }
}

class AdminUserModel {
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final String? phone;
  final String? gender;
  final String? address;
  final String status;
  final List<String> roles;
  final String? primaryRole;

  const AdminUserModel({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    this.phone,
    this.gender,
    this.address,
    required this.status,
    required this.roles,
    this.primaryRole,
  });

  bool get isLocked => status.toLowerCase() == 'locked';

  String get roleLabel => primaryRole ?? (roles.isNotEmpty ? roles.first : '—');

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['roles'];
    final roles = rolesRaw is List
        ? rolesRaw.map((e) => e.toString()).toList()
        : <String>[];
    return AdminUserModel(
      userId: _asInt(json['userId']),
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
      status: json['status']?.toString() ?? 'Active',
      roles: roles,
      primaryRole: json['primaryRole']?.toString(),
    );
  }
}

class AdminUserCreateRequest {
  final String username;
  final String password;
  final String fullName;
  final String email;
  final String? phone;
  final String? gender;
  final String? address;
  final String roleName;
  final String? profileCode;

  const AdminUserCreateRequest({
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    this.phone,
    this.gender,
    this.address,
    required this.roleName,
    this.profileCode,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'fullName': fullName,
        'email': email,
        if (phone != null && phone!.isNotEmpty) 'phone': phone,
        if (gender != null && gender!.isNotEmpty) 'gender': gender,
        if (address != null && address!.isNotEmpty) 'address': address,
        'roleName': roleName,
        if (profileCode != null && profileCode!.isNotEmpty)
          'profileCode': profileCode,
      };
}

class AdminUserUpdateRequest {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? gender;
  final String? address;
  final String? password;
  final String? roleName;

  const AdminUserUpdateRequest({
    this.fullName,
    this.email,
    this.phone,
    this.gender,
    this.address,
    this.password,
    this.roleName,
  });

  Map<String, dynamic> toJson() => {
        if (fullName != null) 'fullName': fullName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (gender != null) 'gender': gender,
        if (address != null) 'address': address,
        if (password != null && password!.isNotEmpty) 'password': password,
        if (roleName != null) 'roleName': roleName,
      };
}

class AdminRoleModel {
  final int roleId;
  final String roleName;
  final String? description;
  final bool isActive;
  final int userCount;

  const AdminRoleModel({
    required this.roleId,
    required this.roleName,
    this.description,
    required this.isActive,
    required this.userCount,
  });

  factory AdminRoleModel.fromJson(Map<String, dynamic> json) {
    return AdminRoleModel(
      roleId: _asInt(json['roleId']),
      roleName: json['roleName']?.toString() ?? '',
      description: json['description']?.toString(),
      isActive: json['isActive'] == true ||
          json['isActive']?.toString().toLowerCase() == 'true',
      userCount: _asInt(json['userCount']),
    );
  }
}

class AdminRoleRequest {
  final String roleName;
  final String? description;
  final bool? isActive;

  const AdminRoleRequest({
    required this.roleName,
    this.description,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        'roleName': roleName,
        if (description != null) 'description': description,
        if (isActive != null) 'isActive': isActive,
      };
}

class AssignRoleRequest {
  final int userId;
  final int roleId;

  const AssignRoleRequest({required this.userId, required this.roleId});

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'roleId': roleId,
      };
}

class AdminProfileModel {
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final String? phone;
  final String? gender;
  final String? address;
  final String? avatarUrl;
  final String status;
  final List<String> roles;

  const AdminProfileModel({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    this.phone,
    this.gender,
    this.address,
    this.avatarUrl,
    required this.status,
    required this.roles,
  });

  factory AdminProfileModel.fromJson(Map<String, dynamic> json) {
    final rolesRaw = json['roles'];
    final roles = rolesRaw is List
        ? rolesRaw.map((e) => e.toString()).toList()
        : <String>[];
    return AdminProfileModel(
      userId: _asInt(json['userId']),
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      status: json['status']?.toString() ?? 'Active',
      roles: roles,
    );
  }
}

class AdminProfileUpdateRequest {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? gender;
  final String? address;

  const AdminProfileUpdateRequest({
    this.fullName,
    this.email,
    this.phone,
    this.gender,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        if (fullName != null) 'fullName': fullName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (gender != null) 'gender': gender,
        if (address != null) 'address': address,
      };
}

class AdminChangePasswordRequest {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const AdminChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      };
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
