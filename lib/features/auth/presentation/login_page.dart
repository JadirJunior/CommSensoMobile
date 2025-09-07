import 'package:commsensomobile/features/auth/presentation/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Branding / título
                      Image.asset('assets/icons/commsenso_logo_sem_fundo.png', height: 250, color: Theme.of(context).colorScheme.onSurface),
                      const SizedBox(height: 12),
                      Text('Entrar',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Acesse sua conta para continuar',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Campos
                      TextFormField(
                        controller: controller.userCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Usuário',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Informe o usuário' : null,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                      ),

                      // SizedBox usadas para espaçamento
                      const SizedBox(height: 12),
                      Obx(() => TextFormField(
                            controller: controller.passCtrl,
                            obscureText: controller.obscure.value,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(controller.obscure.value
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: controller.toggleObscure,
                              ),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Informe a senha'
                                : null,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => controller.onLogin(),
                            autofillHints: const [AutofillHints.password],
                          )),
                      const SizedBox(height: 8),

                      // Botão principal / loading
                      Obx(() {
                        final isLoading = controller.isLoading.value;
                        return FilledButton(
                          onPressed: isLoading ? null : controller.onLogin,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Entrar'),
                        );
                      }),
                      const SizedBox(height: 12),

                      // Erros (inline) opcional
                      Obx(() {
                        final err = controller.error.value;
                        if (err == null) return const SizedBox.shrink();
                        return Text(
                          err,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
