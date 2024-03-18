import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: home_page(),
  ));
}

class home_page extends StatefulWidget {
  const home_page({super.key});

  @override
  State<home_page> createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: addDB,
            icon: const Icon(
              Icons.add,
              size: 40,
              color: Colors.white,
            )),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder(
        future: loadDataDB(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return bodyMaker(snapshot.data ?? []);
          } else {
            return const Center(
                child: CircularProgressIndicator(strokeWidth: 20));
          }
        },
      ),
    );
  }

  Future<bool> addDB() async {
    setState(() {});
    SharedPreferences pref = await SharedPreferences.getInstance();
    int counter = pref.getInt('counter') ?? 0;
    counter++;
    pref.setInt('counter', counter);
    if (kDebugMode) {
      print("app counter: $counter");
      print("DB  counter: ${pref.getInt('counter') ?? 0}");
    }
    List<String> dataList = pref.getStringList('dataList') ?? [];
    dataList.add("item $counter");
    pref.setStringList('dataList', dataList);
    print(pref.getStringList('dataList') ?? []);
    return true;
  }

  Future<List<String>> loadDataDB() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> dataList = pref.getStringList('dataList') ?? [];
    Future.delayed(const Duration(seconds: 30));
    return dataList;
  }

  Widget bodyMaker(List<String> dataList) {
    if (dataList.isEmpty) {
      return const Center(child: Text("no item found :("));
    } else {
      return ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              onLongPress: () async {
                deleteDB(index, true);
              },
              trailing: Text(dataList[index]),
              leading: IconButton(
                  onPressed: () async {
                    deleteDB(index, false);
                  },
                  icon: const Icon(Icons.cancel)),
            ),
          );
        },
      );
    }
  }

  deleteDB(int index, bool deleteAll) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> dataList = pref.getStringList('dataList') ?? [];
    print("dataList before delete: $dataList");
    if (deleteAll) {
      //
      dataList.clear();
      //
      int counter = pref.getInt('counter') ?? 0;
      counter = 0;
      pref.setInt('counter', counter);
    } else {
      dataList.removeAt(index);
    }
    pref.setStringList('dataList', dataList);
    print("dataList after delete: ${pref.getStringList('dataList') ?? []}");
    setState(() {});
  }
}
