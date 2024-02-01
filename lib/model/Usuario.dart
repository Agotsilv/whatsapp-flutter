class Usuario {
  late String _nome;
  late String _email;
  late String _senha;
  late String _imagem;

  Usuario();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {"nome": nome, "email": email};
    return map;
  }

  String get imagem => _imagem;

  set imagem(String value) {
    _imagem = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }
}
