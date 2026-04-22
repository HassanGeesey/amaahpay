import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: AppColors.neutral900),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected error occurred'), backgroundColor: AppColors.neutral900),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'name': 'Demo User', 'role': 'admin'},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Check your email to verify.'), backgroundColor: AppColors.neutral900),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: AppColors.neutral900),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected error occurred'), backgroundColor: AppColors.neutral900),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: C.bg(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              _buildLogo(),
              const SizedBox(height: 48),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildSubtitle(isDark),
              const SizedBox(height: 32),
              _buildForm(isDark),
              const SizedBox(height: 40),
              _buildFooter(isDark),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 72,
      height: 72,
      decoration: D.darkCard,
      child: const Icon(Icons.storefront_rounded, size: 36, color: C.textInverse),
    );
  }

  Widget _buildTitle() {
    return Text('AmaahPay', style: T.sectionHeader.copyWith(fontSize: 28, fontWeight: FontWeight.w700));
  }

  Widget _buildSubtitle(bool isDark) {
    return Text('Manage your shop with elegance', style: T.body.copyWith(color: C.muted(isDark)));
  }

  Widget _buildForm(bool isDark) {
    return Container(
      decoration: D.card(isDark: isDark),
      child: Column(
        children: [
          _buildEmailField(isDark),
          Container(height: 1, color: C.bdr(isDark), margin: const EdgeInsets.symmetric(horizontal: 16)),
          _buildPasswordField(isDark),
        ],
      ),
    );
  }

  Widget _buildEmailField(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.email_outlined, color: C.muted(isDark), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: T.body.copyWith(color: C.txt(isDark)),
              decoration: InputDecoration(
                hintText: 'Email address',
                hintStyle: T.body.copyWith(color: C.muted(isDark)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.lock_outline, color: C.muted(isDark), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: T.body.copyWith(color: C.txt(isDark)),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: T.body.copyWith(color: C.muted(isDark)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: C.textSecondary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _isLoading
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: D.darkCard,
                child: const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: C.textInverse))),
              )
            : _buildSignInButton(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account?", style: T.body.copyWith(color: C.textSecondary)),
            GestureDetector(
              onTap: _signUp,
              child: Padding(padding: const EdgeInsets.all(8), child: Text(' Sign up', style: T.body.copyWith(fontWeight: FontWeight.w600, color: C.accent))),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return GestureDetector(
      onTap: _signIn,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: D.darkCard,
        child: Center(child: Text('Sign In', style: T.body.copyWith(fontWeight: FontWeight.w600, color: C.textInverse))),
      ),
    );
  }
}