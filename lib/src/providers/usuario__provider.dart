import 'package:formvalidation/src/preferencias/preferencias_usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UsuarioProvider {

  final String _firebaseToken = 'AIzaSyCQYA45JLid1aFh1HdDzi5yn9tPY-pRw3I';

  final _prefs = PreferenciasUsuario();

  Future<Map<String, dynamic>> nuevoUsuario(String email, String password) async {

    final authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    final resp = await http.post(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_firebaseToken',
      body: json.encode(authData)
    );

    Map<String, dynamic> decodedResp = json.decode(resp.body);

    print(decodedResp);

    if(decodedResp.containsKey('idToken')){
      //Salvar Token
      _prefs.token = decodedResp['idToken'];
      return { 'ok' : true, 'token' : decodedResp['idToken']};
    }else{
      //Error
      return { 'ok' : false, 'mensaje': decodedResp['error']['message']};
    }

  }

  Future<Map<String, dynamic>> login(String email, String password) async{

    final authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    final resp = await http.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_firebaseToken',
        body: json.encode(authData)
    );

    Map<String, dynamic> decodedResp = json.decode(resp.body);

    print(decodedResp);

    if(decodedResp.containsKey('idToken')){
      //Salvar Token
      _prefs.token = decodedResp['idToken'];
      return { 'ok' : true, 'token' : decodedResp['idToken']};
    }else{
      //Error
      return { 'ok' : false, 'mensaje': decodedResp['error']['message']};
    }

  }

}
