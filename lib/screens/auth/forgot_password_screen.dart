import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studytrack/core/utils/app_validators.dart';
import 'package:studytrack/core/utils/snackbar_utils.dart';
import 'package:studytrack/providers/auth_provider.dart';
import 'package:studytrack/widgets/app_text_field.dart';
import 'package:studytrack/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleRecovery() async {
    final errorMessage = AppValidators.email(_emailController.text);

    if (errorMessage != null) {
      SnackBarUtils.show(context, errorMessage, isError: true);
      return;
    }

    try {
      await context.read<AuthProvider>().recoverPassword(_emailController.text);
    } catch (error) {
      if (!mounted) {
        return;
      }

      SnackBarUtils.show(context, error.toString(), isError: true);
      return;
    }

    if (!mounted) {
      return;
    }

    SnackBarUtils.show(
      context,
      'Link de recuperacao enviado de forma simulada para o email informado.',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Informe seu email para simular o envio da recuperacao.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Recuperar',
                  icon: Icons.send_rounded,
                  isLoading: authProvider.isLoading,
                  onPressed: _handleRecovery,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
