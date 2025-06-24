import 'package:flutter/material.dart';
import '../services/fitness_service.dart';
import '../models/user_profile.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _goalController = TextEditingController();
  String _selectedGender = 'Male';
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadExistingProfile();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration:const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin:const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  void _loadExistingProfile() {
    final profile = FitnessService().userProfile;
    if (profile != null) {
      _weightController.text = profile.weight.toString();
      _heightController.text = profile.height.toString();
      _ageController.text = profile.age.toString();
      _goalController.text = profile.dailyStepGoal.toString();
      _selectedGender = profile.gender;
    } else {
      _goalController.text = '10000';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics:const BouncingScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  padding:const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildForm(),
                      const SizedBox(height: 40),
                      _buildSaveButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Setup Your Profile',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00D4FF),
                Color(0xFF5B73FF),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Help us personalize your fitness experience',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _weightController,
            label: 'Weight (kg)',
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _heightController,
            label: 'Height (cm)',
            icon: Icons.height,
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _ageController,
            label: 'Age',
            icon: Icons.cake_outlined,
          ),
          const SizedBox(height: 24),
          _buildGenderSelector(),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _goalController,
            label: 'Daily Step Goal',
            icon: Icons.flag_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        color: Colors.white.withOpacity(0.05),
      ),
      child: TextFormField(
        controller: controller,
        style:const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w300,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.6),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding:const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:const BorderSide(
              color: Color(0xFF00D4FF),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.red.withOpacity(0.7),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        color: Colors.white.withOpacity(0.05),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        style:const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        dropdownColor:const Color(0xFF1A1A2E),
        decoration: InputDecoration(
          labelText: 'Gender',
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w300,
          ),
          prefixIcon: Icon(
            Icons.person_outline,
            color: Colors.white.withOpacity(0.6),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding:const EdgeInsets.symmetric(vertical: 20),
        ),
        items: ['Male', 'Female', 'Other'].map((gender) {
          return DropdownMenuItem(
            value: gender,
            child: Text(
              gender,
              style:const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedGender = value!;
          });
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00D4FF),
            Color(0xFF5B73FF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00D4FF).withOpacity(0.3),
            blurRadius: 20,
            offset:const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ?const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Save Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final profile = UserProfile(
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        dailyStepGoal: int.parse(_goalController.text),
      );

      try {
        await FitnessService().saveUserProfile(profile);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:const Text('Profile saved successfully'),
            backgroundColor:const Color(0xFF00D4FF),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        
        await Future.delayed(Duration(milliseconds: 500));
        
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration:const Duration(milliseconds: 500),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
