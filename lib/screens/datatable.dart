import 'package:flutter/material.dart';
import 'package:json_table/json_table.dart';
import 'package:netgorila/configs/databaseprovider.dart';

class NetDataTable extends StatefulWidget {
  const NetDataTable({super.key});

  @override
  State<NetDataTable> createState() => _NetDataTableState();
}

class _NetDataTableState extends State<NetDataTable> {
  dynamic netalldata;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Netdata'),
      ),
      body: netalldata != null?JsonTable(
        netalldata,
        showColumnToggle: true,
        paginationRowCount: pagesCount,       
      ): const Center(child: CircularProgressIndicator()),  
    );
  }
}