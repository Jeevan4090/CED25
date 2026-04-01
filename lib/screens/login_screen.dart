import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'dashboard_screen.dart';
import 'student_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _codeFocus = FocusNode();

  bool _isLoading = false;
  bool _obscureCode = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: const Interval(0.0, 0.7, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic)));
    _scaleAnim = Tween<double>(begin: 0.96, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    nameController.dispose();
    codeController.dispose();
    _nameFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final code = codeController.text.trim();
    final name = nameController.text.trim();
    final supabase = Supabase.instance.client;

    if (name.isEmpty) {
      _showSnack('Please enter your name');
      return;
    }
    if (code.isEmpty) {
      _showSnack('Please enter your access code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final admin = await supabase
          .from('admins')
          .select()
          .eq('access_code', code)
          .maybeSingle();

      if (admin != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_code", code);
        await prefs.setString("name", name);
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("role", "admin");
        if (!mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()));
        return;
      }

      final student = await supabase
          .from('students')
          .select()
          .eq('access_code', code)
          .maybeSingle();

      if (student != null) {
        await supabase
            .from('students')
            .update({"name": name}).eq('access_code', code);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_code", code);
        await prefs.setString("name", name);
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("role", "student");
        if (!mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const StudentDashboard()));
        return;
      }

      if (!mounted) return;
      _showSnack('Invalid access code. Please try again.');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFF),
      body: Stack(
        children: [
          // ── BACKGROUND DECORATION ─────────────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5B4FFF).withOpacity(0.14),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00C6FF).withOpacity(0.16),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7C3AED).withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5A0).withOpacity(0.13),
              ),
            ),
          ),

          // ── MAIN CONTENT ──────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SizedBox(
                height: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.08),

                    // ── TOP BADGE ───────────────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B4FFF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF5B4FFF).withOpacity(0.35),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.school_rounded,
                                size: 14, color: Color(0xFF5B4FFF)),
                            SizedBox(width: 6),
                            Text(
                              'Civil Engineering Dept.',
                              style: TextStyle(
                                color: Color(0xFF5B4FFF),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── TITLE ───────────────────────────────────────────
                    SlideTransition(
                      position: _slideAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'CED',
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -2,
                                      height: 1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '25',
                                    style: TextStyle(
                                      color: Color(0xFF5B4FFF),
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -2,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your study material hub.\nSign in to get started.',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

                    // ── FORM CARD ───────────────────────────────────────
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                                color: const Color(0xFFC7C2FF), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5B4FFF).withOpacity(0.14),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome back',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Enter your details to continue',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Name field
                              _InputField(
                                controller: nameController,
                                focusNode: _nameFocus,
                                hint: 'Your full name',
                                label: 'Name',
                                icon: Icons.person_outline_rounded,
                                nextFocus: _codeFocus,
                              ),

                              const SizedBox(height: 14),

                              // Code field
                              _InputField(
                                controller: codeController,
                                focusNode: _codeFocus,
                                hint: 'Enter your access code',
                                label: 'Access Code',
                                icon: Icons.vpn_key_outlined,
                                obscure: _obscureCode,
                                onObscureToggle: () =>
                                    setState(() => _obscureCode = !_obscureCode),
                                isLast: true,
                                onSubmit: () {
                                  FocusScope.of(context).unfocus();
                                  login();
                                },
                              ),

                              const SizedBox(height: 24),

                              // Enter button
                              GestureDetector(
                                onTap: _isLoading
                                    ? null
                                    : () {
                                        FocusScope.of(context).unfocus();
                                        login();
                                      },
                                child: Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: _isLoading
                                        ? null
                                        : const LinearGradient(
                                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                    color: _isLoading ? const Color(0xFFAEA8FF) : null,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: _isLoading ? [] : [
                                      BoxShadow(
                                        color: const Color(0xFF6366F1).withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ── FOOTER ──────────────────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Text(
                            'Need access? Contact your department admin.',
                            style: TextStyle(
                              color: const Color(0xFFADB5D0),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── INPUT FIELD ───────────────────────────────────────────────────────────────
class _InputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final String label;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onObscureToggle;
  final FocusNode? nextFocus;
  final bool isLast;
  final VoidCallback? onSubmit;

  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.onObscureToggle,
    this.nextFocus,
    this.isLast = false,
    this.onSubmit,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: _focused ? const Color(0xFF5B4FFF) : const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _focused
                ? const Color(0xFFF0EEFF)
                : const Color(0xFFFBFBFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _focused
                  ? const Color(0xFF5B4FFF)
                  : const Color(0xFFD4D0FF),
              width: _focused ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: widget.obscure,
            textInputAction:
                widget.isLast ? TextInputAction.done : TextInputAction.next,
            onSubmitted: (_) {
              if (widget.nextFocus != null) {
                FocusScope.of(context).requestFocus(widget.nextFocus);
              } else {
                widget.onSubmit?.call();
              }
            },
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                widget.icon,
                size: 18,
                color: _focused
                    ? const Color(0xFF5B4FFF)
                    : const Color(0xFFB8B3E8),
              ),
              suffixIcon: widget.onObscureToggle != null
                  ? GestureDetector(
                      onTap: widget.onObscureToggle,
                      child: Icon(
                        widget.obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: const Color(0xFFB8B3E8),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}