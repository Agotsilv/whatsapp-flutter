import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whats/model/Usuario.dart';
import 'package:whats/model/iConversa.dart';
import 'package:whats/model/IMensagem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:whats/screens/Conversas/conversas.dart';

class Mensagem extends StatefulWidget {
  Usuario contato = Usuario();
  Mensagem(this.contato);

  @override
  State<Mensagem> createState() => _MensagemState();
}

class _MensagemState extends State<Mensagem> {
  final TextEditingController _controllerMensagem = TextEditingController();

  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  String _idUsuarioLogado = '';
  String _idUsuarioDestinatario = '';
  FirebaseFirestore db = FirebaseFirestore.instance;
  IMensagem mensagem = IMensagem();

  XFile? _imagem;
  late bool _subindoImagem = false;
  String _urlImagemRecuperada = '';

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = await auth.currentUser;
    setState(() {
      _idUsuarioLogado = usuarioLogado!.uid;
      _idUsuarioDestinatario = widget.contato.idUsuario!;
    });

    _adicionarListenerMensagens();
  }

  _enviarMensagem() async {
    late String mensagemText = _controllerMensagem.text;

    if (mensagemText.isNotEmpty) {
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = mensagemText;
      mensagem.urlImagem = '';
      mensagem.data = Timestamp.now().toString();
      mensagem.tipo = 'texto';

      // Remetente
      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

      // Destinatario
      _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

      _salvarConversa(mensagem);
    }
  }

  _salvarMensagem(
      String idRemetente, String idDestinarario, IMensagem msg) async {
    db
        .collection('mensagens')
        .doc(idRemetente)
        .collection(idDestinarario)
        .add(msg.toMap());

    _controllerMensagem.clear();
  }

  _enviarFoto() async {
    XFile? imagemSelecionada;
    ImagePicker picker = ImagePicker();

    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();

    imagemSelecionada = await picker.pickImage(source: ImageSource.gallery);

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child("mensagens")
        .child(_idUsuarioLogado)
        .child(nomeImagem + ".jpeg");

    File file = File(imagemSelecionada!.path);
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
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.data = Timestamp.now().toString();
    mensagem.tipo = 'imagem';

    // Remetente
    _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

    // Destinatario
    _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

    // Salvar conversa
    _salvarConversa(mensagem);
  }

  _salvarConversa(IMensagem msg) {
    // Salvar conversa remetente
    iConversa cRemetente = iConversa();

    cRemetente.idRemetente = _idUsuarioLogado;
    cRemetente.idDestinatario = _idUsuarioDestinatario;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.caminhoFoto = widget.contato.imagem;
    cRemetente.tipoMensagem = msg.tipo;
    cRemetente.salvar();

    // Salvar conversa Destinatário
    iConversa cDestinatario = iConversa();

    cDestinatario.idRemetente = _idUsuarioDestinatario;
    cDestinatario.idDestinatario = _idUsuarioLogado;
    cDestinatario.mensagem = msg.mensagem;
    cDestinatario.nome = widget.contato.nome;
    cDestinatario.caminhoFoto = widget.contato.imagem;
    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.salvar();
  }

  Stream<QuerySnapshot>? _adicionarListenerMensagens() {
    final stream = db
        .collection('mensagens')
        .doc(_idUsuarioLogado)
        .collection(_idUsuarioDestinatario)
        .orderBy("data", descending: false)
        .snapshots();

    stream.listen((event) {
      _controller.add(event);
      Timer(Duration(seconds: 1), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    var caixadeMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                autocorrect: false,
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma mensagem...",
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xff075e54)),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    prefixIcon: _subindoImagem
                        ? CircularProgressIndicator()
                        : IconButton(
                            icon: Icon(Icons.camera_alt,
                                color: Color(0xff075e54)),
                            onPressed: () {
                              _enviarFoto();
                            },
                          )),
              ),
            ),
          ),
          FloatingActionButton(
              backgroundColor: const Color(0xff075e54),
              child: Icon(Icons.send, color: Colors.white),
              mini: true,
              onPressed: () {
                _enviarMensagem();
              })
        ],
      ),
    );

    var stream = StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Carregando mensagem"),
                    CircularProgressIndicator(
                      color: Colors.green,
                    )
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot querySnapshot = snapshot.data!;

              if (snapshot.hasError) {
                return Expanded(child: Text('Error ao carregar Dados@'));
              } else {
                return Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: querySnapshot.docs.length,
                    itemBuilder: (context, index) {
                      List<DocumentSnapshot> mensagensRecebe =
                          querySnapshot.docs.toList();
                      DocumentSnapshot item = mensagensRecebe[index];
                      Alignment alinhamento = Alignment.centerRight;

                      Color cor = Color(0xffd2ffa5);
                      if (_idUsuarioLogado != item['idUsuario']) {
                        cor = Colors.white;
                        alinhamento = Alignment.centerLeft;
                      }
                      return Align(
                        alignment: alinhamento,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                              ),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: cor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  )),
                              child: item["_tipo"] == "texto"
                                  ? Text(
                                      item["mensagem"],
                                      style: TextStyle(fontSize: 18),
                                    )
                                  : Image.network(item["_urlImagem"])),
                        ),
                      );
                    },
                  ),
                );
              } // fim else
              break;
          }
        });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Transform.translate(
              offset: Offset(-30, 0),
              child: CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.contato.imagem != null
                    ? NetworkImage(widget.contato.imagem)
                    : null,
              ),
            ),
            Transform.translate(
              offset: Offset(-20, 0),
              child: Text(widget.contato.nome),
            ),
          ],
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xff075e54),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/bg.png'), fit: BoxFit.cover),
        ),
        child: SafeArea(
            child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              stream,
              caixadeMensagem,
            ],
          ),
        )),
      ),
    );
  }
}
