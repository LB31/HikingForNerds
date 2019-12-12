import 'package:flutter/material.dart';
import 'package:hiking4nerds/components/hikingmapbox.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationSelection extends StatefulWidget {
  @override
  _LocationSelectionState createState() => _LocationSelectionState();
}

class _LocationSelectionState extends State<LocationSelection> {
  final GlobalKey<MapWidgetState> mapWidgetKey =
      new GlobalKey<MapWidgetState>();
  LatLng _location;

  Future<void> moveToCurrentLocation() async {
    LocationData currentLocation = await Location().getLocation();
    moveToLatLng(LatLng(currentLocation.latitude, currentLocation.longitude));
  }

  Future<LatLng> queryToLatLng(String query) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(query);
    var first = addresses.first;
    return LatLng(first.coordinates.latitude, first.coordinates.longitude);
  }

  Future<String> queryToAddressName(String query) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(query);
    return addresses.first.addressLine;
  }

  void moveToAddress(String query) async {
    LatLng latLng = await queryToLatLng(query);
    moveToLatLng(latLng);
    saveAddressToHistory(query);
  }

  void moveToLatLng(LatLng latLng) {
    mapWidgetKey.currentState.mapController
        .moveCamera(CameraUpdate.newLatLng(latLng));
    mapWidgetKey.currentState.mapController.moveCamera(CameraUpdate.zoomTo(14));
  }

  void saveAddressToHistory(query) async {
    String newHistoryEntry = await queryToAddressName(query);

    SharedPreferences.getInstance().then((prefs) {
      List<String> _history =
          prefs.getStringList("searchHistory") ?? List<String>();

      List<String> updatedHistory = [
        ...[newHistoryEntry],
        ..._history,
      ];

      //Remove duplicates from history
      updatedHistory = updatedHistory.toSet().toList();
      prefs.setStringList("searchHistory", updatedHistory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          MapWidget(
            key: mapWidgetKey,
            isStatic: true,
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5 - 45,
            left: MediaQuery.of(context).size.width * 0.5 - 25,
              child: Icon(
            Icons.person_pin_circle,
            color: Colors.red,
            size: 50,
          )),
          Positioned(
            right: 5,
            top: MediaQuery.of(context).size.height * 0.5,
            child: FloatingActionButton(
              heroTag: "btn-gps",
              child: Icon(Icons.gps_fixed),
              onPressed: () {
                moveToCurrentLocation();
              },
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width * 0.5 - 25,
            top: 15,
            child: IconButton(
              icon: Icon(Icons.search),
              iconSize: 50,
              onPressed: () async {
                var query = await showSearch(
                    context: context, delegate: CustomSearchDelegate());
                if (query.length > 0) {
                  moveToAddress(query);
                }
              },
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: "btn-search",
        child: Icon(Icons.directions_walk),
        onPressed: () {
          setState(() {
            _location =
                mapWidgetKey.currentState.mapController.cameraPosition.target;
          });
        },
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  List<String> _history = List<String>();

  CustomSearchDelegate() {
    //_history = <String>["Berlin Schoeneweide", "Japan", "Weserstraße 144", "Dettlef", "Avenue 1 12052"];

    SharedPreferences.getInstance().then((prefs) {
      _history = prefs.getStringList("searchHistory") ?? List<String>();
    });
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    String queryString = query;

    return FutureBuilder(
        future: queryString.length > 0
            ? Geocoder.local.findAddressesFromQuery(queryString)
            : Future.value(List<Address>()),
        builder: (BuildContext context, AsyncSnapshot<List<Address>> snapshot) {
          List<String> addressNames = List<String>();
          if (snapshot.connectionState == ConnectionState.done) {
            List<Address> addresses = List<Address>();
            if (snapshot.hasData) {
              addresses = snapshot.data;
            }
            addressNames = addresses.map((address) {
              return address.addressLine;
            }).toList();
          }
          final Iterable<String> suggestions =
              query.isEmpty ? _history : addressNames.isNotEmpty ? addressNames : List<String>();

          return _SuggestionList(
            query: query,
            suggestions: suggestions.map<String>((String i) => '$i').toList(),
            onSelected: (String suggestion) {
              query = suggestion;
              this.close(context, query);
            },
          );
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    this.close(context, query);
    return Text(query);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Clear',
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({this.suggestions, this.query, this.onSelected});

  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final String suggestion = suggestions[i];
        return ListTile(
          leading: query.isEmpty ? const Icon(Icons.history) : const Icon(null),
          title: RichText(
            text: TextSpan(
              text: suggestion.substring(0, query.length),
              style:
                  theme.textTheme.subhead.copyWith(fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: suggestion.substring(query.length),
                  style: theme.textTheme.subhead,
                ),
              ],
            ),
          ),
          onTap: () {
            onSelected(suggestion);
          },
        );
      },
    );
  }
}
