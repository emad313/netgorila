import 'dart:async';
import 'dart:convert';

import 'package:cell_info/CellResponse.dart';
import 'package:cell_info/SIMInfoResponse.dart';
import 'package:cell_info/cell_info.dart';
import 'package:cell_info/models/common/cell_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CellsResponse _cellsResponse = CellsResponse();
  late Timer timer;
  dynamic primaryCellInfo;
  dynamic neighborCellInfo;
  dynamic primarySimInfo;
  dynamic neighborSimInfo;


  @override
  void initState() {
    super.initState();
    startTimer();
  }

  String currentDBM = "";

  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformState() async {
  //   CellsResponse cellsResponse;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   String? platformVersion = await CellInfo.getCellInfo;
  //     final body = json.decode(platformVersion!);
  //     cellsResponse = CellsResponse.fromJson(body);
  //   try {
  //     CellType currentCellInFirstChip = cellsResponse.primaryCellList![0];
  //     if (currentCellInFirstChip.type == "LTE") {
  //       currentDBM = "LTE dbm = ${currentCellInFirstChip.lte!.signalLTE!.dbm}";
  //     } else if (currentCellInFirstChip.type == "NR") {
  //       currentDBM =
  //           "NR dbm = ${currentCellInFirstChip.nr!.signalNR!.dbm}";
  //     } else if (currentCellInFirstChip.type == "WCDMA") {
  //       currentDBM = "WCDMA dbm = ${currentCellInFirstChip.wcdma!.signalWCDMA!.dbm}";

  //       if (kDebugMode) {
  //         print('currentDBM = $currentDBM');
  //       }
  //     }

  //     String? simInfo = await CellInfo.getSIMInfo;
  //     final simJson = json.decode(simInfo!);
  //     if (kDebugMode) {
  //       print(
  //         "desply name ${SIMInfoResponse.fromJson(simJson).simInfoList![0].displayName}");
  //     }
  //   } on PlatformException {
  //     _cellsResponse = 'Failed to get platform version.' as CellsResponse;
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _cellsResponse = cellsResponse;
  //   });
  // }

  var data;

  checkFunction() async {
    CellsResponse cellsResponse;
    try {
      
    // Platform messages may fail, so we use a try/catch PlatformException.
    String? platformVersion = await CellInfo.getCellInfo;
      final body = json.decode(platformVersion!);
      cellsResponse = CellsResponse.fromJson(body);
      CellType currentCellInFirstChip = cellsResponse.primaryCellList![0];
      CellType currentCellInSecondChip = cellsResponse.neighboringCellList![0];
      



      String? simInfo = await CellInfo.getSIMInfo;
      final simJson = json.decode(simInfo!);
      setState(() {
        // data = body;
        primaryCellInfo = body['primaryCellList'][0];
        neighborCellInfo = body['neighboringCellList'][0];
        primarySimInfo = simJson['simInfoList'][0];
        neighborSimInfo = simJson['simInfoList'][1];
      });
      
    } on PlatformException {
      printsome('Failed to get platform version.');
    }
  }

  printsome(obj){
    if (kDebugMode) {
      print(obj);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Net Goriala'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    primaryCellInfo != null? Column(
                      children: [
                        Row(
                          children:  [
                            const Expanded(child: Text("Primary Cell Info")),
                            Expanded(child: Text("${primaryCellInfo['lte']['bandLTE']['name']}",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold
                            ),
                             )),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(child: Text("${primarySimInfo['displayName']}",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold
                            ),
                            
                            )),
                            Expanded(child: Text("mcc: ${primarySimInfo['mcc']}")),
                            Expanded(child: Text("mnc: ${primarySimInfo['mnc']}")),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: Text("${primarySimInfo['subscriptionInfoNumber']}")),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text("Cell Type: ${primaryCellInfo['type']}"),
                                Text("CI: ${primaryCellInfo['lte']['eci']}"),
                                Text("eNb: ${primaryCellInfo['lte']['enb']}"),
                                Text("CID: ${primaryCellInfo['lte']['cid']}"),
                                Text("TAC: ${primaryCellInfo['lte']['tac']}"),
                                Text("PCI: ${primaryCellInfo['lte']['pci']}"),
                                Text("Bandwidth: ${primaryCellInfo['lte']['bandwidth']}"),
                                ]
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text("CQI: ${primaryCellInfo['lte']['signalLTE']['cqi']} dbm"),
                                Text("RSRP: ${primaryCellInfo['lte']['signalLTE']['rsrp']} dbm"),
                                Text("RSRPASU: ${primaryCellInfo['lte']['signalLTE']['rsrpAsu']} dbm"),
                                Text("RSRQ: ${primaryCellInfo['lte']['signalLTE']['rsrq']} dbm"),
                                Text("RSSI: ${primaryCellInfo['lte']['signalLTE']['rssi']} dbm"),
                                Text("RSSIASU: ${primaryCellInfo['lte']['signalLTE']['rssiAsu']} dbm"), 
                                Text("SNR: ${primaryCellInfo['lte']['signalLTE']['snr']}"),
                                Text("TimingAdvance: ${primaryCellInfo['lte']['signalLTE']['timingAdvance']} dbm"),
                                Text("DBM: ${primaryCellInfo['lte']['signalLTE']['dbm']} dbm"),
                                ]
                              ),
                            ),
                          ],
                        ),
                          ],
                    ) : Container(),
                    const Divider(
                      thickness: 2,
                    ),
                    neighborCellInfo != null? Column(
                      children: [
                        Row(
                          children:  [
                            const Expanded(child: Text("Neighbor Cell Info")),
                            Expanded(child: Text("${neighborCellInfo['lte']['bandLTE']['name']}",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold
                            ),
                             )),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(child: Text("${neighborSimInfo['displayName']}",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold
                            ),
                            
                            )),
                            Expanded(child: Text("mcc: ${neighborSimInfo['mcc']}")),
                            Expanded(child: Text("mnc: ${neighborSimInfo['mnc']}")),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: Text("${neighborSimInfo['subscriptionInfoNumber']}")),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text("Cell Type: ${neighborCellInfo['type']}"),
                                Text("CI: ${neighborCellInfo['lte']['eci']}"),
                                Text("eNb: ${neighborCellInfo['lte']['enb']}"),
                                Text("CID: ${neighborCellInfo['lte']['cid']}"),
                                Text("TAC: ${neighborCellInfo['lte']['tac']}"),
                                Text("PCI: ${neighborCellInfo['lte']['pci']}"),
                                Text("Bandwidth: ${neighborCellInfo['lte']['bandwidth']}"),
                                ]
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text("CQI: ${neighborCellInfo['lte']['signalLTE']['cqi']} dbm"),
                                Text("RSRP: ${neighborCellInfo['lte']['signalLTE']['rsrp']} dbm"),
                                Text("RSRPASU: ${neighborCellInfo['lte']['signalLTE']['rsrpAsu']} dbm"),
                                Text("RSRQ: ${neighborCellInfo['lte']['signalLTE']['rsrq']} dbm"),
                                Text("RSSI: ${neighborCellInfo['lte']['signalLTE']['rssi']} dbm"),
                                Text("RSSIASU: ${neighborCellInfo['lte']['signalLTE']['rssiAsu']} dbm"), 
                                Text("SNR: ${neighborCellInfo['lte']['signalLTE']['snr']}"),
                                Text("TimingAdvance: ${neighborCellInfo['lte']['signalLTE']['timingAdvance']} dbm"),
                                Text("DBM: ${neighborCellInfo['lte']['signalLTE']['dbm']} dbm"),
                                ]
                              ),
                            ),
                          ],
                        ),
                          ],
                    ) : Container(),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: ElevatedButton(onPressed: (){
              checkFunction();
            },
            child: const Text("Get Cell Info")),
          ),
        ],
      ),
    );
  }
      

  void startTimer() {
    const oneSec = Duration(seconds: 3);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        checkFunction();
      },
    );
  }
}