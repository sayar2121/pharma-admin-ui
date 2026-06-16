import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/app_bar.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/user.dart';
import '../../services/api_url.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() =>
      _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  bool _isEditing = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _altPhoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _whatsappController;
  late TextEditingController _gstinController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _drugLicenseController;
  late TextEditingController _panCardController;
  late TextEditingController _bankAccountNoController;
  late TextEditingController _bankIfscCodeController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankAccountNameController;
  late TextEditingController _regCertController;
  late TextEditingController _shopPhotoController;
  late TextEditingController _ownerPhotoController;
  late TextEditingController _gstCertificateController;
  late TextEditingController _drugLicenseNoController;
  late TextEditingController _tradeLicenseNoController;
  late TextEditingController _tradeLicenseController;
  late TextEditingController _panCardNoController;
  late TextEditingController _aadhaarNoController;
  late TextEditingController _aadhaarCardController;
  late TextEditingController _pharmacistRegNoController;
  late TextEditingController _pharmacistRegController;
  late TextEditingController _businessRegNoController;
  late TextEditingController _bankDocumentController;
  late TextEditingController _addressProofNoController;
  late TextEditingController _addressProofController;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage(TextEditingController controller) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() => controller.text = image.path);
    }
  }

  Future<void> _pickFile(TextEditingController controller) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    if (result != null) {
      setState(() => controller.text = result.files.single.path!);
    }
  }

  Future<void> _viewDocument(String path) async {
    if (path.isEmpty || path == 'skipped_for_web_testing' || path == 'NOT UPLOADED') return;

    // If it's a local path during edit, ignore
    if (path.startsWith('/data') || path.startsWith('C:') || path.startsWith('/Users')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please save the profile first to view local files.')),
      );
      return;
    }

    String cleanPath = path.replaceAll('\\', '/');
    if (!cleanPath.startsWith('uploads/')) {
      if (cleanPath.startsWith('/')) {
        cleanPath = 'uploads$cleanPath';
      } else {
        cleanPath = 'uploads/$cleanPath';
      }
    }

    final urlString = '${ApiUrl.baseUrl}/$cleanPath';
    final Uri? url = Uri.tryParse(urlString);

    if (url == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid URL format')),
        );
      }
      return;
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open document. No app found to handle $urlString')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening document: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.shopName);
    _addressController = TextEditingController(text: user?.shopAddress);
    _phoneController = TextEditingController(text: user?.shopPhoneNo);
    _altPhoneController = TextEditingController(
      text: user?.shopAlternativePhoneNo,
    );
    _emailController = TextEditingController(text: user?.shopEmail);
    _passwordController = TextEditingController(text: user?.shopPassword);
    _whatsappController = TextEditingController(text: user?.whatsappNumber);
    _gstinController = TextEditingController(text: user?.gstinNo);
    _latitudeController = TextEditingController(text: user?.latitude);
    _longitudeController = TextEditingController(text: user?.longitude);
    _drugLicenseController = TextEditingController(
      text: user?.drugLicenseUpload,
    );
    _panCardController = TextEditingController(text: user?.panCardUpload);
    _bankAccountNoController = TextEditingController(text: user?.bankAccountNo);
    _bankIfscCodeController = TextEditingController(text: user?.bankIfscCode);
    _bankNameController = TextEditingController(text: user?.bankName);
    _bankAccountNameController = TextEditingController(text: user?.bankAccountName);
    _regCertController = TextEditingController(
      text: user?.registrationCertificateUpload,
    );
    _shopPhotoController = TextEditingController(text: user?.shopPhoto ?? '');
    _ownerPhotoController = TextEditingController(text: user?.ownerPhoto ?? '');
    _gstCertificateController = TextEditingController(text: user?.gstCertificateUpload ?? '');
    _drugLicenseNoController = TextEditingController(text: user?.drugLicenseNo ?? '');
    _tradeLicenseNoController = TextEditingController(text: user?.tradeLicenseNo ?? '');
    _tradeLicenseController = TextEditingController(text: user?.tradeLicenseUpload ?? '');
    _panCardNoController = TextEditingController(text: user?.panCardNo ?? '');
    _aadhaarNoController = TextEditingController(text: user?.aadhaarNo ?? '');
    _aadhaarCardController = TextEditingController(text: user?.aadhaarCardUpload ?? '');
    _pharmacistRegNoController = TextEditingController(text: user?.pharmacistRegNo ?? '');
    _pharmacistRegController = TextEditingController(text: user?.pharmacistRegUpload ?? '');
    _businessRegNoController = TextEditingController(text: user?.businessRegNo ?? '');
    _bankDocumentController = TextEditingController(text: user?.bankDocumentUpload ?? '');
    _addressProofNoController = TextEditingController(text: user?.addressProofNo ?? '');
    _addressProofController = TextEditingController(text: user?.addressProofUpload ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _whatsappController.dispose();
    _gstinController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _drugLicenseController.dispose();
    _panCardController.dispose();
    _bankAccountNoController.dispose();
    _bankIfscCodeController.dispose();
    _bankNameController.dispose();
    _bankAccountNameController.dispose();
    _regCertController.dispose();
    _shopPhotoController.dispose();
    _ownerPhotoController.dispose();
    _gstCertificateController.dispose();
    _drugLicenseNoController.dispose();
    _tradeLicenseNoController.dispose();
    _tradeLicenseController.dispose();
    _panCardNoController.dispose();
    _aadhaarNoController.dispose();
    _aadhaarCardController.dispose();
    _pharmacistRegNoController.dispose();
    _pharmacistRegController.dispose();
    _businessRegNoController.dispose();
    _bankDocumentController.dispose();
    _addressProofNoController.dispose();
    _addressProofController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final updatedUser = User(
      shopId: ref.read(authProvider).user?.shopId,
      shopName: _nameController.text,
      shopAddress: _addressController.text,
      shopPhoneNo: _phoneController.text,
      shopAlternativePhoneNo: _altPhoneController.text,
      shopEmail: _emailController.text,
      shopPassword: _passwordController.text,
      whatsappNumber: _whatsappController.text,
      gstinNo: _gstinController.text,
      latitude: _latitudeController.text,
      longitude: _longitudeController.text,
      shopPhoto: _shopPhotoController.text,
      ownerPhoto: _ownerPhotoController.text,
      drugLicenseNo: _drugLicenseNoController.text,
      drugLicenseUpload: _drugLicenseController.text,
      gstCertificateUpload: _gstCertificateController.text,
      tradeLicenseNo: _tradeLicenseNoController.text,
      tradeLicenseUpload: _tradeLicenseController.text,
      panCardNo: _panCardNoController.text,
      panCardUpload: _panCardController.text,
      aadhaarNo: _aadhaarNoController.text,
      aadhaarCardUpload: _aadhaarCardController.text,
      pharmacistRegNo: _pharmacistRegNoController.text,
      pharmacistRegUpload: _pharmacistRegController.text,
      businessRegNo: _businessRegNoController.text,
      registrationCertificateUpload: _regCertController.text,
      bankAccountNo: _bankAccountNoController.text,
      bankIfscCode: _bankIfscCodeController.text,
      bankName: _bankNameController.text,
      bankAccountName: _bankAccountNameController.text,
      bankDocumentUpload: _bankDocumentController.text,
      addressProofNo: _addressProofNoController.text,
      addressProofUpload: _addressProofController.text,
    );

    await ref.read(profileProvider.notifier).updateProfile(updatedUser);
    final profileState = ref.read(profileProvider);
    
    if (profileState.error == null && profileState.user != null) {
      await ref.read(authProvider.notifier).updateUser(profileState.user!);
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileState.error ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openMapPicker() async {
    if (!_isEditing) return;
    final latValue = double.tryParse(_latitudeController.text);
    final lngValue = double.tryParse(_longitudeController.text);
    final result = await context.push<Map<String, String>>(
      '/map',
      extra: {
        'latitude': latValue,
        'longitude': lngValue,
      },
    );

    if (result != null) {
      setState(() {
        _latitudeController.text = result['latitude'] ?? '';
        _longitudeController.text = result['longitude'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Edit Profile',
        subtitle: 'Shop details & documents',
        showBackButton: true,
        actions: [
          CustomAppBar.buildActionButton(
            icon: _isEditing ? Iconsax.tick_circle : Iconsax.edit_2,
            iconColor: _isEditing ? AppColors.success : AppColors.primary,
            onTap: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isEditing) _buildModernBanner(),
            const SizedBox(height: 16),
            _buildModernSection('GENERAL INFORMATION', [
              _buildModernEditableField(
                'Shop Name',
                _nameController,
                Iconsax.shop,
              ),
              _buildModernEditableField(
                'Shop Address',
                _addressController,
                Iconsax.location,
              ),
              _buildModernEditableField(
                'Latitude',
                _latitudeController,
                Iconsax.gps,
                readOnly: true,
                onTap: _openMapPicker,
              ),
              _buildModernEditableField(
                'Longitude',
                _longitudeController,
                Iconsax.gps_slash,
                readOnly: true,
                onTap: _openMapPicker,
              ),
              _buildModernEditableField(
                'Phone Number',
                _phoneController,
                Iconsax.call,
              ),
              _buildModernEditableField(
                'Alt. Phone',
                _altPhoneController,
                Iconsax.call,
              ),
            ]),
            const SizedBox(height: 24),
            _buildModernSection('ACCOUNT & SECURITY', [
              _buildModernEditableField(
                'Shop Email',
                _emailController,
                Iconsax.sms,
              ),
              _buildModernEditableField(
                'Password',
                _passwordController,
                Iconsax.lock,
                isPassword: true,
              ),
            ]),
            const SizedBox(height: 24),
            _buildModernSection('BUSINESS DETAILS', [
              _buildModernEditableField(
                'WhatsApp Number',
                _whatsappController,
                Iconsax.message,
              ),
              _buildModernEditableField(
                'GSTIN No.',
                _gstinController,
                Iconsax.card_pos,
              ),
            ]),
            const SizedBox(height: 24),
            _buildModernSection('VERIFICATION DOCUMENTS', [
              _buildModernPickerField('Shop Photo', _shopPhotoController, Iconsax.image, isImage: true),
              _buildModernPickerField('Owner Photo', _ownerPhotoController, Iconsax.image, isImage: true),
              _buildModernEditableField('Drug License No.', _drugLicenseNoController, Iconsax.document),
              _buildModernPickerField('Drug License Doc', _drugLicenseController, Iconsax.document_upload),
              _buildModernPickerField('GST Certificate Doc', _gstCertificateController, Iconsax.document_upload),
              _buildModernEditableField('Trade License No.', _tradeLicenseNoController, Iconsax.document),
              _buildModernPickerField('Trade License Doc', _tradeLicenseController, Iconsax.document_upload),
              _buildModernEditableField('PAN Card No.', _panCardNoController, Iconsax.personalcard),
              _buildModernPickerField('PAN Card Doc', _panCardController, Iconsax.document_upload),
              _buildModernEditableField('Aadhaar No.', _aadhaarNoController, Iconsax.personalcard),
              _buildModernPickerField('Aadhaar Card Doc', _aadhaarCardController, Iconsax.document_upload),
              _buildModernEditableField('Pharmacist Reg No.', _pharmacistRegNoController, Iconsax.document),
              _buildModernPickerField('Pharmacist Reg Doc', _pharmacistRegController, Iconsax.document_upload),
              _buildModernEditableField('Business Reg No.', _businessRegNoController, Iconsax.document),
              _buildModernPickerField('Business Reg Doc (Cert)', _regCertController, Iconsax.document_upload),
              _buildModernEditableField('Address Proof No.', _addressProofNoController, Iconsax.document),
              _buildModernPickerField('Address Proof Doc', _addressProofController, Iconsax.document_upload),
            ]),
            const SizedBox(height: 24),
            _buildModernSection('BANKING DETAILS', [
              _buildModernEditableField('Bank Name', _bankNameController, Iconsax.bank),
              _buildModernEditableField('Account Holder Name', _bankAccountNameController, Iconsax.user),
              _buildModernEditableField('Account Number', _bankAccountNoController, Iconsax.card),
              _buildModernEditableField('IFSC Code', _bankIfscCodeController, Iconsax.code),
              _buildModernPickerField('Bank Document Proof', _bankDocumentController, Iconsax.document_upload),
            ]),
            const SizedBox(height: 40),
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'SAVE UPDATES',
                    style: TextStyle(letterSpacing: 1.5),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: AppCardStyles.primaryGradientCard.copyWith(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.info_circle, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep your info updated',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Click the edit icon to modify details',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: AppTextStyles.tagline.copyWith(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Container(
          decoration: AppCardStyles.sleekCard.copyWith(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildModernEditableField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isEditing ? Colors.white : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEditing ? AppColors.primary.withAlpha(50) : AppColors.divider.withAlpha(30),
          width: 1,
        ),
        boxShadow: _isEditing ? [
          BoxShadow(
            color: AppColors.primary.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                TextField(
                  controller: controller,
                  enabled: _isEditing,
                  obscureText: isPassword,
                  readOnly: readOnly,
                  onTap: onTap,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _isEditing ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 6, bottom: 2),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPickerField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isImage = false,
  }) {
    final hasFile = controller.text.isNotEmpty && controller.text != 'skipped_for_web_testing';
    return InkWell(
      onTap: _isEditing
          ? () => isImage ? _pickImage(controller) : _pickFile(controller)
          : () => _viewDocument(controller.text),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isEditing ? Colors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (_isEditing && hasFile)
                ? AppColors.primary.withAlpha(100)
                : (_isEditing ? AppColors.primary.withAlpha(50) : AppColors.divider.withAlpha(30)),
            width: 1,
          ),
          boxShadow: _isEditing ? [
            BoxShadow(
              color: AppColors.primary.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasFile ? AppColors.primary.withAlpha(30) : AppColors.textTertiary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: hasFile ? AppColors.primary : AppColors.textTertiary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasFile ? controller.text.split('/').last : 'NOT UPLOADED',
                    style: TextStyle(
                      fontWeight: hasFile ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 14,
                      color: hasFile
                          ? AppColors.textPrimary
                          : AppColors.textTertiary.withAlpha(128),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (_isEditing)
              Icon(
                hasFile ? Iconsax.tick_circle : Iconsax.add_square,
                color: hasFile ? AppColors.success : AppColors.primary.withAlpha(180),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
