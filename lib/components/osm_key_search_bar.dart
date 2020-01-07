import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:search_widget/search_widget.dart';

import '../styles.dart';

class OSMKeySearchBar extends StatefulWidget {
  @override
  _OSMKeySearchBarState createState() => _OSMKeySearchBarState();
}

class _OSMKeySearchBarState extends State<OSMKeySearchBar> {
  List<String> osmKeys = <String>[
    'architecture',
    'bar',
    'basilica',
    'cathedral',
    'church',
    'exhibition',
    'gas station',
    'lake, ' 'monuments',
    'museum',
    'park',
    'river',
    'romanic',
    'school',
    'zoo',
  ];

  List<String> selectedKeys;

  @override
  Widget build(BuildContext context) {
    return SearchWidget<String>(
        dataList: osmKeys,
        hideSearchBoxWhenItemSelected: false,
        listContainerHeight: MediaQuery.of(context).size.height / 4,
        queryBuilder: (String query, List<String> list) {
          return list
              .where((String osmKey) =>
              osmKey.toLowerCase().contains(query.toLowerCase()))
              .toList();
        },
        popupListItemBuilder: (String osmKey) {
          return PopupListItemWidget(osmKey);
        },
        selectedItemBuilder:
            (String selectedOSMKey, VoidCallback deleteSelectedOSMKey) {
          if (selectedKeys.length < 3 && !selectedKeys.contains(selectedOSMKey))
            selectedKeys.add(selectedOSMKey);
          return SelectedItemsWidget(selectedOSMKey, deleteSelectedOSMKey,
              widget.parent.widget.routeParams.poi);
        },
        // widget customization
        noItemsFoundWidget: NoItemsFound(),
        textFieldBuilder:
            (TextEditingController controller, FocusNode focusNode) {
          return SearchTextField(controller, focusNode);
        });
  }
}

class SelectedItemsWidget extends StatefulWidget {
  final String selectedOSMKey;
  final VoidCallback deleteSelectedOSMKey;
  final List<String> selectedOSMKeys;

  SelectedItemsWidget(
      this.selectedOSMKey, this.deleteSelectedOSMKey, this.selectedOSMKeys);

  @override
  _SelectedItemsWidgetState createState() => _SelectedItemsWidgetState();
}

class _SelectedItemsWidgetState extends State<SelectedItemsWidget> {
  chips() {
    List<Widget> chips = List();
    widget.selectedOSMKeys.forEach((key) {
      chips.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: Chip(
          label: Text(key),
          backgroundColor: htwGreen,
          shadowColor: Colors.white,
          deleteIcon: Icon(Icons.close),
          onDeleted: () {
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
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
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