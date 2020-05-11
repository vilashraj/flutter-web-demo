import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MWListViewDm {
  String title;
  String subTitle;
  Map<String, String> searchMapParameters;
  Widget leading;
  Widget trailing;
  Widget child;
  String id;
  Function onTap;
  bool isSelected = false;

  MWListViewDm({
    @required this.title,
    @required this.id,
    this.subTitle,
    this.searchMapParameters,
    this.leading,
    this.trailing,
    this.child,
    this.onTap,
  }) : assert(id != null && title != null);
}

// ignore: must_be_immutable
class MWListView extends StatefulWidget {
  String title;
  List<MWListViewDm> items;
  Key key;
  Axis scrollDirection;
  bool reverse;
  ScrollController controller;
  bool primary;
  ScrollPhysics physics;
  bool shrinkWrap;
  EdgeInsetsGeometry padding;
  Widget separator;
  bool addAutomaticKeepAlives;
  bool addRepaintBoundaries;
  bool addSemanticIndexes;
  double cacheExtent;
  ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  int semanticChildCount;
  DragStartBehavior dragStartBehavior;
  double itemExtent;
  bool withAppBar;
  bool enableSearch;
  int searchDebounceMilliseconds;
  bool showCheckMarkForMultipleSelectionInLeading;
  bool showCheckMarkForMultipleSelectionInTrailing;
  List<Widget> appbarActions;
  bool allowSwipeToDismiss;
  bool allowMultipleSelection;

  MWListView(
      {this.key,
      this.title,
      this.items,
      this.separator,
      this.itemExtent,
      this.scrollDirection = Axis.vertical,
      this.reverse = false,
      this.allowSwipeToDismiss = false,
      this.allowMultipleSelection = false,
      this.showCheckMarkForMultipleSelectionInLeading = false,
      this.showCheckMarkForMultipleSelectionInTrailing = true,
      this.controller,
      this.primary,
      this.physics,
      this.withAppBar = true,
      this.enableSearch = true,
      this.shrinkWrap = false,
      this.padding,
        this.appbarActions,
      this.addAutomaticKeepAlives = true,
      this.addRepaintBoundaries = true,
      this.addSemanticIndexes = true,
      this.cacheExtent,
      this.semanticChildCount,
      this.searchDebounceMilliseconds = 1,
      this.dragStartBehavior = DragStartBehavior.start,
      this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual});

  @override
  _MWListViewState createState() => _MWListViewState();
}

class _MWListViewState extends State<MWListView> {
  Debouncer debouncer;
  List<MWListViewDm> originalList = List();
  List<MWListViewDm> filteredList = List();
  TextEditingController searchController = TextEditingController();

  bool enableMultiSelection = false;
  bool showCheckMarkForMultipleSelectionInLeading;
  bool showCheckMarkForMultipleSelectionInTrailing;

