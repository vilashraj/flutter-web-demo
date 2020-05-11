import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gun/list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(
//        title: Text(widget.title),
//      ),
      body: MWListView(
        items: dummyDataList,
        title: "MWListView Demo",
        enableSearch: true,
        allowMultipleSelection: true,
        showCheckMarkForMultipleSelectionInLeading: true,
        showCheckMarkForMultipleSelectionInTrailing: false,
        separator: Divider(),
        withAppBar: true,
        allowSwipeToDismiss: true,
        appbarActions: [IconButton(
          icon:Icon(Icons.delete,),
          onPressed:(){
            setState(() {
              dummyDataList.removeWhere((element) => element.isSelected);
            });
          }
        )],
      ),
    );
  }
}


