import 'package:flutter/material.dart';
import 'package:movieflutter/src/models/pelicula_model.dart';
import 'package:movieflutter/src/providers/peliculas_providers.dart';

class DataSearch extends SearchDelegate {


  String seleccion = "";
  final peliculasProvider = new PeliculasProvider();

  final peliculas = [
    "Rapidos y furiosos",
    "El rey leon",
    "The Oldman and The Gun",
    "Hellboy",
    "Spiderman",
    "Avengers",
    "El Hijo"
  ];
  final peliculasrecientes = [
    "Spiderman",
    "Capitan America"
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    // Acciones de nuestro Appbar
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: (){
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Icono a la izquierda de Appbar
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: (){
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Crear los resultados que vamos a mostrar
    return Center(
      child: Container(
        height: 100.0,
        width: 100.0,
        color: Colors.blueAccent,
        child: Text(seleccion),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Las sugerencias que aparecen cuando la persona escribe
    /*
    final listaSugerida = (query.isEmpty) 
                          ? peliculasrecientes 
                          : peliculas.where(
                            (p) => p.toLowerCase().startsWith(query.toLowerCase())
                          ).toList(); 

    return ListView.builder(
      itemCount: listaSugerida.length,
      itemBuilder: (context, i){
        return ListTile(
          leading: Icon(Icons.movie),
          title: Text(listaSugerida[i]),
          onTap: (){
            seleccion = listaSugerida[i];
            showResults(context);
          },
        );
      },
    );
    */
    if(query.isEmpty) return Container();

    return FutureBuilder(
      future: peliculasProvider.buscarPelicula(query),
      builder: (BuildContext context, AsyncSnapshot<List<Pelicula>> snapshot) {
        if(snapshot.hasData){

          final peliculas = snapshot.data;

          return ListView(
            children: peliculas.map((pelicula){
              return ListTile(
                leading: FadeInImage(
                  image: NetworkImage(pelicula.getPosterImg()),
                  placeholder: AssetImage("assets/img/no-image.jpg"),
                  width: 25.0,
                  fit: BoxFit.contain,
                ),
                title: Text(pelicula.title),
                subtitle: Text(pelicula.originalTitle),
                onTap: (){
                  close(context, null);
                  pelicula.uniqueId = "";
                  Navigator.pushNamed(context, 'detalle', arguments: pelicula);
                },
              );
            }).toList(),
          );
        }else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );

  }

}