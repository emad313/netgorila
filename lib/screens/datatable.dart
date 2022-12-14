import 'package:flutter/material.dart';
import 'package:json_table/json_table.dart';
import 'package:netgorila/configs/databaseprovider.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;

class NetDataTable extends StatefulWidget {
  const NetDataTable({super.key});

  @override
  State<NetDataTable> createState() => _NetDataTableState();
}

class _NetDataTableState extends State<NetDataTable> {
  List<String> header = [];
  List<List<String>> rows = [];
  List netalldata =  [];
  int pagesCount = 25;
  @override
  void initState() {
    super.initState();
    DatabaseProvider.db.getAllNetdata().then((value){
      setState(() {
        netalldata = value;
      });
    });
  }

  exportToCSV(){
    // Get header from netalldata
    // ObjectKey(netalldata[0]);
    netalldata[0].forEach((key, value) {
      header.add(key);
    });
    // add header to rows
    rows.add(header);
    // Get rows from netalldata with list string
    for (var i = 0; i < netalldata.length; i++) {
      List<String> row = [];
      for (var j = 0; j < header.length; j++) {
        row.add(netalldata[i][header[j]].toString());
      }
      rows.add(row);
    }

    // Export to CSV
    exportCSV.myCSV(header, rows);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Netdata'),
        actions: [
          IconButton(
            onPressed: exportToCSV,
            icon: const Icon(Icons.download),
          )
        ],
      ),
      body: netalldata.isNotEmpty?JsonTable(
        netalldata,
        paginationRowCount: pagesCount,       
      ): const Center(child: CircularProgressIndicator()),  
    );
  }
}