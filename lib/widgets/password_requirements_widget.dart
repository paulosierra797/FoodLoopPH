import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/password_validator.dart';

class PasswordRequirementsWidget extends StatelessWidget {
  final String password;
  final bool showRequirements;

  const PasswordRequirementsWidget({
    super.key,
    required this.password,
    this.showRequirements = true,
  });

  @override
  Widget build(BuildContext context) {
    final validation = PasswordValidator.validate(password);
    
    if (!showRequirements) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          ...validation.requirements.map((requirement) => 
            _buildRequirementRow(requirement)
          ).toList(),
          if (password.isNotEmpty) ...[
            SizedBox(height: 12),
            _buildStrengthIndicator(validation),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirementRow(PasswordRequirement requirement) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: requirement.isMet ? Colors.green : Colors.transparent,
              border: Border.all(
                color: requirement.isMet ? Colors.green : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: requirement.isMet
                ? Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  )
                : null,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              requirement.text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: requirement.isMet ? Colors.green[700] : Colors.grey[600],
                fontWeight: requirement.isMet ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthIndicator(PasswordValidationResult validation) {
    Color strengthColor;
    if (validation.strengthPercentage < 40) {
      strengthColor = Colors.red;
    } else if (validation.strengthPercentage < 70) {
      strengthColor = Colors.orange;
    } else if (validation.strengthPercentage < 100) {
      strengthColor = Colors.blue;
    } else {
      strengthColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password Strength:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              validation.strengthText,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: strengthColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: validation.strengthPercentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          minHeight: 4,
        ),
      ],
    );
  }
}

class PasswordStrengthField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool showRequirements;
  final Function(bool)? onValidationChanged;

  const PasswordStrengthField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.showRequirements = true,
    this.onValidationChanged,
  });

  @override
  State<PasswordStrengthField> createState() => _PasswordStrengthFieldState();
}

class _PasswordStrengthFieldState extends State<PasswordStrengthField> {
  bool _obscureText = true;
  bool _showRequirements = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPasswordChanged);
    super.dispose();
  }

  void _onPasswordChanged() {
    final validation = PasswordValidator.validate(widget.controller.text);
    widget.onValidationChanged?.call(validation.isValid);
    
    setState(() {
      _showRequirements = widget.controller.text.isNotEmpty && widget.showRequirements;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: widget.labelText ?? 'Password',
            hintText: widget.hintText ?? 'Enter your password',
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.amber[700]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: PasswordValidator.validatePassword,
        ),
        if (_showRequirements)
          PasswordRequirementsWidget(
            password: widget.controller.text,
            showRequirements: true,
          ),
      ],
    );
  }
}
