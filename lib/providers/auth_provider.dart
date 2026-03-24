import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teste_flutter/models/usuario.dart';
import 'package:teste_flutter/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final usuarioProvider = StateNotifierProvider<UsuarioNotifier, AsyncValue<Usuario?>>((ref) {
  return UsuarioNotifier(ref.watch(authServiceProvider));
});

class UsuarioNotifier extends StateNotifier<AsyncValue<Usuario?>> {
  final AuthService _authService;

  UsuarioNotifier(this._authService) : super(const AsyncValue.loading()) {
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    try {
      final usuario = await _authService.getUsuarioLogado();
      state = AsyncValue.data(usuario);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> login(String email, String senha) async {
    try {
      final usuario = await _authService.login(email, senha);
      if (usuario != null) {
        state = AsyncValue.data(usuario);
        return true;
      }
      // Não atualiza o estado se as credenciais forem inválidas
      // apenas retorna false
      return false;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }
}
