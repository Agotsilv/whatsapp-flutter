import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cross_file/cross_file.dart';

class Configuracoes extends StatefulWidget {
  const Configuracoes({Key? key}) : super(key: key);

  @override
  State<Configuracoes> createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  final TextEditingController _controllerNome = TextEditingController();

  XFile? _imagem;
  late String _idUsuarioLogado;
  late bool _subindoImagem = false;
  String _urlImagemRecuperada = '';
  String _defaultImage =
      "https://t4.ftcdn.net/jpg/00/64/67/27/360_F_64672736_U5kpdGs9keUll8CRQ3p3YaEv2M6qkVY5.jpg";

  Future<dynamic>? _recuperarImagem(String origemDaImagem) async {
    XFile? imagemSelecionada;
    ImagePicker picker = ImagePicker();

    switch (origemDaImagem) {
      case 'camera':
        imagemSelecionada = await picker.pickImage(source: ImageSource.camera);
        break;
      case 'galeria':
        imagemSelecionada = await picker.pickImage(source: ImageSource.gallery);
        break;
    }
    setState(() {
      _imagem = imagemSelecionada;
      if (_imagem != null) {
        _uploadImage();
      }
    });
  }

  Future<dynamic>? _uploadImage() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo =
        pastaRaiz.child("perfil").child("$_idUsuarioLogado.jpeg");

    File file = File(_imagem!.path);

    UploadTask uploadTask = arquivo.putFile(file);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      if (snapshot.state == TaskState.running) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (snapshot.state == TaskState.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });

    uploadTask.then((TaskSnapshot snapshot) {
      _recuperarUrlImagem(snapshot);
    });
  }

  Future<dynamic>? _recuperarUrlImagem(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    // _atualizarUrlImageFireStore(url);
    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  // _atualizarUrlImageFireStore(String url){
  //     FirebaseFirestore db = FirebaseFirestore.instance;
  //
  //     Map<String, dynamic> dadosAtualizar ={
  //       "urlImagem": url
  //     };
  //     db.collection('usuarios')
  //     .doc(_idUsuarioLogado)
  //     .update(dadosAtualizar);
  // }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = await auth.currentUser;
    _idUsuarioLogado = usuarioLogado!.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;

    DocumentSnapshot snapshot =
        await db.collection("usuarios").doc(_idUsuarioLogado).get();

    if (snapshot.exists) {
      Map<String, dynamic> dados = snapshot.data() as Map<String, dynamic>;
      _controllerNome.text = dados['nome'];

      if (dados['urlImagem'] != null) {
        setState(() {
          _urlImagemRecuperada = dados['urlImagem'];
        });
      }
    }
  }

  updateData() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String nome = _controllerNome.text;
    String imagem = _urlImagemRecuperada != '' ? _urlImagemRecuperada : _defaultImage;

    Map<String, dynamic> dadosAtualizar = {
      "urlImagem": imagem,
      "nome": nome
    };
    db.collection('usuarios').doc(_idUsuarioLogado).update(dadosAtualizar);

    Navigator.pop(context, '/home');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
        backgroundColor: const Color(0xff075e54),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: _subindoImagem
                      ? CircularProgressIndicator()
                      : Container(),
                ),
                CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    backgroundImage: _urlImagemRecuperada.isNotEmpty
                        ? NetworkImage(_urlImagemRecuperada)
                        : NetworkImage(_defaultImage)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        _recuperarImagem("camera");
                      },
                      child: Text(
                        "Câmera",
                        style: TextStyle(fontSize: 20, color: Colors.black87),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _recuperarImagem("galeria");
                      },
                      child: Text(
                        "Galeria",
                        style: TextStyle(fontSize: 20, color: Colors.black87),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 8, left: 25, right: 25, top: 5),
                  child: TextField(
                    autofocus: true,
                    controller: _controllerNome,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(15, 16, 10, 16),
                      hintText: "Nome",
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF20B457)),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    child: Text(
                      "Salvar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      updateData();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
