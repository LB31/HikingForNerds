import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:search_widget/search_widget.dart';

import '../styles.dart';

class PoiCategorySearchBar extends StatefulWidget {
  final List<String> selectedCategories;

  PoiCategorySearchBar({Key key, @required this.selectedCategories})
      : super(key: key);

  @override
  _PoiCategorySearchBarState createState() => _PoiCategorySearchBarState();
}

// TODO Get full list of categories
class _PoiCategorySearchBarState extends State<PoiCategorySearchBar> {
  List<String> categories = <String>[
    'architecture',
    'bar',
    'basilica',
    'bus',
    'bus station',
    'cathedral',
    'church',
    'exhibition',
    'gas station',
    'lake',
    'monuments',
    'museum',
    'park',
    'river',
    'romanic',
    'school',
    'train',
    'train station',
    'viewpoint',
    'zoo',
  ];


  @override
  Widget build(BuildContext context) {
    return SearchWidget<String>(
        dataList: categories,
        hideSearchBoxWhenItemSelected: false,
        listContainerHeight: MediaQuery.of(context).size.height / 4,
        queryBuilder: (String query, List<String> list) {
          return list
              .where((String category) =>
                  category.toLowerCase().contains(query.toLowerCase()))
              .toList();
        },
        popupListItemBuilder: (String category) {
          return PopupListItemWidget(category);
        },
        selectedItemBuilder:
            (String selectedCategory, VoidCallback onDeleteSelectedCategory) {
          if (widget.selectedCategories.length < 3 && !widget.selectedCategories.contains(selectedCategory))
            widget.selectedCategories.add(selectedCategory);
          return SelectedItemsWidget(
              selectedCategory, onDeleteSelectedCategory, widget.selectedCategories);
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
  final String selectedCategory;
  final VoidCallback onDeleteSelectedCategory;
  final List<String> selectedCategories;

  SelectedItemsWidget(
      this.selectedCategory, this.onDeleteSelectedCategory, this.selectedCategories);

  @override
  _SelectedItemsWidgetState createState() => _SelectedItemsWidgetState();
}

class _SelectedItemsWidgetState extends State<SelectedItemsWidget> {
  chips() {
    List<Widget> chips = List();
    widget.selectedCategories.forEach((key) {
      chips.add(Chip(
        label: Text(key, style: TextStyle(fontSize: 16.0)),
        backgroundColor: htwGreen,
        deleteIcon: Icon(Icons.close),
        onDeleted: () {
          setState(() {
            widget.selectedCategories.remove(key);
          });
        },
      ));
    });
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Wrap(
          children: chips(),
          spacing: 4.0,
        ));
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
          hintText: "Search categories here (max. 3) ...",
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
            Icons.search,
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
  final String category;

  PopupListItemWidget(this.category);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        category,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}
