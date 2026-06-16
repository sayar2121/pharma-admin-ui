import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Screen 1: Basic Info
  final _shopNameController = TextEditingController();
  final _shopOwnerNameController = TextEditingController();
  final _ownerPhotoController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _addressProofController = TextEditingController();
  final _shopPhotoController = TextEditingController();
  final _shopPhoneController = TextEditingController();
  final _shopAltPhoneController = TextEditingController();
  final _shopEmailController = TextEditingController();
  final _shopPasswordController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _whatsappController = TextEditingController();

  // Screen 2: Business & Licenses
  final _gstinController = TextEditingController();
  final _gstCertController = TextEditingController();
  final _drugLicenseNoController = TextEditingController();
  final _drugLicenseController = TextEditingController();
  final _tradeLicenseNoController = TextEditingController();
  final _tradeLicenseController = TextEditingController();
  final _pharmacistRegNoController = TextEditingController();
  final _pharmacistRegController = TextEditingController();
  final _businessRegNoController = TextEditingController();
  final _regCertController = TextEditingController();

  // Screen 3: Identity Verification
  final _panCardNoController = TextEditingController();
  final _panCardController = TextEditingController();
  final _aadhaarNoController = TextEditingController();
  final _aadhaarCardController = TextEditingController();

  // Screen 4: Bank Details
  final _bankNameController = TextEditingController();
  final _bankAccountNameController = TextEditingController();
  final _bankBranchNameController = TextEditingController();
  final _bankIfscCodeController = TextEditingController();
  final _bankAccountNoController = TextEditingController();
  final _bankDocumentController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage(TextEditingController controller) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        controller.text = image.path;
      });
    }
  }

  Future<void> _pickFile(TextEditingController controller) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        controller.text = result.files.single.path!;
      });
    }
  }

  bool _validateCurrentStep() {
    List<TextEditingController> currentControllers = [];
    switch (_currentStep) {
      case 0:
        currentControllers = [
          _shopNameController, _shopOwnerNameController, _ownerPhotoController,
          _shopAddressController, _addressProofController, _shopPhotoController,
          _shopPhoneController, _shopAltPhoneController, _shopEmailController,
          _shopPasswordController, _latitudeController, _longitudeController,
          _whatsappController
        ];
        break;
      case 1:
        currentControllers = [
          _gstinController, _gstCertController, _drugLicenseNoController,
          _drugLicenseController, _tradeLicenseNoController, _tradeLicenseController,
          _pharmacistRegNoController, _pharmacistRegController, _businessRegNoController,
          _regCertController
        ];
        break;
      case 2:
        currentControllers = [
          _panCardNoController, _panCardController,
          _aadhaarNoController, _aadhaarCardController
        ];
        break;
      case 3:
        currentControllers = [
          _bankNameController, _bankAccountNameController, _bankBranchNameController,
          _bankIfscCodeController, _bankAccountNoController, _bankDocumentController
        ];
        break;
    }

    for (var controller in currentControllers) {
      if (controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields in this step.'),
            backgroundColor: AppColors.error,
          ),
        );
        return false;
      }
    }
    return true;
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _submit() {
    final user = User(
      shopName: _shopNameController.text,
      shopOwnerName: _shopOwnerNameController.text,
      ownerPhoto: _ownerPhotoController.text,
      shopAddress: _shopAddressController.text,
      addressProofUpload: _addressProofController.text,
      shopPhoto: _shopPhotoController.text,
      shopPhoneNo: _shopPhoneController.text,
      shopAlternativePhoneNo: _shopAltPhoneController.text,
      shopEmail: _shopEmailController.text,
      shopPassword: _shopPasswordController.text,
      latitude: _latitudeController.text,
      longitude: _longitudeController.text,
      whatsappNumber: _whatsappController.text,
      
      gstinNo: _gstinController.text,
      gstCertificateUpload: _gstCertController.text,
      drugLicenseNo: _drugLicenseNoController.text,
      drugLicenseUpload: _drugLicenseController.text,
      tradeLicenseNo: _tradeLicenseNoController.text,
      tradeLicenseUpload: _tradeLicenseController.text,
      pharmacistRegNo: _pharmacistRegNoController.text,
      pharmacistRegUpload: _pharmacistRegController.text,
      businessRegNo: _businessRegNoController.text,
      registrationCertificateUpload: _regCertController.text,
      
      panCardNo: _panCardNoController.text,
      panCardUpload: _panCardController.text,
      aadhaarNo: _aadhaarNoController.text,
      aadhaarCardUpload: _aadhaarCardController.text,
      
      bankName: _bankNameController.text,
      bankAccountName: _bankAccountNameController.text,
      bankBranchName: _bankBranchNameController.text,
      bankIfscCode: _bankIfscCodeController.text,
      bankAccountNo: _bankAccountNoController.text,
      bankDocumentUpload: _bankDocumentController.text,
    );

    ref.read(authProvider.notifier).signup(user).then((_) {
      final state = ref.read(authProvider);
      if (!mounted) return;
      if (state.error == null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.verify, color: AppColors.success, size: 48),
                ),
                const SizedBox(height: 24),
                const Text('Account Created!', style: AppTextStyles.cardTitle),
                const SizedBox(height: 12),
                const Text(
                  'Your account will be activated in 24 to 48 hours. Once our admin panel verifies your details, you can start receiving orders.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.description,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/login');
                    },
                    child: const Text('Back to Login'),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${state.error}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
  }

  Future<void> _openMapPicker() async {
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildSlide('Basic Info', 'Tell us about your shop', [
                    _buildTextField(_shopNameController, 'Shop Name', Iconsax.shop),
                    _buildTextField(_shopOwnerNameController, 'Shop Owner Name', Iconsax.user),
                    _buildPickerField(_ownerPhotoController, 'Shop Owner Picture', Iconsax.image, isImage: true),
                    _buildTextField(_shopAddressController, 'Shop Address', Iconsax.location),
                    _buildPickerField(_addressProofController, 'Shop Address Proof', Iconsax.document_upload),
                    _buildPickerField(_shopPhotoController, 'Shop Photo', Iconsax.image, isImage: true),
                    _buildTextField(_shopPhoneController, 'Shop Phone Number', Iconsax.call),
                    _buildTextField(_shopAltPhoneController, 'Alternative Phone Number', Iconsax.call),
                    _buildTextField(_shopEmailController, 'Shop Email', Iconsax.sms),
                    _buildTextField(_shopPasswordController, 'Shop Password', Iconsax.lock, isPassword: true),
                    _buildTextField(_latitudeController, 'Latitude', Iconsax.gps, readOnly: true, onTap: _openMapPicker),
                    _buildTextField(_longitudeController, 'Longitude', Iconsax.gps_slash, readOnly: true, onTap: _openMapPicker),
                    _buildTextField(_whatsappController, 'WhatsApp Number', Iconsax.message),
                  ]),
                  _buildSlide('Business Details', 'Licenses & Registrations', [
                    _buildTextField(_gstinController, 'GST Number', Iconsax.card_pos),
                    _buildPickerField(_gstCertController, 'GST Certificate Upload', Iconsax.document_upload),
                    _buildTextField(_drugLicenseNoController, 'Drug License Number', Iconsax.health),
                    _buildPickerField(_drugLicenseController, 'Drug License Upload', Iconsax.document_upload),
                    _buildTextField(_tradeLicenseNoController, 'Trade License Number', Iconsax.buildings),
                    _buildPickerField(_tradeLicenseController, 'Trade License Upload', Iconsax.document_upload),
                    _buildTextField(_pharmacistRegNoController, 'Pharmacist Reg Number', Iconsax.verify),
                    _buildPickerField(_pharmacistRegController, 'Pharmacist Reg Upload', Iconsax.document_upload),
                    _buildTextField(_businessRegNoController, 'Business Reg Number', Iconsax.building_4),
                    _buildPickerField(_regCertController, 'Business Reg Upload', Iconsax.document_upload),
                  ]),
                  _buildSlide('Identity', 'Personal verification', [
                    _buildTextField(_panCardNoController, 'PAN Card Number', Iconsax.card),
                    _buildPickerField(_panCardController, 'Upload PAN Card', Iconsax.document_upload),
                    _buildTextField(_aadhaarNoController, 'Aadhar Card Number', Iconsax.personalcard),
                    _buildPickerField(_aadhaarCardController, 'Aadhar Card Upload', Iconsax.document_upload),
                  ]),
                  _buildSlide('Bank Details', 'Where we send your money', [
                    _buildTextField(_bankNameController, 'Bank Name', Iconsax.bank),
                    _buildTextField(_bankAccountNameController, 'Bank Account Holder Name', Iconsax.user),
                    _buildTextField(_bankBranchNameController, 'Branch Name', Iconsax.building),
                    _buildTextField(_bankIfscCodeController, 'IFSC Code', Iconsax.code),
                    _buildTextField(_bankAccountNoController, 'Bank Account Number', Iconsax.card),
                    _buildPickerField(_bankDocumentController, 'Passbook Front Page Upload', Iconsax.document_upload),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousStep,
            icon: const Icon(Iconsax.arrow_left_2),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Account', style: AppTextStyles.subHeader),
              Text('Step-by-step registration', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: AppColors.divider,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: AppTextStyles.caption,
              ),
              Text(
                '${((_currentStep + 1) / _totalSteps * 100).toInt()}%',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(String title, String subtitle, List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.header.copyWith(fontSize: 24)),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.description),
          const SizedBox(height: 40),
          ...children.expand((w) => [w, const SizedBox(height: 20)]),
          const SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildPickerField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isImage = false,
  }) {
    final hasFile = controller.text.isNotEmpty;
    return GestureDetector(
      onTap: () => isImage ? _pickImage(controller) : _pickFile(controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          border: Border.all(
            color: hasFile ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: hasFile ? AppColors.primary : AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (hasFile)
                    Text(
                      controller.text.split('/').last,
                      style: AppTextStyles.description.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'Tap to upload',
                      style: AppTextStyles.description.copyWith(
                        fontSize: 14,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            if (hasFile)
              const Icon(
                Iconsax.tick_circle,
                color: AppColors.success,
                size: 20,
              )
            else
              const Icon(
                Iconsax.add_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }

  Widget _buildFooter() {
    final authState = ref.watch(authProvider);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: authState.isLoading ? null : _nextStep,
          child: authState.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(_currentStep == _totalSteps - 1 ? 'Finish' : 'Continue'),
        ),
      ),
    );
  }
}
