import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:whats/Home/Home.dart';
import 'package:whats/model/Usuario.dart';

class CadastroUsuario extends StatefulWidget {
  const CadastroUsuario({Key? key}) : super(key: key);

  @override
  State<CadastroUsuario> createState() => _CadastroUsuarioState();
}

class _CadastroUsuarioState extends State<CadastroUsuario> {
  final TextEditingController _controllerNome = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerSenha = TextEditingController();

  String _mensagemError = "";

  validarCampos() {
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (nome.isNotEmpty) {
      if (email.isNotEmpty && email.contains("@")) {
        if (senha.isNotEmpty && senha.length >= 6) {
            Usuario usuario = Usuario();

            usuario.nome = nome;
            usuario.emai = email;
            usuario.senha = senha;

          _cadastrarUsuario( usuario );

          setState(() {
            _mensagemError = "";
          });
        } else {
          setState(() {
            _mensagemError = "A senha precisa ser maior ou igual a 6 caracteres";
          });
        }
      } else {
        setState(() {
          _mensagemError = "Email inválido | Preencha usando o @";
        });
      }
    } else {
      setState(() {
        _mensagemError = "Nome e Email são obrigatórios!";
      });
    }
  }

  _cadastrarUsuario(Usuario usuario) async {
    FirebaseAuth auth = FirebaseAuth.instance;
      auth.createUserWithEmailAndPassword(
          email: usuario.emai,
          password: usuario.senha
      ).then((response){
       Navigator.push(context,
           MaterialPageRoute(builder: (context) => const Home(),
           ),
       );
      }).catchError((error) {
        setState(() {
          _mensagemError = "Error ao cadastrar usuário, "
              "verifique os campos ou tente novamente mais tarde!";
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro'),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Color(0xff075e54),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xff075e54)),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    'images/usuario.png',
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(15, 16, 15, 16),
                      hintText: "Nome",
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF25D366)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(15, 16, 15, 16),
                      hintText: "E-mail",
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF25D366)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),

                //! Campo de Senha
                TextField(
                  controller: _controllerSenha,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(15, 16, 15, 16),
                    hintText: "Senha",
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF25D366)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    child: Text(
                      "Cadastrar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      validarCampos();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16)),
                  ),
                ),

                Center(
                  child: Text(
                    _mensagemError,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 20,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
