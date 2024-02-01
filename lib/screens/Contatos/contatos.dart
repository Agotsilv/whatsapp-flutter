import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whats/model/Usuario.dart';

class Contatos extends StatefulWidget {
  @override
  _ContatosState createState() => _ContatosState();
}

class _ContatosState extends State<Contatos> {
  String? _idUsuarioLogado;
  String? _emailUsuarioLogado;
  String _defaultImage =
      "https://t4.ftcdn.net/jpg/00/64/67/27/360_F_64672736_U5kpdGs9keUll8CRQ3p3YaEv2M6qkVY5.jpg";

  Future<List<Usuario>> _recuperarContatos() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection("usuarios").get();
    List<Usuario> listaUsuarios = [];
    for (DocumentSnapshot item in querySnapshot.docs) {
      var dados = item.data() as Map<String, dynamic>;
      if (dados["email"] == _emailUsuarioLogado) continue;

      Usuario usuario = Usuario();
      usuario.email = dados["email"] ?? "";
      usuario.nome = dados["nome"] ?? "";
      usuario.imagem = dados["urlImagem"] ?? _defaultImage;
      listaUsuarios.add(usuario);
    }
    return listaUsuarios;
  }

  _recuperarDadosUsuario() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    var usuarioLogado = await FirebaseAuth.instance.currentUser;
    _idUsuarioLogado = usuarioLogado?.uid;
    _emailUsuarioLogado = usuarioLogado?.email;
  }

  @override
  void initState() {
    _recuperarDadosUsuario();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
        future: _recuperarContatos(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Carregando contatos"),
                    CircularProgressIndicator(
                      color: Colors.green,
                    )
                  ],
                ),
              );

            case ConnectionState.active:
            case ConnectionState.done:
              return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, indice) {
                    List<Usuario>? listaItens = snapshot.data;
                    Usuario usuario = listaItens![indice];
                    return ListTile(
                      onTap: () {},
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor: Colors.grey,
                          backgroundImage: usuario.imagem != null
                              ? NetworkImage(usuario.imagem)
                              : null),
                      title: Text(
                        usuario.nome,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    );
                  });
          }
        });
  }
}
