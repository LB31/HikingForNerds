import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hiking4nerds/components/map_widget.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hiking4nerds/services/routeparams.dart';

class LocationSelectionPage extends StatefulWidget {
  final RouteParamsCallback onPushRoutePreferences;

  LocationSelectionPage({@required this.onPushRoutePreferences});

  @override
  _LocationSelectionPageState createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  final GlobalKey<MapWidgetState> mapWidgetKey = GlobalKey<MapWidgetState>();
  String searchedLocation = "";

  Future<void> moveToCurrentLocation() async {
    LocationData currentLocation = await Location().getLocation();
    LatLng currentLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
    moveToLatLng(currentLatLng);

    List<Address> addresses = await Geocoder.local.findAddressesFromCoordinates(Coordinates(currentLatLng.latitude, currentLatLng.longitude));

    setState(() {
      searchedLocation = addresses[0].addressLine;
    });
  }

  Future<LatLng> queryToLatLng(String query) async {
    List<Address> addresses =
        await Geocoder.local.findAddressesFromQuery(query);
    Address first = addresses.first;
    return LatLng(first.coordinates.latitude, first.coordinates.longitude);
  }

  Future<String> queryToAddressName(String query) async {
    List<Address> addresses =
        await Geocoder.local.findAddressesFromQuery(query);
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
      appBar: AppBar(
        title: Text(LocalizationService().getLocalization(
            english: "Select your starting location",
            german: "Wähle deinen Startpunkt aus")), // TODO add localization
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          MapWidget(
            key: mapWidgetKey,
            isStatic: true,
          ),
          Center(
            heightFactor: 1.5,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              height: 60,
              child: GestureDetector(
                onTap: () async {
                  String query = await showSearch(
                      context: context, delegate: CustomSearchDelegate());
                  if (query != null && query.length > 0) {
                    searchedLocation = query;
                    moveToAddress(query);
                  }
                },
                child: Card(
                    elevation: 7,
                    shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(
                      Radius.circular(5.0),
                    )),
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                                child: Container(
                                    child: Text(searchBarText(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: Color(0xFF808080),
                                            fontSize: 16),
                                        textAlign: TextAlign.start))),
                            Center(
                                child: Icon(FontAwesomeIcons.search, size: 22,
                                    color: Color(0xFF808080)))
                          ],
                        ))),
              ),
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).size.height * 0.5 - 45 - 70,
              left: MediaQuery.of(context).size.width * 0.5 - 25,
              child: Icon(
                Icons.person_pin_circle,
                color: Colors.red,
                size: 50,
              )),
          Positioned(
            right: MediaQuery.of(context).size.width * 0.05,
            bottom: 16,
            child: SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                heroTag: "btn-gps",
                backgroundColor: htwGrey,
                child: Icon(Icons.gps_fixed),
                onPressed: () {
                  moveToCurrentLocation();
                },
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width * 0.5 - 35,
            child: SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                backgroundColor: htwGreen,
                heroTag: "btn-go",
                child: Icon(FontAwesomeIcons.check, size: 30),
                //child: Text("GO", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                onPressed: () {
                  LatLng routeStartingLocation = mapWidgetKey
                      .currentState.mapController.cameraPosition.target;
                  RouteParams routeParams = RouteParams(routeStartingLocation);
                  widget.onPushRoutePreferences(routeParams);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  String searchBarText() {
    return searchedLocation.isEmpty
        ? LocalizationService()
            .getLocalization(english: "Search", german: "Suche")
        : searchedLocation;
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
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
      tooltip: LocalizationService()
          .getLocalization(english: "Back", german: "Zurück"),
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
          final Iterable<String> suggestions = query.isEmpty
              ? _history
              : addressNames.isNotEmpty ? addressNames : List<String>();

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
          tooltip: LocalizationService()
              .getLocalization(english: "Clear", german: "Leeren"),
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

//Code taken from: https://stackoverflow.com/a/51322773/5630207
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onTap;
  final AppBar appBar;

  const CustomAppBar({Key key, this.onTap, this.appBar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: appBar);
  }

  // TODO: implement preferredSize
  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
