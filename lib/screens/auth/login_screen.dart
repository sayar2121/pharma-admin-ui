import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../cards/auth/contact_bottomsheet.dart';
import '../../cards/auth/error_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _currentPage = 0;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.user != null) {
        context.go('/dashboard');
      }
      if (previous?.isLoading == true && !next.isLoading && next.error != null) {
        ErrorBottomSheet.show(context, next.error!);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background accents
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withAlpha(20),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      // Top header area
                      Row(
                        children: [
                          // Back Button
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _currentPage == 1 ? 1.0 : 0.0,
                            child: _currentPage == 1
                                ? IconButton(
                                    onPressed: _previousPage,
                                    icon: const Icon(Iconsax.arrow_left_2, color: AppColors.textPrimary),
                                    padding: EdgeInsets.zero,
                                    alignment: Alignment.centerLeft,
                                  )
                                : const SizedBox(width: 48, height: 48),
                          ),
                          const Spacer(),
                          // Step Indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStepDot(0),
                              const SizedBox(width: 8),
                              _buildStepDot(1),
                            ],
                          ),
                          const Spacer(),
                          const SizedBox(width: 48), // Balance for back button
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Logo
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(30),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo/logo.png',
                            width: 60,
                            height: 60,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Iconsax.hospital,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      // Animated Form Wrapper
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) => setState(() => _currentPage = index),
                          children: [
                            _buildCardWrap(_buildEmailSlide()),
                            _buildCardWrap(_buildPasswordSlide()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.divider,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildCardWrap(Widget child) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(24),
        decoration: AppCardStyles.sleekCard,
        child: child,
      ),
    );
  }

  Widget _buildEmailSlide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Welcome Back', style: AppTextStyles.header),
        const SizedBox(height: 8),
        Text(
          'Enter your registered email to continue',
          style: AppTextStyles.description,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: 'Email Address',
            prefixIcon: Icon(Iconsax.sms, color: AppColors.primary),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextPage,
            child: const Text('Next'),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.description.copyWith(fontSize: 14),
              children: [
                const TextSpan(text: 'New user? '),
                TextSpan(
                  text: 'Create an account now',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () => context.push('/signup'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSlide() {
    final authState = ref.watch(authProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Enter Password', style: AppTextStyles.header),
        const SizedBox(height: 8),
        Text(
          'Secure your access with your password',
          style: AppTextStyles.description,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: const Icon(Iconsax.lock, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
                color: AppColors.textTertiary,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authState.isLoading
                ? null
                : () => ref.read(authProvider.notifier).login(_emailController.text, _passwordController.text),
            child: authState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Sign In'),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.description.copyWith(fontSize: 14),
              children: [
                const TextSpan(text: 'Having trouble logging in? '),
                TextSpan(
                  text: 'Contact support',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () => ContactBottomSheet.show(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
