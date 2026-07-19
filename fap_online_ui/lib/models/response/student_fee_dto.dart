class StudentFeeDTO {
  final int studentFeeId;
  final String feeTypeName;
  final double amount;
  final double paidAmount;
  final double remainingAmount;
  final String dueDate;
  final String status;
  final String semesterName;

  StudentFeeDTO({
    required this.studentFeeId,
    required this.feeTypeName,
    required this.amount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.dueDate,
    required this.status,
    required this.semesterName,
  });

  factory StudentFeeDTO.fromJson(Map<String, dynamic> json) {
    return StudentFeeDTO(
      studentFeeId: json['studentFeeId'] ?? 0,
      feeTypeName: json['feeTypeName'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      remainingAmount: (json['remainingAmount'] ?? 0).toDouble(),
      dueDate: json['dueDate'] ?? '',
      status: json['status'] ?? 'UNPAID',
      semesterName: json['semesterName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentFeeId': studentFeeId,
      'feeTypeName': feeTypeName,
      'amount': amount,
      'paidAmount': paidAmount,
      'remainingAmount': remainingAmount,
      'dueDate': dueDate,
      'status': status,
      'semesterName': semesterName,
    };
  }
}