  @override
  void initState() {
    debouncer = Debouncer(
        milliseconds: widget.searchDebounceMilliseconds > 0
            ? widget.searchDebounceMilliseconds
            : 1);
    originalList = widget.items;
    filteredList = originalList;
    showCheckMarkForMultipleSelectionInLeading =
        widget.showCheckMarkForMultipleSelectionInLeading;
    showCheckMarkForMultipleSelectionInTrailing =
        widget.showCheckMarkForMultipleSelectionInTrailing;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  Widget getBody() {
    if (filteredList == null) {
      return errorContainer(error: "Items cannot be null.");
    }

    if (widget.semanticChildCount != null &&
        widget.semanticChildCount > filteredList.length) {
      return errorContainer(
          error:
              "Semantic Child Count should not be greater than number of items");
    }

    if(widget.withAppBar){
      return showListBodyWithAppBar();
    }
    return showListBodyWithoutAppBar();
  }

  Widget showListBodyWithAppBar(){
    return Scaffold(
        appBar: AppBar(
          title: getAppbarTitle(),
          leading: closeMultiSelectButton(),
          actions: enableMultiSelection?widget.appbarActions:null,
        ),
        body: getListAndSearchBar());
  }

  Widget getAppbarTitle(){
    if(enableMultiSelection){
      return Text(originalList.where((element) => element.isSelected).toList().length.toString() + " Selected");
    }
    return Text(widget.title??"");
  }

  Widget showListBodyWithoutAppBar(){
    return Scaffold(
        body: Column(
          children: <Widget>[
            actionContainer(),
            Expanded(child: getListAndSearchBar()),
          ],
        ));
  }

  Widget getListAndSearchBar(){
    return Column(
      children: <Widget>[
        widget.enableSearch
            ? TextField(
            controller: searchController,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0), hintText: "Search"),
            onChanged: (value) {
              applySearch(value);
            })
            : Container(),
        Expanded(child: getList()),
      ],
    );
  }

  applySearch(String value){
    debouncer.run(() {
      setState(() {
        filteredList = originalList.where((i) {
          if (i.title != null &&
              i.title
                  .trim()
                  .toLowerCase()
                  .contains(value.trim().toLowerCase())) {
            return true;
          }

          if (i.subTitle != null &&
              i.subTitle
                  .trim()
                  .toLowerCase()
                  .contains(value.trim().toLowerCase())) {
            return true;
          }

          for (String k in i.searchMapParameters.keys) {
            if (i.searchMapParameters[k] != null &&
                i.searchMapParameters[k]
                    .trim()
                    .toLowerCase()
                    .contains(value.trim().toLowerCase())) {
              return true;
            }
          }

          return false;
        }).toList();
      });
    });
  }

  Widget getList() {
    if (filteredList.isEmpty) {
      return emptyListContainer(error: "No Results Found");
    }
    if (widget.separator != null) {
      return getSeparatedList();
    }

    return getSimpleList();
  }

  Widget getSimpleList() {
    return ListView.builder(
        itemBuilder: (BuildContext context, int position) {
          return getListItem(position: position);
        },
        itemCount: filteredList.length,
        scrollDirection: widget.scrollDirection,
        key: widget.key,
        controller: widget.controller,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addSemanticIndexes: widget.addSemanticIndexes,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        reverse: widget.reverse,
        primary: widget.primary,
        cacheExtent: widget.cacheExtent,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        padding: widget.padding,
        dragStartBehavior: widget.dragStartBehavior,
        itemExtent: widget.itemExtent,
        semanticChildCount: widget.semanticChildCount);
  }

  Widget getSeparatedList() {
    return ListView.separated(
      itemBuilder: (BuildContext context, int position) {
        return getListItem(position: position);
      },
      separatorBuilder: (BuildContext context, int position) {
        return widget.separator;
      },
      itemCount: filteredList.length,
      controller: widget.controller,
      key: widget.key,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      cacheExtent: widget.cacheExtent,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      primary: widget.primary,
      reverse: widget.reverse,
      scrollDirection: widget.scrollDirection,
    );
  }

  Widget getListItem({@required int position}){
    return widget.allowSwipeToDismiss ? getDismissibleItem(position: position):getItem(position: position);
  }

  Widget getDismissibleItem({@required int position}){
    return Dismissible(
      background: stackBehindDismiss(),
      key: UniqueKey(),
     child: getItem(position: position),
      onDismissed:(direction) {
        var item = filteredList.elementAt(position);
        //To delete
        int pos = deleteItem(position);
        //To show a snackbar with the UNDO button
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Item deleted"),
            action: SnackBarAction(
                label: "UNDO",
                onPressed: () {
                  //To undo deletion
                  undoDeletion(position, item, pos);
                })));
      },
    );
  }

  int deleteItem(index){
    int pos = 0;
    setState((){
       pos = originalList.indexOf(filteredList[index]);
       originalList.removeAt(pos);
       applySearch(searchController.value.text);
    });
    return pos;
  }

  void undoDeletion(index, item, pos){
    setState((){
        originalList.insert(pos, item);
        applySearch(searchController.value.text);
    });
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }

  Widget getItem({@required int position}) {
    if (filteredList[position].child != null) {
      return GestureDetector(
        child: filteredList[position].child,
        onTap: filteredList[position].child ?? () {},
      );
    }

    return Container(
      color: filteredList[position].isSelected
          ? Colors.blue[50]
          : Colors.transparent,
      child: ListTile(
          selected: filteredList[position].isSelected,
          title: Text(filteredList[position].title ?? ""),
          subtitle: Text(filteredList[position].subTitle ?? ""),
          leading: getLeading(position),
          trailing: getTrailing(position),
          onTap: () => selectItem(position),
          onLongPress: () => enableMultiSelectionOnLongPress(position)),
    );
  }

  Widget errorContainer({@required String error}) {
    return Center(
      child: Text(
        error,
        style: TextStyle(color: Colors.red, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget emptyListContainer({@required String error}) {
    return Center(
      child: Text(
        error,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget getLeading(int position) {
    if (enableMultiSelection) {
       if (showCheckMarkForMultipleSelectionInLeading) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Checkbox(
                value: filteredList[position].isSelected,
                onChanged: (value) {
                  setState(() {
                    filteredList[position].isSelected = !filteredList[position].isSelected;
                  });
                }),
            filteredList[position].leading ?? Container(),
          ],
        );
      }
    }
    return filteredList[position].leading ?? Icon(Icons.person);
  }

  Widget getTrailing(int position) {
    if (enableMultiSelection) {
      if (showCheckMarkForMultipleSelectionInTrailing) {
        return Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              filteredList[position].trailing ?? Container(),
              Checkbox(
                  value: filteredList[position].isSelected,
                  onChanged: (value) {
                    setState(() {
                      filteredList[position].isSelected = !filteredList[position].isSelected;
                    });
                  },),
            ],
          ),
        );
      }
    }
    return filteredList[position].trailing;
  }

  actionContainer(){
    return enableMultiSelection?Container(
      color: Colors.grey[200],
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:<Widget>[
          closeMultiSelectButton(),
          Text(originalList.where((element) => element.isSelected).toList().length.toString()+" Selected",style: TextStyle(color: Colors.black, fontSize: 16),),
          Row(
            children:widget.appbarActions??[]
          ),
        ]
      ),
    ):Container(height: 0,);
  }

  closeMultiSelectButton(){
    return enableMultiSelection?IconButton(icon: Icon(Icons.close),onPressed: (){
      originalList.forEach((element) {
        element.isSelected = false;
      });
      setState((){
        enableMultiSelection = false;
      });
    },):null;
  }

  selectItem(int position) {
    if (enableMultiSelection) {
      setState(() {
        filteredList[position].isSelected = !filteredList[position].isSelected;
      });
    } else {
      filteredList[position].onTap ?? () {};
    }
  }

  enableMultiSelectionOnLongPress(int position) {
    if (!enableMultiSelection && widget.allowMultipleSelection) {
      setState(() {
        enableMultiSelection = true;
        filteredList[position].isSelected = !filteredList[position].isSelected;
      });
    }
  }


}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

