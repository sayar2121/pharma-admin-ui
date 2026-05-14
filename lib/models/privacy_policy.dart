class PrivacyPolicyModel {
  final String privacyId;
  final String privacyHeader;
  final String privacyDescription;

  PrivacyPolicyModel({
    required this.privacyId,
    required this.privacyHeader,
    required this.privacyDescription,
  });

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyModel(
      privacyId: json['privacy_id'] ?? '',
      privacyHeader: json['privacy_header'] ?? '',
      privacyDescription: json['privacy_description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'privacy_id': privacyId,
      'privacy_header': privacyHeader,
      'privacy_description': privacyDescription,
    };
  }
}
