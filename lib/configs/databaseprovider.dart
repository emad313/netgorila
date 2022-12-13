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
          'mcc INTEGER,'
          'mnc INTEGER,'
          'cellname INTEGER,'
          'ci INTEGER,'
          'enb INTEGER,'
          'cid INTEGER,'
          'tac INTEGER,'
          'pci INTEGER,'
          'bandwidth INTEGER,'
          'cqi DOUBLE,'
          'rsrp DOUBLE,'
          'rsrpasu DOUBLE,'
          'rsrq DOUBLE,'
          'rssi DOUBLE,'
          'rssiasu DOUBLE,'
          'snr DOUBLE,'
          'timingadvance DOUBLE,'
          'dmb DOUBLE,'
          'lattitude DOUBLE,'
          'longitude DOUBLE,'
          'location TEXT,'
          ')');
    });
  }

  // Inser Netdata with functions parameters
  insert({
    String? technology,
    String? networkoperatorname,
    int? mcc,
    int? mnc,
    int? cellname,
    int? ci,
    int? enb,
    int? cid,
    int? tac,
    int? pci,
    int? bandwidth,
    double? cqi,
    double? rsrp,
    double? rsrpasu,
    double? rsrq,
    double? rssi,
    double? rssiasu,
    double? snr,
    double? timingadvance,
    double? dmb,
    double? lattitude,
    double? longitude,
    String? location,
  }) async {
    final db = await database;
    // var maxIdResult = await db!.rawQuery("SELECT MAX(id)+1 as last_inserted_id FROM Product"); 
    //   var id = maxIdResult.first["last_inserted_id"]; 
    var raw = await db!.rawInsert(
        'INSERT Into Netdata (technology, networkoperatorname, mcc, mnc, cellname, ci, enb, cid, tac, pci, bandwidth, cqi, rsrp, rsrpasu, rsrq, rssi, rssiasu, snr, timingadvance, dmb, lattitude, longitude, location)'
        ' VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
        [
          technology,
          networkoperatorname,
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
    int? mcc,
    int? mnc,
    int? cellname,
    int? ci,
    int? enb,
    int? cid,
    int? tac,
    int? pci,
    int? bandwidth,
    double? cqi,
    double? rsrp,
    double? rsrpasu,
    double? rsrq,
    double? rssi,
    double? rssiasu,
    double? snr,
    double? timingadvance,
    double? dmb,
    double? lattitude,
    double? longitude,
    String? location,
  }) async {
    final db = await database;
    var res = await db!.update("Netdata", {
      "technology": technology,
      "networkoperatorname": networkoperatorname,
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