List<MWListViewDm> dummyDataList = [
  MWListViewDm(
      id: "1",
      title: "Vilash",
      subTitle: "Patel",
      searchMapParameters: {"phone": "9428755666"}),
  MWListViewDm(
      id: "2",
      title: "Raj",
      subTitle: "Patel",
      searchMapParameters: {"phone": "9876543210"}),
  MWListViewDm(
      id: "3",
      title: "Bhagyesh",
      subTitle: "Shah",
      searchMapParameters: {"phone": "7016271391"}),
  MWListViewDm(
      id: "4",
      title: "Peter",
      subTitle: "England",
      searchMapParameters: {"phone": "9727855666"}),
  MWListViewDm(
      id: "5",
      title: "Shahrukh",
      subTitle: "Khan",
      searchMapParameters: {"phone": "9913055666"}),
  MWListViewDm(
      id: "6",
      title: "Harry",
      subTitle: "Potter",
      searchMapParameters: {"phone": "94287559939"}),
  MWListViewDm(
      id: "7",
      title: "Tom",
      subTitle: "Jerry",
      searchMapParameters: {"phone": "9425435666"}),
  MWListViewDm(
      id: "8",
      title: "Rock",
      subTitle: "Patel",
      searchMapParameters: {"phone": "9428799888"}),
  MWListViewDm(
      id: "9",
      title: "Mansukh",
      subTitle: "Patel",
      searchMapParameters: {"phone": "9123456789"}),
  MWListViewDm(
      id: "10",
      title: "Om",
      subTitle: "Prakash",
      searchMapParameters: {"phone": "789654312"}),
  MWListViewDm(
      id: "11",
      title: "John",
      subTitle: "Appleseed",
      searchMapParameters: {"phone": "84736457437"}),
];
