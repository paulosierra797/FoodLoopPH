class PasswordValidator {
  static const int minLength = 8;

  // Password validation result
  static PasswordValidationResult validate(String password) {
    final requirements = <PasswordRequirement>[
      PasswordRequirement(
        text: 'At least 8 characters',
        isMet: password.length >= minLength,
      ),
      PasswordRequirement(
        text: 'One uppercase letter (A-Z)',
        isMet: password.contains(RegExp(r'[A-Z]')),
      ),
      PasswordRequirement(
        text: 'One lowercase letter (a-z)',
        isMet: password.contains(RegExp(r'[a-z]')),
      ),
      PasswordRequirement(
        text: 'One number (0-9)',
        isMet: password.contains(RegExp(r'[0-9]')),
      ),
      PasswordRequirement(
        text: 'One special character (!@#\$%^&*)',
        isMet: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      ),
    ];

    final metRequirements = requirements.where((req) => req.isMet).length;
    final isValid = metRequirements == requirements.length;
    
    // Calculate strength percentage
    final strengthPercentage = (metRequirements / requirements.length * 100).round();
    
    String strengthText;
    if (strengthPercentage < 40) {
      strengthText = 'Weak';
    } else if (strengthPercentage < 70) {
      strengthText = 'Fair';
    } else if (strengthPercentage < 100) {
      strengthText = 'Good';
    } else {
      strengthText = 'Strong';
    }

    return PasswordValidationResult(
      requirements: requirements,
      isValid: isValid,
      strengthPercentage: strengthPercentage,
      strengthText: strengthText,
    );
  }

  // Quick validation for forms
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    final result = validate(password);
    if (!result.isValid) {
      final unmetRequirements = result.requirements
          .where((req) => !req.isMet)
          .map((req) => req.text)
          .toList();
      
      if (unmetRequirements.length == 1) {
        return 'Missing: ${unmetRequirements.first}';
      } else {
        return 'Missing ${unmetRequirements.length} requirements';
      }
    }
    
    return null;
  }
}

class PasswordRequirement {
  final String text;
  final bool isMet;

  PasswordRequirement({
    required this.text,
    required this.isMet,
  });
}

class PasswordValidationResult {
  final List<PasswordRequirement> requirements;
  final bool isValid;
  final int strengthPercentage;
  final String strengthText;

  PasswordValidationResult({
    required this.requirements,
    required this.isValid,
    required this.strengthPercentage,
    required this.strengthText,
  });
}
