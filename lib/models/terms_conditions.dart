class TermsConditionsModel {
  final String termId;
  final String termHeader;
  final String termDescription;

  TermsConditionsModel({
    required this.termId,
    required this.termHeader,
    required this.termDescription,
  });

  factory TermsConditionsModel.fromJson(Map<String, dynamic> json) {
    return TermsConditionsModel(
      termId: json['term_id'] ?? '',
      termHeader: json['term_header'] ?? '',
      termDescription: json['term_description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'term_id': termId,
      'term_header': termHeader,
      'term_description': termDescription,
    };
  }
}
