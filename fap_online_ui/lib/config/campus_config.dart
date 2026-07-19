/// Config campus phía Frontend (chưa gắn backend).
/// Sau này có thể đổi sang gọi API GET /api/campuses.
class CampusInfo {
  final String code;
  final String name;
  final String city;

  const CampusInfo({
    required this.code,
    required this.name,
    required this.city,
  });
}

class CampusConfig {
  CampusConfig._();

  static const List<CampusInfo> campuses = [
    CampusInfo(code: 'HN', name: 'FPT University Hà Nội', city: 'Hà Nội'),
    CampusInfo(code: 'HCM', name: 'FPT University TP.HCM', city: 'TP. Hồ Chí Minh'),
    CampusInfo(code: 'DN', name: 'FPT University Đà Nẵng', city: 'Đà Nẵng'),
    CampusInfo(code: 'CT', name: 'FPT University Cần Thơ', city: 'Cần Thơ'),
    CampusInfo(code: 'QN', name: 'FPT University Quy Nhơn', city: 'Quy Nhơn'),
  ];

  static CampusInfo? findByCode(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final campus in campuses) {
      if (campus.code == code) return campus;
    }
    return null;
  }
}
