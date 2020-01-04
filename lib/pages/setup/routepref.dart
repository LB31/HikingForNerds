import 'package:flutter/material.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:search_widget/search_widget.dart';

class RoutePreferences extends StatefulWidget {
  final VoidCallback routeParams;
  final VoidCallback onPushRouteList;

  RoutePreferences({@required this.routeParams, @required this.onPushRouteList});

  @override
  _RoutePreferencesState createState() => _RoutePreferencesState();
}

class _RoutePreferencesState extends State<RoutePreferences> {
 
  double distance = 5.0; // default
  List<String> osmkeys = <String>[];
  List<String> altitudeOptions = <String>['N/A', 'minimum', 'high'];
  int selectedAltitude = 0;

  altitudeSelection(){
    List<Widget> optionsBar = List();
    altitudeOptions.forEach((opt) {
      int index = altitudeOptions.indexOf(opt);
      optionsBar.add(
      FlatButton(
        child: Text(altitudeOptions[index]),
        color: index == selectedAltitude ? htwGreen : htwGrey,
        onPressed: (){
          setState(() {
            selectedAltitude = index;            
          });
        }, 
      ));
    });
    return optionsBar;
  }

  @override
  Widget build(BuildContext context) {
    double maxValue = 30.0; // max value for distance and divisions
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Setup'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  'Select Route Distance',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.left,
                ),
                Row(
                  children: <Widget>[
                    Flexible (
                      flex: 1,
                      child: Slider.adaptive(
                        activeColor: htwGreen,
                        inactiveColor: htwBlue,
                        value: distance,
                        min: 1.0,
                        max: maxValue,
                        divisions: maxValue.toInt(),
                        label: distance.toString(),
                        onChanged: (newDistance) {
                          setState(() => distance = newDistance.roundToDouble());
                        },
                      ),
                    ),
                    Container(
                        width: 60.0,
                        alignment: Alignment.center,
                        child: Text('${distance.toInt()}\nKM',
                            style: Theme.of(context).textTheme.display1),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 40, 10, 20),
            child: Divider(color: htwGrey,),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Select Points of Interest',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.left,
              ),
              OSMKeySearch(this),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 40, 10, 20),
            child: Divider(color: htwGrey),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Select Altitude Level',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.left,
              ),
              Wrap(
                children: altitudeSelection(),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 40, 10, 20),
          ),
          Container(
              child: RawMaterialButton(
                  onPressed: () => print('Calculating ${distance.toString()} route with ${osmkeys.length} item(s) and ${altitudeOptions[selectedAltitude]} altitude level'),
                  child: Text('GO'),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: htwGreen,
                  padding: const EdgeInsets.all(20.0),
                ),
                alignment: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }
}

class OSMKeySearch extends StatefulWidget {
  final _RoutePreferencesState parent;
  OSMKeySearch(this.parent);

  @override
  _OSMKeySearchState createState() => _OSMKeySearchState();
}

class _OSMKeySearchState extends State<OSMKeySearch> {

  List<String> osmkeys = <String>[
    'architecture', 'bar', 'church', 'exhibition', 'gas station', 'lake, ''monuments', 'museum', 'park', 'river', 'romanic', 'school', 'zoo',
  ];

  @override
  Widget build(BuildContext context) {
    return SearchWidget<String>(
      dataList: osmkeys,
      hideSearchBoxWhenItemSelected: false,
      listContainerHeight: MediaQuery.of(context).size.height / 4,
      queryBuilder: (String query, List<String> list) {
        return list.where((String osmkey) => osmkey.toLowerCase().contains(query.toLowerCase())).toList();
      },
      popupListItemBuilder: (String osmkey) {
        return PopupListItemWidget(osmkey);
      },
      selectedItemBuilder: (String selectedOSMKey, VoidCallback deleteSelectedOSMKey) {
        if(widget.parent.osmkeys.length < 3 && !widget.parent.osmkeys.contains(selectedOSMKey)) widget.parent.osmkeys.add(selectedOSMKey);
        return SelectedItemsWidget(selectedOSMKey, deleteSelectedOSMKey, widget.parent.osmkeys);
      },
      // widget customization
      noItemsFoundWidget: NoItemsFound(),
      textFieldBuilder: (TextEditingController controller, FocusNode focusNode) {
        return SearchTextField(controller, focusNode);
      });
  }
}

class SelectedItemsWidget extends StatefulWidget {
  final String selectedOSMKey;
  final VoidCallback deleteSelectedOSMKey;
  final List<String> selectedOSMKeys;

  SelectedItemsWidget(this.selectedOSMKey, this.deleteSelectedOSMKey, this.selectedOSMKeys);

  @override
  _SelectedItemsWidgetState createState() => _SelectedItemsWidgetState();
}

class _SelectedItemsWidgetState extends State<SelectedItemsWidget> {

    chips () {
      List<Widget> chips = List();
      widget.selectedOSMKeys.forEach((key) {
        chips.add(Container(
          padding: const EdgeInsets.all(2.0),
          child: Chip(
            label: Text(key),
            backgroundColor: htwGreen,
            shadowColor: Colors.white, 
            deleteIcon: Icon(Icons.close), 
            onDeleted: (){
              setState(() {
                widget.selectedOSMKeys.remove(key);
              });
            },        
          ),
        ));
      });
      return chips;
    }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: chips(),
    );
  }
}

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  SearchTextField(this.controller, this.focusNode);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0x4437474F)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme
                .of(context)
                .primaryColor),
          ),
          suffixIcon: Icon(Icons.search),
          border: InputBorder.none,
          hintText: "Search categories here (max 3)...",
          contentPadding: EdgeInsets.only(
            left: 16,
            right: 20,
            top: 14,
            bottom: 14,
          ),
        ),
      ),
    );
  }
}

class NoItemsFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.folder_open,
            size: 24,
            color: Colors.grey[900].withOpacity(0.7),
          ),
          SizedBox(width: 10.0),
          Text(
            "No Items Found",
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey[900].withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class PopupListItemWidget extends StatelessWidget {
  final String osmkey;

  PopupListItemWidget(this.osmkey);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        osmkey,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}