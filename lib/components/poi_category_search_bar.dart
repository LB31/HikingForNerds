import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:hiking4nerds/services/routing/poi_category.dart';
import 'package:search_widget/search_widget.dart';

import '../styles.dart';

class PoiCategorySearchBar extends StatefulWidget {
  final List<PoiCategory> selectedCategories;

  PoiCategorySearchBar({Key key, @required this.selectedCategories})
      : super(key: key);

  @override
  _PoiCategorySearchBarState createState() => _PoiCategorySearchBarState();
}

class _PoiCategorySearchBarState extends State<PoiCategorySearchBar> {
  
  List<String> categories = <String>[
    'architecture',
    'bar',
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
    'zoo',
  ];
  
  @override
  Widget build(BuildContext context) {
    return SearchWidget<PoiCategory>(
        dataList: PoiCategory.categories..sort((a, b) => a.name.compareTo(b.name)),
        hideSearchBoxWhenItemSelected: false,
        listContainerHeight: MediaQuery.of(context).size.height / 4,
        queryBuilder: (String query, List<PoiCategory> list) {
          return list.where((category) =>
              category.name.toLowerCase().startsWith(query.toLowerCase()));
        },
        popupListItemBuilder: (PoiCategory category) {
          return PopupListItemWidget(category);
        },
        selectedItemBuilder: (PoiCategory selectedCategory,
            VoidCallback onDeleteSelectedCategory) {
          if (widget.selectedCategories.length < 3 &&
              !widget.selectedCategories.contains(selectedCategory))
            widget.selectedCategories.add(selectedCategory);
          return SelectedItemsWidget(selectedCategory, onDeleteSelectedCategory,
              widget.selectedCategories);
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
  final PoiCategory selectedCategory;
  final List<PoiCategory> selectedCategories;
  final VoidCallback onDeleteSelectedCategory;

  SelectedItemsWidget(this.selectedCategory, this.onDeleteSelectedCategory,
      this.selectedCategories);

  @override
  _SelectedItemsWidgetState createState() => _SelectedItemsWidgetState();
}

class _SelectedItemsWidgetState extends State<SelectedItemsWidget> {
  List<Widget> generateChips() {
    List<Widget> chips = List();
    widget.selectedCategories.forEach((category) {
      chips.add(Chip(
        label: Text(category.name,
            style: TextStyle(fontSize: 16.0, color: Colors.white)),
        backgroundColor: category.color,
        deleteIcon: Icon(
          Icons.close,
          color: Colors.white,
        ),
        onDeleted: () {
          setState(() {
            widget.selectedCategories.remove(category);
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
          children: generateChips(),
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
          hintText: LocalizationService().getLocalization(english: 'Search POIs here (max. 3) ...', german: 'Suche nach POIs hier (max. 3)'),
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
            LocalizationService().getLocalization(english: 'No Items Found', german: 'Keine Elemente gefunden'),
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
  final PoiCategory category;

  PopupListItemWidget(this.category);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        category.name,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}
