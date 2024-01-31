import 'package:flutter/material.dart';
import 'package:whats/model/iConversa.dart';

class Conversas extends StatefulWidget {
  const Conversas({Key? key}) : super(key: key);

  @override
  State<Conversas> createState() => _ConversasState();
}

class _ConversasState extends State<Conversas> {
  List<iConversa> listasConversas = [
    iConversa("Renata", "Olá, tudo bem ?", "https://firebasestorage.googleapis.com/v0/b/whatsappflutter-23016.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=e853222e-392c-45b2-bc18-069fbf07f513"),
    iConversa("Renato", "Olá, tudo bem ?", "https://firebasestorage.googleapis.com/v0/b/whatsappflutter-23016.appspot.com/o/perfil%2Fperfil2.jpg?alt=media&token=ef2f1f58-0238-4721-a170-a3010f9fa86f"),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listasConversas.length,
      itemBuilder: (context, index) {
        iConversa conversa = listasConversas[index];
        return Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(10, 8, 16, 1),
              leading: CircleAvatar(
                maxRadius: 30,
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(conversa.caminhoFoto),
              ),
              title: Text(
                conversa.nome,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                conversa.mensagem,
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
