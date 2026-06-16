import 'dart:convert';

class User {
  final String? shopId;
  final String shopName;
  final String? shopOwnerName;
  final String shopAddress;
  final String? shopPhoto;
  final String shopPhoneNo;
  final String? shopAlternativePhoneNo;
  final String shopEmail;
  final String shopPassword;
  final String? whatsappNumber;
  final String? gstinNo;
  final String latitude;
  final String longitude;
  final String? gstCertificateUpload;
  final String? drugLicenseNo;
  final String drugLicenseUpload;
  final String? tradeLicenseNo;
  final String? tradeLicenseUpload;
  final String? panCardNo;
  final String panCardUpload;
  final String? aadhaarNo;
  final String? aadhaarCardUpload;
  final String? pharmacistRegNo;
  final String? pharmacistRegUpload;
  final String? businessRegNo;
  final String registrationCertificateUpload;
  final String bankAccountNo;
  final String bankIfscCode;
  final String bankName;
  final String? bankBranchName;
  final String bankAccountName;
  final String? bankDocumentUpload;
  final String? addressProofNo;
  final String? addressProofUpload;
  final String? ownerPhoto;
  final String? status;

  User({
    this.shopId,
    required this.shopName,
    this.shopOwnerName,
    required this.shopAddress,
    this.shopPhoto,
    required this.shopPhoneNo,
    this.shopAlternativePhoneNo,
    required this.shopEmail,
    required this.shopPassword,
    this.whatsappNumber,
    this.gstinNo,
    required this.latitude,
    required this.longitude,
    this.gstCertificateUpload,
    this.drugLicenseNo,
    required this.drugLicenseUpload,
    this.tradeLicenseNo,
    this.tradeLicenseUpload,
    this.panCardNo,
    required this.panCardUpload,
    this.aadhaarNo,
    this.aadhaarCardUpload,
    this.pharmacistRegNo,
    this.pharmacistRegUpload,
    this.businessRegNo,
    required this.registrationCertificateUpload,
    required this.bankAccountNo,
    required this.bankIfscCode,
    required this.bankName,
    this.bankBranchName,
    required this.bankAccountName,
    this.bankDocumentUpload,
    this.addressProofNo,
    this.addressProofUpload,
    this.ownerPhoto,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'shop_id': shopId,
      'shop_name': shopName,
      'shop_owner_name': shopOwnerName,
      'shop_address': shopAddress,
      'shop_photo': shopPhoto,
      'shop_phone_no': shopPhoneNo,
      'shop_alternative_phone_no': shopAlternativePhoneNo,
      'shop_email': shopEmail,
      'shop_password': shopPassword,
      'whatsapp_number': whatsappNumber,
      'gstin_no': gstinNo,
      'latitude': latitude,
      'longitude': longitude,
      'gst_certificate_upload': gstCertificateUpload,
      'drug_license_no': drugLicenseNo,
      'drug_license_upload': drugLicenseUpload,
      'trade_license_no': tradeLicenseNo,
      'trade_license_upload': tradeLicenseUpload,
      'pan_card_no': panCardNo,
      'pan_card_upload': panCardUpload,
      'aadhaar_no': aadhaarNo,
      'aadhaar_card_upload': aadhaarCardUpload,
      'pharmacist_reg_no': pharmacistRegNo,
      'pharmacist_reg_upload': pharmacistRegUpload,
      'business_reg_no': businessRegNo,
      'registration_certificate_upload': registrationCertificateUpload,
      'bank_account_no': bankAccountNo,
      'bank_ifsc_code': bankIfscCode,
      'bank_name': bankName,
      'bank_branch_name': bankBranchName,
      'bank_account_name': bankAccountName,
      'bank_document_upload': bankDocumentUpload,
      'address_proof_no': addressProofNo,
      'address_proof_upload': addressProofUpload,
      'owner_photo': ownerPhoto,
      'status': status,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      shopId: map['shop_id'],
      shopName: map['shop_name'] ?? '',
      shopOwnerName: map['shop_owner_name'],
      shopAddress: map['shop_address'] ?? '',
      shopPhoto: map['shop_photo'],
      shopPhoneNo: map['shop_phone_no'] ?? '',
      shopAlternativePhoneNo: map['shop_alternative_phone_no'],
      shopEmail: map['shop_email'] ?? '',
      shopPassword: map['shop_password'] ?? '',
      whatsappNumber: map['whatsapp_number'],
      gstinNo: map['gstin_no'],
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      gstCertificateUpload: map['gst_certificate_upload'],
      drugLicenseNo: map['drug_license_no'],
      drugLicenseUpload: map['drug_license_upload'] ?? '',
      tradeLicenseNo: map['trade_license_no'],
      tradeLicenseUpload: map['trade_license_upload'],
      panCardNo: map['pan_card_no'],
      panCardUpload: map['pan_card_upload'] ?? '',
      aadhaarNo: map['aadhaar_no'],
      aadhaarCardUpload: map['aadhaar_card_upload'],
      pharmacistRegNo: map['pharmacist_reg_no'],
      pharmacistRegUpload: map['pharmacist_reg_upload'],
      businessRegNo: map['business_reg_no'],
      registrationCertificateUpload: map['registration_certificate_upload'] ?? '',
      bankAccountNo: map['bank_account_no'] ?? '',
      bankIfscCode: map['bank_ifsc_code'] ?? '',
      bankName: map['bank_name'] ?? '',
      bankBranchName: map['bank_branch_name'],
      bankAccountName: map['bank_account_name'] ?? '',
      bankDocumentUpload: map['bank_document_upload'],
      addressProofNo: map['address_proof_no'],
      addressProofUpload: map['address_proof_upload'],
      ownerPhoto: map['owner_photo'],
      status: map['status'],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
