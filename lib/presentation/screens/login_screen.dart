// lib/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:math';

// Import signup screen
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  // Variabel untuk animasi mata singa
  late AnimationController _glassesController;
  late Animation<double> _glassesAnimation;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  double _leftPupilX = 0.0;
  double _leftPupilY = 0.0;
  double _rightPupilX = 0.0;
  double _rightPupilY = 0.0;
  double _earRotation = 0.0;
  bool _hasGlasses = false;

  @override
  void initState() {
    super.initState();
    _initializeSupabaseIfNeeded();
    
    // Setup animasi kacamata
    _glassesController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _glassesAnimation = CurvedAnimation(
      parent: _glassesController,
      curve: Curves.easeInOut,
    );
    
    // Mulai dengan animasi idle (telinga bergerak sedikit)
    _startIdleAnimation();
    
    // Listener untuk perubahan input
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _passwordController.removeListener(_onPasswordChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _glassesController.dispose();
    super.dispose();
  }

  void _startIdleAnimation() {
    // Animasi idle untuk telinga bergerak sedikit
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _earRotation = _earRotation == 0.0 ? 0.05 : 0.0;
        });
        _startIdleAnimation();
      }
    });
  }

  void _onEmailChanged() {
    if (_isEmailFocused) {
      final text = _emailController.text;
      final progress = min(text.length / 30.0, 1.0);
      
      setState(() {
        _leftPupilX = progress * 6.0 - 3.0;
        _rightPupilX = progress * 6.0 - 3.0;
        _leftPupilY = sin(progress * pi) * 1.5;
        _rightPupilY = sin(progress * pi) * 1.5;
      });
    }
  }

  void _onPasswordChanged() {
    if (_isPasswordFocused) {
      setState(() {
        _leftPupilX = 0.0;
        _rightPupilX = 0.0;
        _leftPupilY = 0.0;
        _rightPupilY = 0.0;
      });
    }
  }

  void _toggleGlasses() {
    if (_hasGlasses) {
      // Lepaskan kacamata
      _glassesController.reverse().whenComplete(() {
        if (mounted) {
          setState(() {
            _hasGlasses = false;
          });
        }
      });
    } else {
      // Pakai kacamata
      setState(() {
        _hasGlasses = true;
      });
      _glassesController.forward();
    }
  }

  void _onEmailFocusChanged(bool hasFocus) {
    setState(() {
      _isEmailFocused = hasFocus;
      if (hasFocus) {
        if (_hasGlasses) {
          _toggleGlasses();
        }
      }
    });
  }

  void _onPasswordFocusChanged(bool hasFocus) {
    setState(() {
      _isPasswordFocused = hasFocus;
      if (hasFocus) {
        if (_obscurePassword && !_hasGlasses) {
          _toggleGlasses();
        } else if (!_obscurePassword && _hasGlasses) {
          _toggleGlasses();
        }
      } else if (!_isEmailFocused && _hasGlasses) {
        _toggleGlasses();
      }
    });
  }

  Future<void> _initializeSupabaseIfNeeded() async {
    try {
      await Supabase.instance.client.rpc('ping');
    } catch (e) {
      try {
        await dotenv.load(fileName: ".env");
        final url = dotenv.env['SUPABASE_URL'];
        final key = dotenv.env['SUPABASE_ANON_KEY'];
        
        if (url == null || key == null) {
          throw Exception('File .env tidak lengkap');
        }
        
        await Supabase.initialize(url: url, anonKey: key);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal initialize Supabase: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      if (_hasGlasses) {
        _toggleGlasses();
      }
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Redirect ke home screen setelah login berhasil
      Get.offAllNamed('/');
    } on AuthException catch (e) {
      Get.snackbar(
        'Login Gagal',
        e.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToSignup() {
    Get.to(() => const SignupScreen());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final colors = theme.colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Lion Header - FIXED HEIGHT
                    Container(
                      height: size.height * 0.35,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Kepala Singa
                              GestureDetector(
                                onTap: () {
                                  if (_isPasswordFocused) {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                      if (_obscurePassword && !_hasGlasses) {
                                        _toggleGlasses();
                                      } else if (!_obscurePassword && _hasGlasses) {
                                        _toggleGlasses();
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.orange[700]!,
                                        Colors.orange[500]!,
                                        Colors.orange[300]!,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(60),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Telinga kiri
                                      Positioned(
                                        top: 15,
                                        left: 25,
                                        child: Transform.rotate(
                                          angle: _earRotation,
                                          child: Container(
                                            width: 25,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: Colors.orange[900],
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15),
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Telinga kanan
                                      Positioned(
                                        top: 15,
                                        right: 25,
                                        child: Transform.rotate(
                                          angle: -_earRotation,
                                          child: Container(
                                            width: 25,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: Colors.orange[900],
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15),
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Wajah singa
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.orange[400],
                                          borderRadius: BorderRadius.circular(50),
                                          border: Border.all(
                                            color: Colors.orange[800]!,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      
                                      // Rambut wajah
                                      Positioned(
                                        top: 40,
                                        left: 8,
                                        child: Container(
                                          width: 84,
                                          height: 35,
                                          decoration: BoxDecoration(
                                            color: Colors.orange[900]!.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(17.5),
                                          ),
                                        ),
                                      ),
                                      
                                      // Mata kiri
                                      Positioned(
                                        top: 38,
                                        left: 30,
                                        child: _LionEye(
                                          isLeft: true,
                                          pupilX: _leftPupilX,
                                          pupilY: _leftPupilY,
                                          hasGlasses: _hasGlasses,
                                        ),
                                      ),
                                      
                                      // Mata kanan
                                      Positioned(
                                        top: 38,
                                        right: 30,
                                        child: _LionEye(
                                          isLeft: false,
                                          pupilX: _rightPupilX,
                                          pupilY: _rightPupilY,
                                          hasGlasses: _hasGlasses,
                                        ),
                                      ),
                                      
                                      // Hidung
                                      Positioned(
                                        top: 62,
                                        child: Container(
                                          width: 20,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: Colors.brown[800],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                      
                                      // Mulut
                                      Positioned(
                                        top: 80,
                                        child: Container(
                                          width: 30,
                                          height: 2,
                                          color: Colors.brown[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Kacamata dengan animasi - FIXED OPACITY
                              if (_hasGlasses)
                              AnimatedBuilder(
                                animation: _glassesController,
                                builder: (context, child) {
                                  final animationValue = _glassesAnimation.value;
                                  final safeOpacity = animationValue.clamp(0.0, 1.0);
                                  
                                  return Positioned(
                                    top: 35,
                                    child: Opacity(
                                      opacity: safeOpacity,
                                      child: Transform.scale(
                                        scale: animationValue.clamp(0.5, 1.0),
                                        child: _LionGlasses(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Status text
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isEmailFocused
                                ? Text(
                                    'Singa sedang membaca emailmu... 📧',
                                    key: const ValueKey('email'),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.primary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  )
                                : _isPasswordFocused
                                    ? Text(
                                        _obscurePassword
                                            ? 'Singa pakai kacamata, password aman! 😎'
                                            : 'Singa bisa lihat passwordmu! 👁️',
                                        key: ValueKey(_obscurePassword ? 'glasses' : 'no_glasses'),
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: _obscurePassword 
                                              ? Colors.blue[700]
                                              : Colors.orange[700],
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.center,
                                      )
                                    : Text(
                                        'Raaaawr! Selamat datang! 🦁',
                                        key: const ValueKey('welcome'),
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Masuk ke Kerajaan Akunmu',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onBackground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Form Section - FLEXIBLE HEIGHT
                    Flexible(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),
                            
                            // Email Field
                            Focus(
                              onFocusChange: _onEmailFocusChanged,
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(
                                    PhosphorIcons.envelope(PhosphorIconsStyle.light),
                                    color: _isEmailFocused 
                                        ? colors.primary 
                                        : colors.onSurfaceVariant,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: _isEmailFocused
                                      ? colors.primary.withOpacity(0.05)
                                      : colors.surfaceVariant.withOpacity(0.3),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                style: theme.textTheme.bodyLarge,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email wajib diisi';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Email tidak valid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            Focus(
                              onFocusChange: _onPasswordFocusChanged,
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(
                                    PhosphorIcons.lock(PhosphorIconsStyle.light),
                                    color: _isPasswordFocused 
                                        ? colors.primary 
                                        : colors.onSurfaceVariant,
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                        if (_isPasswordFocused) {
                                          if (_obscurePassword && !_hasGlasses) {
                                            _toggleGlasses();
                                          } else if (!_obscurePassword && _hasGlasses) {
                                            _toggleGlasses();
                                          }
                                        }
                                      });
                                    },
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: Icon(
                                        key: ValueKey(_obscurePassword),
                                        _obscurePassword
                                            ? PhosphorIcons.eyeSlash(PhosphorIconsStyle.light)
                                            : PhosphorIcons.eye(PhosphorIconsStyle.light),
                                        color: _isPasswordFocused 
                                            ? colors.primary 
                                            : colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: _isPasswordFocused
                                      ? colors.primary.withOpacity(0.05)
                                      : colors.surfaceVariant.withOpacity(0.3),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                ),
                                style: theme.textTheme.bodyLarge,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password wajib diisi';
                                  }
                                  if (value.length < 6) {
                                    return 'Password minimal 6 karakter';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Get.snackbar(
                                    'Fitur Tersedia',
                                    'Fitur reset password akan segera hadir',
                                    backgroundColor: colors.primary,
                                    colorText: Colors.white,
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: colors.primary,
                                ),
                                child: const Text('Lupa Password?'),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _hasGlasses 
                                                ? PhosphorIcons.eyeglasses(PhosphorIconsStyle.light)
                                                : PhosphorIcons.crown(PhosphorIconsStyle.light),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Masuk ke Kerajaan',
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            PhosphorIcons.arrowRight(PhosphorIconsStyle.light),
                                            size: 16,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: colors.outline.withOpacity(0.3),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'ATAU',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: colors.outline.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Signup Button - MENGGUNAKAN GETX
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: _navigateToSignup,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.primary,
                                  side: BorderSide(
                                    color: colors.outline,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      PhosphorIcons.userPlus(PhosphorIconsStyle.light),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Bergabung dengan Kerajaan',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer - FIXED HEIGHT
                    Container(
                      height: 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _hasGlasses
                                    ? PhosphorIcons.eyeglasses(PhosphorIconsStyle.light)
                                    : PhosphorIcons.pawPrint(PhosphorIconsStyle.light),
                                size: 12,
                                color: colors.onSurfaceVariant.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _hasGlasses
                                    ? 'Mode rahasia aktif! 😎'
                                    : 'Dilindungi oleh Singa Penjaga',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '© 2024 Lion Kingdom. All rights reserved',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget untuk mata singa
class _LionEye extends StatelessWidget {
  final bool isLeft;
  final double pupilX;
  final double pupilY;
  final bool hasGlasses;

  const _LionEye({
    required this.isLeft,
    required this.pupilX,
    required this.pupilY,
    required this.hasGlasses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.orange[900]!,
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pupil
          Positioned(
            left: 5 + pupilX.clamp(-3.0, 3.0),
            top: 5 + pupilY.clamp(-2.0, 2.0),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: hasGlasses ? Colors.grey[700] : Colors.brown[900],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk kacamata singa
class _LionGlasses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      height: 35,
      child: Stack(
        children: [
          // Frame kiri
          Positioned(
            left: 10,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.blueGrey[800]!,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          
          // Frame kanan
          Positioned(
            right: 10,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.blueGrey[800]!,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          
          // Bridge kacamata
          Positioned(
            left: 38,
            top: 12,
            child: Container(
              width: 15,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.blueGrey[800],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}