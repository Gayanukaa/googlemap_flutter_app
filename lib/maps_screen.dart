import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_demo/places_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {

  final LatLng _initialPosition = const LatLng(7.056555656949024, 79.92517702281475);
  late LatLng user_current_position;
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  MapType _currentMapType = MapType.normal;
  
  TextEditingController _addressEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
      ),
      body: Stack(
        children: [
          Container(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 9,
              ),
              onMapCreated: _onMapCreate,
              markers: _markers,
              mapType: _currentMapType,
              onTap: (latLng){
                _onAddMarker(latLng);
              },
            ),
          ),
          Positioned(
              child: Container(
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 2
                    )
                  ]
                ),
                child: TypeAheadField<Suggestion>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _addressEditingController,
                    decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      hintText: 'Type Address',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 20),
                      isCollapsed: true
                    )
                  ),
                  hideOnEmpty: true,
                  hideOnLoading: true,
                  onSuggestionSelected: (selectedSuggestion){},
                  itemBuilder: (context, suggestion){
                    return GestureDetector(
                      onTap: (){},
                      child: ListTile(
                        title: Text(suggestion.description, style: const TextStyle(color: Colors.black),),
                      ),
                    );
                  },
                  suggestionsCallback: (pattern) async{
                    return await PlacesAPIProvider('23456').fetchSuggestions(pattern);
                  },
                ),
              )),
          Positioned(
              bottom: 8,
              left: 5,
              child: FloatingActionButton(
                  onPressed: () async {
                    await getUserCurrentPosition().then((value) async {
                      await _navigateToCameraPosition(value);
                    });
                  },
                  child: const Icon(Icons.my_location, color: Colors.white,)
              )
          ),
          Positioned(
              bottom: 8,
              left: 70,
              child: FloatingActionButton(
                  onPressed: (){
                    setState(() {
                      _currentMapType = (_currentMapType == MapType.normal) ? MapType.satellite : MapType.normal;
                    });
                  },
                  child: const Icon(Icons.map, color: Colors.white,)
              )
          )
        ],
      ),
    );
  }

  void _onMapCreate(GoogleMapController controller){
    _controller.complete(controller);
  }

  void _onAddMarker(LatLng position){
    setState(() {
      _markers.add(Marker(
          icon: BitmapDescriptor.defaultMarker,
          markerId: MarkerId(position.longitude.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: 'Marker',
            snippet: position.toString()
          ),
        )
      );
    });
  }

  Future<LatLng> getUserCurrentPosition() async{
    var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best
    );

    setState(() {
      user_current_position = LatLng(position.latitude, position.longitude);
    });

    return user_current_position;
  }

  Future _navigateToCameraPosition(LatLng position) async{
    final controller = await _controller.future;
    await controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: position,
                zoom: 12
            )
        )
    );

  }
}
