import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whats/model/Usuario.dart';
import 'package:whats/model/iConversa.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Conversas extends StatefulWidget {
  const Conversas({Key? key}) : super(key: key);

  @override
  State<Conversas> createState() => _ConversasState();
}

class _ConversasState extends State<Conversas> {

  final _controller = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;
  String _idUsuarioLogado = '';

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = await auth.currentUser;
    setState(() {
      _idUsuarioLogado = usuarioLogado!.uid;
    });

    _adicionarListenerConversas();
  }

  Stream<QuerySnapshot>? _adicionarListenerConversas() {
    final stream = db
        .collection("conversas")
        .doc(_idUsuarioLogado)
        .collection("ultima_conversa")
        .snapshots();

    stream.listen((event) {
      _controller.add(event);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Carregando conversas"),
                  CircularProgressIndicator(
                    color: Colors.green,
                  )
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text('Error ao carregar dados');
            } else {
              QuerySnapshot querySnapshot = snapshot.data!;
              if (querySnapshot.docs.length == 0) {
                return Center(
                  child: Text(
                    "Você não possui nenhuma mensagem ainda :(",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return ListView.builder(
                itemCount: querySnapshot.docs.length,
                itemBuilder: (context, index) {

                  List<DocumentSnapshot> conversas
                  = querySnapshot.docs.toList();

                  DocumentSnapshot item = conversas[index];

                  String url = item["caminhoFoto"];
                  String tipo = item["tipoMensagem"];
                  String mensagem = item["mensagem"];
                  String nome = item["nome"];
                  String idDestinatario = item["idDestinatario"];

                  Usuario usuario = Usuario();

                  usuario.nome = nome;
                  usuario.imagem = url;
                  usuario.idUsuario = idDestinatario;


                  return Column(
                    children: [
                      ListTile(
                          onTap: (){
                            Navigator.pushNamed(context, '/mensagens', arguments: usuario);
                          },

                        contentPadding: EdgeInsets.fromLTRB(10, 8, 16, 1),
                        leading: CircleAvatar(
                          maxRadius: 30,
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(url),
                        ),
                        title: Text(
                          nome,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: tipo == "texto" ? Text(
                          mensagem,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ) : Text(
                          "Imagem",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey[300], // Cor mais clara
                        thickness: 0.5, // Espessura mais fina
                      ),
                    ],
                  );
                },
              );
            }
        }
      },
    );
  }
}
