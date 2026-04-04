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

    if (value!.trim().length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
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

