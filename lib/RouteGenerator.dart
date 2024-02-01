import "package:flutter/material.dart";
import "package:whats/CadastroUsuario/Cadastro.dart";
import "package:whats/Configuracoes/Configuracoes.dart";
import "package:whats/Home/Home.dart";
import "package:whats/LoginUser/Login.dart";


class RouteGenerator{

  static Route<dynamic>? generateRoute(RouteSettings settings){
    switch(settings.name){
      case "/":
        return MaterialPageRoute(builder: (_) => Login());
        case "/login":
          return MaterialPageRoute(builder: (_) => Login());
      case "/cadastro":
        return MaterialPageRoute(builder: (_) => CadastroUsuario());
      case "/home":
        return MaterialPageRoute(builder: (_) => Home());
      case "/config":
        return MaterialPageRoute(builder: (_) => Configuracoes());
      default:
        _errorRota();
      // case "/home":
      //   return MaterialPageRoute(builder: (_) => Home());
    }
  }

  static Route<dynamic> _errorRota(){
    return MaterialPageRoute(builder: (_){
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tela não encontrada!'),
        ),
        body: const Center(
          child: Text("Tela não encontrada!"),
        ),
      );
    });
  }

}