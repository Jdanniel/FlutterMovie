import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:movieflutter/src/models/actores_model.dart';
import 'package:movieflutter/src/models/pelicula_model.dart';

class PeliculasProvider{
  String _apikey = 'd2d180f9949f1fa8fd497430314f0f1f';
  String _url = 'api.themoviedb.org';
  String _language = 'es-ES';

  int _popularesPage = 0;
  bool _cargando     = false;

  List<Pelicula> _populares = new List();

  final _popularesStreamController = StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink => _popularesStreamController.sink.add;

  Stream<List<Pelicula>> get popularesStream => _popularesStreamController.stream;

  void disposeStreams(){
    _popularesStreamController?.close();
  }

  Future<List<Pelicula>> _procesarRespuesta(Uri url) async{
    final respuesta = await http.get(url);
    final decodeData = json.decode(respuesta.body);
    final peliculaPopular = new Peliculas.fromJsonList(decodeData['results']);
    return peliculaPopular.items;
  }

  Future<List<Pelicula>> getEnCines() async{
    final url = Uri.https(_url, '3/movie/now_playing',{
      'api_key' : _apikey,
      'language' : _language
    });
    return await _procesarRespuesta(url);
  }

  Future<List<Pelicula>> getPopular() async{
    if(_cargando) return [];
    _cargando = true;
    _popularesPage++;

    final url = Uri.https(_url, '3/movie/popular',{
      'api_key' : _apikey,
      'language' : _language,
      'page' : _popularesPage.toString()
    });

    final respuesta = await _procesarRespuesta(url);

    _populares.addAll(respuesta);
    popularesSink(_populares);
    _cargando = false;
    return respuesta;
  }

  Future<List<Actor>> getCast(String peliId) async{
    final url = Uri.https(_url, '3/movie/$peliId/credits',{
      'api_key' : _apikey,
      'language' : _language
    });
    final respuesta = await http.get(url);
    final decodedData =  json.decode(respuesta.body);

    final cast = new Cast.fromJsonList(decodedData['cast']);
    return cast.actores;
  }

  Future<List<Pelicula>> buscarPelicula(String query) async{
    final url = Uri.https(_url, '3/search/movie',{
      'api_key' : _apikey,
      'language' : _language,
      'query' : query
    });
    return await _procesarRespuesta(url);
  }


}