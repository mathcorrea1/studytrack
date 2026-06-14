class AppValidators {
  const AppValidators._();

  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'O campo $fieldName e obrigatorio.';
    }

    return null;
  }

  static String? email(String? value) {
    final requiredValidation = requiredField(value, 'email');
    if (requiredValidation != null) {
      return requiredValidation;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Informe um email valido.';
    }

    return null;
  }

  static String? password(String? value) {
    final requiredValidation = requiredField(value, 'senha');
    if (requiredValidation != null) {
      return requiredValidation;
    }

    final password = value!.trim();

    if (password.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'A senha deve ter pelo menos uma letra maiuscula.';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'A senha deve ter pelo menos uma letra minuscula.';
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      return 'A senha deve ter pelo menos um numero.';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\[\];~`]').hasMatch(password)) {
      return 'A senha deve ter pelo menos um caractere especial.';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final requiredValidation = requiredField(value, 'confirmacao de senha');
    if (requiredValidation != null) {
      return requiredValidation;
    }

    if (value != password) {
      return 'As senhas precisam ser iguais.';
    }

    return null;
  }
}

