import 'dart:convert';
import 'dart:io';

import 'package:shelf_multipart/form_data.dart';
import 'package:shelf_multipart/multipart.dart';

import '../../../model/entity/ads_DTO.dart';
import '../../../model/entity/ca_DTO.dart';
import '../../../model/entity/utente_DTO.dart';
import '../../../utils/jwt_constants.dart';
import '../../../utils/jwt_utils.dart';
import '../service/autenticazione_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' as shelf_router;

import '../service/autonticazione_service_impl.dart';

class AutenticazioneController {
  late final AutenticazioneService _authService;
  late final shelf_router.Router _router;

  AutenticazioneController() {
    _authService = AutenticazioneServiceImpl();
    _router = shelf_router.Router();
    _router.post('/login', _login);
    _router.post('/deleteUtente', _deleteUtente);
    _router.post('/listaUtenti', _listaUtenti);
    _router.post('/visualizzaUtente', _visualizzaUtente);
    _router.post('/modifyUtente', _modifyUtente);
    _router.post('/addImage', _uploadImage);
    _router.post('/checkUserUtente', _checkUserUtente);
    _router.post('/checkUserCA', _checkUserCA);
    _router.post('/checkUserADS', _checkUserADS);
    _router.all('/<ignored|.*>', _notFound);
  }

  shelf_router.Router get router => _router;

  Future<Response> _login(Request request) async {
    try {
      String requestBody = await request.readAsString();

      Map<String, dynamic> requestData = jsonDecode(requestBody);

      final String username = requestData['email'];
      final String password = requestData['password'];

      // Esegui l'autenticazione
      final dynamic user = await _authService.login(username, password);
      if (user != null) {
        String jwtToken = '';
        if (user is UtenteDTO) {
          jwtToken = JWTUtils.generateAccessToken(
              username: username,
              secretKey: JWTConstants.accessTokenSecretKeyForUtente,
              userType: "Utente",
              userId: user.id.toString());
        } else if (user is CaDTO) {
          jwtToken = JWTUtils.generateAccessToken(
              username: username,
              secretKey: JWTConstants.accessTokenSecretKeyForCA,
              userType: "CA",
              userId: user.id.toString());
        } else if (user is AdsDTO) {
          jwtToken = JWTUtils.generateAccessToken(
              username: username,
              secretKey: JWTConstants.accessTokenSecretKeyForADS,
              userType: "ADS",
              userId: user.id.toString());
        }
        final responseBody = jsonEncode({'token': jwtToken});
        return Response.ok(responseBody,
            headers: {'Content-Type': 'application/json'});
      } else {
        return Response.forbidden('Credenziali non valide');
      }
    } catch (e) {
      return Response.internalServerError(body: 'Errore durante il login: $e');
    }
  }

  Future<Response> _deleteUtente(Request request) async {
    try {
      final String requestBody = await request.readAsString();
      final Map<String, dynamic> params = jsonDecode(requestBody);

      String username = params['username'] ?? '';

      if (await _authService.deleteUtente(username)) {
        final responseBody = jsonEncode({'result': "Eliminazione effettuata."});
        return Response.ok(responseBody,
            headers: {'Content-Type': 'application/json'});
      } else {
        final responseBody =
            jsonEncode({'result': 'Eliminazione non effettuata'});
        return Response.badRequest(
            body: responseBody, headers: {'Content-Type': 'application/json'});
      }
    } catch (e) {
      // Gestione degli errori durante la chiamata al servizio
      return Response.internalServerError(
          body: 'Errore durante l\'eliminazione dell\'utente: $e');
    }
  }

  Future<Response> _listaUtenti(Request request) async {
    try {
      final List<UtenteDTO> listaUser = await _authService.listaUtenti();
      final responseBody = jsonEncode({'utenti': listaUser});
      return Response.ok(responseBody,
          headers: {'Content-Type': 'apllication/json'});
    } catch (e) {
      return Response.internalServerError(
          body: 'Errore durante la visualizzazzione della richiesta');
    }
  }

  _visualizzaUtente(Request request) async {
    try {
      final String requestBody = await request.readAsString();
      final Map<String, dynamic> params = jsonDecode(requestBody);
      String username = params['user'];

      UtenteDTO? utente = await _authService.visualizzaUtente(username);

      if (utente != null) {
        final responseBody = jsonEncode({'result': utente});
        return Response.ok(responseBody,
            headers: {'Content-Type': 'application/json'});
      } else {
        final responseBody =
            jsonEncode({'result': 'visualizzazione non effettuata'});
        return Response.badRequest(
            body: responseBody, headers: {'Content-Type': 'application/json'});
      }
    } catch (e) {
      print(e);
      // Gestione degli errori durante la chiamata al servizio
      return Response.internalServerError(
          body: 'Errore durante l\'eliminazione dell\'utente: $e');
    }
  }

