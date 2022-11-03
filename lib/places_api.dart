import 'dart:convert';

import 'package:http/http.dart' as http;

class PlacesAPIProvider{
  String sessionToken;
  final apiKey = '';

  PlacesAPIProvider(this.sessionToken);

  Future<List<Suggestion>> fetchSuggestions(String query) async{
    if(query.isNotEmpty){
      String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&types=geocode&key=$apiKey&sessiontoken=$sessionToken';

      final response = await http.get(Uri.parse(url));

      if(response.statusCode == 200){
        final result = json.decode(response.body);

        if(result['status' == 'OK']){
          return result['predictions'].map<Suggestion>((p) => Suggestion(p['placeId'], p['description'])).toList();
        }
        else{
          return [];
        }
      }
    }
    else{
      return [];
    }

    return [];
  }

}

class Suggestion{

  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);
}