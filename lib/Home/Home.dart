import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whats/LoginUser/Login.dart';
import 'package:whats/screens/Contatos/contatos.dart';
import 'package:whats/screens/Conversas/conversas.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  List<String> itensMenu = [
    "Configurações",
    "Deslogar"
  ];

  Future verificarUserLogado() async {

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(
        length: 2,
        vsync: this
    );
  }

  _escolhaMenuItem(String i) async{
      switch(i){
        case "Configurações":
          print('Config');
          break;
        case "Deslogar":
          _signOut();
          break;
      }
  }

  _signOut()async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.signOut();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Whatsapp"),
        elevation: 0, // Set AppBar elevation to 0 to remove its shadow
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48), // Set the preferred size for TabBar
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xff075e54), // Set the background color
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Shadow color and opacity
                  offset: const Offset(0, 2), // Offset of the shadow
                  blurRadius: 4, // Blur radius of the shadow
                ),
              ],
            ),
            child: TabBar(
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              unselectedLabelColor: Colors.black38,
              controller: _tabController,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'Conversas'),
                Tab(text: 'Contatos'),
              ],
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context){
              return itensMenu.map((String e){
                return PopupMenuItem<String>(
                    value: e,
                  child: Text(e),
                );
              }).toList();
            }
          )
        ],
        centerTitle: true,
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xff075e54),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Container(
        child: TabBarView(
          controller: _tabController,
          children: [
           Conversas(),
            Contatos(),
          ],
        ),
      ),
    );
  }
}
