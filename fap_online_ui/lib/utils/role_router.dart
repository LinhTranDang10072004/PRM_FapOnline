class RoleRouter {
  static String normalize(String? role) {
    if (role == null) return '';
    var value = role.trim().toUpperCase();
    if (value.startsWith('ROLE_')) {
      value = value.substring(5);
    }
    return value;
  }

  /// Returns named route for the signed-in role.
  static String shellRouteFor(String? role) {
    switch (normalize(role)) {
      case 'ADMIN':
        return '/admin-shell';
      case 'STAFF':
        return '/staff-shell';
      case 'TEACHER':
        return '/teacher-shell';
      case 'STUDENT':
        return '/student-shell';
      case 'PARENT':
        return '/parent-shell';
      default:
        return '/login';
    }
  }
}
