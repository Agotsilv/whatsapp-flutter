class Usuario {
  late String _nome;
  late String _emai;
  late String _senha;

  Usuario();

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get emai => _emai;

  set emai(String value) {
    _emai = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }
}