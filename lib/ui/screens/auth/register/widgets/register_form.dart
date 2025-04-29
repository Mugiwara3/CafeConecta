import 'package:flutter/material.dart';
import 'package:miapp_cafeconecta/ui/widgets/button/primary_button.dart';
import 'package:miapp_cafeconecta/ui/widgets/inputs/custom_text_field.dart';

class RegisterForm extends StatefulWidget {
  final Function({
    required String email,
    required String password,
    required String name,
    String? phone,
  })
  onSubmit;
  final String? errorMessage;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.onSubmit,
    this.errorMessage,
    required this.isLoading,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (widget.errorMessage != null)
            Text(
              widget.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _nameController,
            label: 'Nombre Completo',
            icon: Icons.person,
            validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: 'Correo Electrónico',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator:
                (value) => !value!.contains('@') ? 'Correo no válido' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            label: 'Teléfono (Opcional)',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            label: 'Contraseña',
            icon: Icons.lock,
            obscureText: true,
            validator:
                (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            onPressed: _submit,
            text: 'Registrarse',
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
    }
  }
}