  Future<Response> _modifyUtente(Request request) async {
    try {
      final String requestBody = await request.readAsString();
      final Map<String, dynamic> params = jsonDecode(requestBody);
      final int id =
          params['id'] != null ? int.parse(params['id'].toString()) : 0;
      final String nome = params['nome'] ?? '';
      final String cognome = params['cognome'] ?? '';
      final String codFiscale = params['cod_fiscale'] ?? '';
      final DateTime? dataNascita = params['data_nascita'] != null
          ? DateTime.parse(params['data_nascita'])
          : null;
      final String luogoNascita = params['luogo_nascita'] ?? '';
      final String genere = params['genere'] ?? '';
      final String username = params['username'] ?? '';
      final String password = params['password'] ?? '';
      final String lavoroAdatto = params['lavoro_adatto'] ?? '';
      final String email = params['email'] ?? '';
      final String numTelefono = params['num_telefono'] ?? '';
      final String immagine = params['immagine'] ?? '';
      final String via = params['via'] ?? '';
      final String citta = params['citta'] ?? '';
      final String provincia = params['provincia'] ?? '';

      UtenteDTO utente = UtenteDTO(
          id: id,
          nome: nome,
          cognome: cognome,
          cod_fiscale: codFiscale,
          data_nascita: dataNascita!,
          luogo_nascita: luogoNascita,
          genere: genere,
          username: username,
          password: password,
          lavoro_adatto: lavoroAdatto,
          email: email,
          num_telefono: numTelefono,
          immagine: immagine,
          via: via,
          citta: citta,
          provincia: provincia);

      if (await _authService.modifyUtente(utente)) {
        final responseBody = jsonEncode({'result': "Modifica effettuata."});
        return Response.ok(responseBody,
            headers: {'Content-Type': 'application/json'});
      } else {
        final responseBody = jsonEncode({'result': 'Modifica non effettuata.'});
        return Response.badRequest(
            body: responseBody, headers: {'Content-Type': 'application/json'});
      }
    } catch (e) {
      // Gestione degli errori durante la chiamata al servizio
      return Response.internalServerError(
          body: 'Errore durante la modifica dell\'utente: $e');
    }
  }

  Future<Response> _uploadImage(Request request) async {
    try {
      if (!request.isMultipartForm) {
        return Response.badRequest(body: 'Tipo di contenuto non valido.');
      }

      final parts = request.parts;
      String? username;
      List<int>? imageData;

      await for (final part in parts) {
        if (part.headers.containsKey('content-disposition')) {
          final contentDisposition =
              HeaderValue.parse(part.headers['content-disposition']!);
          final name = contentDisposition.parameters['name'];

          if (name == 'username') {
            username = await part
                .toList()
                .then((value) => utf8.decode(value.expand((i) => i).toList()));
          } else if (name == 'immagine') {
            imageData = await part
                .toList()
                .then((value) => value.expand((i) => i).toList());
          }
        }
      }

      if (username != null && imageData != null) {
        final imagePath = 'images/image_$username.jpg';
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          // Elimina il file esistente
          await imageFile.delete();
        }
        await imageFile.writeAsBytes(imageData);

        return Response.ok('Immagine caricata con successo');
      } else {
        return Response.badRequest(body: 'Dati mancanti nella richiesta');
      }
    } catch (e) {
      return Response.internalServerError(body: 'Errore server: $e');
    }
  }

  Future<Response> _checkUserUtente(Request request) async {
    try {
      String requestBody = await request.readAsString();

      String token = jsonDecode(requestBody);

      if (await _authService.checkUserUtente(token)) {
        return Response.ok(jsonEncode({'result': " Successo"}));
      } else {
        return Response.badRequest(body: jsonEncode({'result': " Fallito "}));
      }
    } catch (e) {
      // Gestione degli errori durante la chiamata al servizio
      return Response.internalServerError(
          body: 'Errore durante la verifica del token: $e');
    }
  }

  Future<Response> _checkUserCA(Request request) async {
    try {
      String requestBody = await request.readAsString();

      String token = jsonDecode(requestBody);

      if (await _authService.checkUserCA(token)) {
        return Response.ok(jsonEncode({'result': " Successo"}));
      } else {
        return Response.badRequest(body: jsonEncode({'result': " Fallito "}));
      }
    } catch (e) {
      // Gestione degli errori durante la chiamata al servizio
      return Response.internalServerError(
          body: 'Errore durante la verifica del token: $e');
    }
  }

  Future<Response> _checkUserADS(Request request) async {
    try {
      String requestBody = await request.readAsString();

      String token = jsonDecode(requestBody);

      if (await _authService.checkUserADS(token)) {
        return Response.ok(jsonEncode({'result': " Successo"}));
      } else {
        return Response.badRequest(body: jsonEncode({'result': " Fallito "}));
      }
    } catch (e) {
      // Gestione degli errori durante la chiamata al servizio
      return Response.internalServerError(
          body: 'Errore durante la verifica del token: $e');
    }
  }

  Future<Response> _notFound(Request request) async {
    return Response.notFound('Endpoint non trovato',
        headers: {'Content-Type': 'text/plain'});
  }

  Map<String, dynamic> parseFormBody(String body) {
    final Map<String, dynamic> formData = {};
    final List<String> pairs = body.split("&");
    for (final String pair in pairs) {
      final List<String> keyValue = pair.split("=");
      if (keyValue.length == 2) {
        final String key = Uri.decodeQueryComponent(keyValue[0]);
        final String value = Uri.decodeQueryComponent(keyValue[1]);
        formData[key] = value;
      }
    }
    return formData;
  }
}
