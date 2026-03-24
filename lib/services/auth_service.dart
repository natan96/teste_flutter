import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste_flutter/models/usuario.dart';

class AuthService {
  static const String _emailKey = 'user_email';
  static const String _nomeKey = 'user_nome';
  
  // Credenciais fixas para teste
  static const String validEmail = 'corretor@imobibrasil.com.br';
  static const String validPassword = 'imobi2026';

  Future<Usuario?> login(String email, String senha) async {
    // Simular delay de rede
    await Future.delayed(const Duration(seconds: 1));

    if (email == validEmail && senha == validPassword) {
      final usuario = Usuario(
        nome: 'Corretor ImobiBrasil',
        email: email,
      );
      
      // Salvar no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailKey, email);
      await prefs.setString(_nomeKey, usuario.nome);
      
      return usuario;
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_nomeKey);
  }

  Future<Usuario?> getUsuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    final nome = prefs.getString(_nomeKey);

    if (email != null && nome != null) {
      return Usuario(nome: nome, email: email);
    }
    return null;
  }

  Future<bool> isLogado() async {
    final usuario = await getUsuarioLogado();
    return usuario != null;
  }
}
