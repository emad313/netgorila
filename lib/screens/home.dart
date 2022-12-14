import 'dart:async';
import 'dart:convert';

import 'package:cell_info/CellResponse.dart';
import 'package:cell_info/SIMInfoResponse.dart';
import 'package:cell_info/cell_info.dart';
import 'package:cell_info/models/common/cell_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../configs/databaseprovider.dart';
import 'datatable.dart';

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

  String bandTypeCap = '';
  String bandTypeSmall = '';
  String nBandTypeCap = '';
  String nBandTypeSmall = '';

  bool loader = false;


  @override
  void initState() {
    super.initState();
    startTimer();
  }

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
        if (currentCellInFirstChip.type == 'LTE') {
          bandTypeCap = 'LTE';
          bandTypeSmall = 'lte';
        }else if (currentCellInFirstChip.type == 'WCDMA') {
          bandTypeCap = 'WCDMA';
          bandTypeSmall = 'wcdma';
        }else if (currentCellInFirstChip.type == 'GSM') {
          bandTypeCap = 'GSM';
          bandTypeSmall = 'gsm';
        }else if (currentCellInFirstChip.type == 'CDMA') {
          bandTypeCap = 'CDMA';
          bandTypeSmall = 'cdma';
        }else if (currentCellInFirstChip.type == 'NR') {
          bandTypeCap = 'NR';
          bandTypeSmall = 'nr';
        }else if (currentCellInFirstChip.type == 'TD_SCDMA') {
          bandTypeCap = 'TD_SCDMA';
          bandTypeSmall = 'td_scdma';
        }else{
          bandTypeCap = 'Unknown';
          bandTypeSmall = 'unknown';
        }
        if (currentCellInSecondChip.type == 'LTE') {
          nBandTypeCap = 'LTE';
          nBandTypeSmall = 'lte';
        }else if (currentCellInSecondChip.type == 'WCDMA') {
          nBandTypeCap = 'WCDMA';
          bandTypeSmall = 'wcdma';
        }else if (currentCellInSecondChip.type == 'GSM') {
          nBandTypeCap = 'GSM';
          nBandTypeSmall = 'gsm';
        }else if (currentCellInSecondChip.type == 'CDMA') {
          nBandTypeCap = 'CDMA';
          nBandTypeSmall = 'cdma';
        }else if (currentCellInSecondChip.type == 'NR') {
          nBandTypeCap = 'NR';
          nBandTypeSmall = 'nr';
        }else if (currentCellInSecondChip.type == 'TD_SCDMA') {
          nBandTypeCap = 'TD_SCDMA';
          nBandTypeSmall = 'td_scdma';
        }else{
          nBandTypeCap = 'Unknown';
          nBandTypeSmall = 'unknown';
        }

        primaryCellInfo = body['primaryCellList'][0];
        primarySimInfo = simJson['simInfoList'][0];
        neighborCellInfo = body['neighboringCellList'][0];
        neighborSimInfo = simJson['simInfoList'][1];

        loader = true;
        // insert to db with primaryCellInfo and primarySimInfo
        if (primaryCellInfo != null && primarySimInfo != null) {
          DatabaseProvider.db.insert(
              cellname: primaryCellInfo[bandTypeSmall]['band$bandTypeCap']['name'],
              networkoperatorname: primarySimInfo['displayName'],
              technology: primaryCellInfo['type'],
              earfcn: primaryCellInfo[bandTypeSmall]['band$bandTypeCap']['channelNumber'],
              mcc: primarySimInfo['mcc'],
              mnc: primarySimInfo['mnc'],
              ci: primaryCellInfo[bandTypeSmall]['eci'],
              cid: primaryCellInfo[bandTypeSmall]['cid'],
              bandwidth: primaryCellInfo[bandTypeSmall]['bandwidth'],
              pci: primaryCellInfo[bandTypeSmall]['pci'],
              tac: primaryCellInfo[bandTypeSmall]['tac'],
              cqi: primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['cqi'],
              dmb: primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['dbm'],
              enb: primaryCellInfo[bandTypeSmall]['enb'],
              snr: primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['snr'],
              rssi: primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['rssi'],
              rssiasu: primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['rssiAsu'],
              rsrq: primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['rsrq'],
              rsrp: primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['rsrp'],
              rsrpasu: primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['rsrpAsu'],
              lattitude: 0.0,
              longitude: 0.0,
              location: 'Dhaka',
              timingadvance: primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['timingAdvance'],
            );
        }
        // insert to db with neighborCellInfo and neighborSimInfo
        if (neighborCellInfo != null && neighborSimInfo != null) {
          DatabaseProvider.db.insert(
              cellname: neighborCellInfo[nBandTypeSmall]['band$nBandTypeCap']['name'],
              networkoperatorname: neighborSimInfo['displayName'],
              technology: neighborCellInfo['type'],
              earfcn: neighborCellInfo[nBandTypeSmall]['band$nBandTypeCap']['channelNumber'],
              mcc: neighborSimInfo['mcc'],
              mnc: neighborSimInfo['mnc'],
              ci: neighborCellInfo[nBandTypeSmall]['eci'],
              cid: neighborCellInfo[nBandTypeSmall]['cid'],
              bandwidth: neighborCellInfo[nBandTypeSmall]['bandwidth'],
              pci: neighborCellInfo[nBandTypeSmall]['pci'],
              tac: neighborCellInfo[nBandTypeSmall]['tac'],
              cqi: neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['cqi'],
              dmb: neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['dbm'],
              enb: neighborCellInfo[nBandTypeSmall]['enb'],
              snr: neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['snr'],
              rssi: neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['rssi'],
              rssiasu: neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['rssiAsu'],
              rsrq: neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['rsrq'],
              rsrp: neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['rsrp'],
              rsrpasu: neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['rsrpAsu'],
              lattitude: 0.0,
              longitude: 0.0,
              location: 'Dhaka',
              timingadvance: neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['timingAdvance'],
            );
        }
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
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NetDataTable()));
          }, icon: const Icon(Icons.equalizer)),
        ],
      ),
      body: ListView(
        children: [
          loader?Padding(
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
                            Expanded(child: Text("${primaryCellInfo[bandTypeSmall]['band$bandTypeCap']['name']}",
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
                                Text("CI: ${primaryCellInfo[bandTypeSmall]['eci']}"),
                                Text("eNb: ${primaryCellInfo[bandTypeSmall]['enb']}"),
                                Text("CID: ${primaryCellInfo[bandTypeSmall]['cid']}"),
                                Text("TAC: ${primaryCellInfo[bandTypeSmall]['tac']}"),
                                Text("PCI: ${primaryCellInfo[bandTypeSmall]['pci']}"),
                                Text("Bandwidth: ${primaryCellInfo[bandTypeSmall]['bandwidth']}"),
                                ]
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text("EARFCN: ${primaryCellInfo[bandTypeSmall]['band$bandTypeCap']['channelNumber']}"),
                                Text("CQI: ${primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['cqi']} dbm"),
                                Text("RSRP: ${primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['rsrp']} dbm"),
                                Text("RSRPASU: ${primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['rsrpAsu']} dbm"),
                                Text("RSRQ: ${primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['rsrq']} dbm"),
                                Text("RSSI: ${primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['rssi']} dbm"),
                                Text("RSSIASU: ${primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['rssiAsu']} dbm"), 
                                Text("SNR: ${primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['snr']}"),
                                Text("TimingAdvance: ${primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['timingAdvance']} dbm"),
                                Text("DBM: ${primaryCellInfo[bandTypeSmall]['signal$bandTypeCap']['dbm']} dbm"),
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
                            Expanded(child: Text("${neighborCellInfo[nBandTypeSmall]['band$nBandTypeCap']['name']}",
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
                                Text("CI: ${neighborCellInfo[nBandTypeSmall]['eci']}"),
                                Text("eNb: ${neighborCellInfo[nBandTypeSmall]['enb']}"),
                                Text("CID: ${neighborCellInfo[nBandTypeSmall]['cid']}"),
                                Text("TAC: ${neighborCellInfo[nBandTypeSmall]['tac']}"),
                                Text("PCI: ${neighborCellInfo[nBandTypeSmall]['pci']}"),
                                Text("Bandwidth: ${neighborCellInfo[nBandTypeSmall]['bandwidth']}"),
                                ]
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text("EARFCN: ${neighborCellInfo[nBandTypeSmall]['band$nBandTypeCap']['channelNumber']}"),
                                Text("CQI: ${neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['cqi']} dbm"),
                                Text("RSRP: ${neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['rsrp']} dbm"),
                                Text("RSRPASU: ${neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['rsrpAsu']} dbm"),
                                Text("RSRQ: ${neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['rsrq']} dbm"),
                                Text("RSSI: ${neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['rssi']} dbm"),
                                Text("RSSIASU: ${neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['rssiAsu']} dbm"), 
                                Text("SNR: ${neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['snr']}"),
                                Text("TimingAdvance: ${neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['timingAdvance']} dbm"),
                                Text("DBM: ${neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['dbm']} dbm"),
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
          ): Container(),
          // Center(
          //   child: ElevatedButton(onPressed: (){
          //     checkFunction();
          //   },
          //   child: const Text("Get Cell Info")),
          // ),
        ],
      ),
    );
  }
      

  void startTimer() {
    const oneSec = Duration(seconds: 5);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        checkFunction();
      },
    );
  }
}