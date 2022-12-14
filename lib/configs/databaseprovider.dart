import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p; 
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory(); 
      String path = p.join(documentsDirectory.path, "database.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE Netdata ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'technology TEXT,'
          'networkoperatorname TEXT,'
          'earfcn INTEGER,'
          'mcc INTEGER,'
          'mnc INTEGER,'
          'cellname TEXT,'
          'ci INTEGER,'
          'enb INTEGER,'
          'cid INTEGER,'
          'tac INTEGER,'
          'pci INTEGER,'
          'bandwidth INTEGER,'
          'cqi INTEGER,'
          'rsrp DOUBLE,'
          'rsrpasu INTEGER,'
          'rsrq DOUBLE,'
          'rssi INTEGER,'
          'rssiasu INTEGER,'
          'snr DOUBLE,'
          'timingadvance INTEGER,'
          'dmb INTEGER,'
          'lattitude DOUBLE,'
          'longitude DOUBLE,'
          'location TEXT'
          ')');
    });
  }

  // Inser Netdata with functions parameters
  insert({
    String? technology,
    String? networkoperatorname,
    int? earfcn,
    int? mcc,
    int? mnc,
    String? cellname,
    int? ci,
    int? enb,
    int? cid,
    int? tac,
    int? pci,
    int? bandwidth,
    int? cqi,
    double? rsrp,
    int? rsrpasu,
    double? rsrq,
    int? rssi,
    int? rssiasu,
    double? snr,
    int? timingadvance,
    int? dmb,
    double? lattitude,
    double? longitude,
    String? location,
  }) async {
    final db = await database;
    // var maxIdResult = await db!.rawQuery("SELECT MAX(id)+1 as last_inserted_id FROM Product"); 
    //   var id = maxIdResult.first["last_inserted_id"]; 
    var raw = await db!.rawInsert(
        'INSERT Into Netdata (technology, networkoperatorname, earfcn, mcc, mnc, cellname, ci, enb, cid, tac, pci, bandwidth, cqi, rsrp, rsrpasu, rsrq, rssi, rssiasu, snr, timingadvance, dmb, lattitude, longitude, location)'
        ' VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
        [
          technology,
          networkoperatorname,
          earfcn,
          mcc,
          mnc,
          cellname,
          ci,
          enb,
          cid,
          tac,
          pci,
          bandwidth,
          cqi,
          rsrp,
          rsrpasu,
          rsrq,
          rssi,
          rssiasu,
          snr,
          timingadvance,
          dmb,
          lattitude,
          longitude,
          location,
        ]);
    return raw;
  }
  // Update Netdata with functions parameters

  update({
    int? id,
    String? technology,
    String? networkoperatorname,
    int? earfcn,
    int? mcc,
    int? mnc,
    String? cellname,
    int? ci,
    int? enb,
    int? cid,
    int? tac,
    int? pci,
    int? bandwidth,
    int? cqi,
    double? rsrp,
    int? rsrpasu,
    double? rsrq,
    int? rssi,
    int? rssiasu,
    double? snr,
    int? timingadvance,
    int? dmb,
    double? lattitude,
    double? longitude,
    String? location,
  }) async {
    final db = await database;
    var res = await db!.update("Netdata", {
      "technology": technology,
      "networkoperatorname": networkoperatorname,
      "earfcn": earfcn,
      "mcc": mcc,
      "mnc": mnc,
      "cellname": cellname,
      "ci": ci,
      "enb": enb,
      "cid": cid,
      "tac": tac,
      "pci": pci,
      "bandwidth": bandwidth,
      "cqi": cqi,
      "rsrp": rsrp,
      "rsrpasu": rsrpasu,
      "rsrq": rsrq,
      "rssi": rssi,
      "rssiasu": rssiasu,
      "snr": snr,
      "timingadvance": timingadvance,
      "dmb": dmb,
      "lattitude": lattitude,
      "longitude": longitude,
      "location": location,
    }, where: "id = ?", whereArgs: [id]);
    return res;
  } 

  // Delete Netdata with functions parameters
  delete({int? id}) async {
    final db = await database;
    db!.delete("Netdata", where: "id = ?", whereArgs: [id]);
  }

  // Get Netdata with functions parameters
  getNetdata({int? id}) async {
    final db = await database;
    var res = await db!.query("Netdata", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? res.first : null;
  }

  // Get all Netdata
  Future<List<Map<String, dynamic>>> getAllNetdata() async {
    final db = await database;
    var res = await db!.query("Netdata");
    return res;
  }
}