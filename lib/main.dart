import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:cell_info/CellResponse.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cell_info/cell_info.dart';
import 'package:cell_info/models/common/cell_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../configs/databaseprovider.dart';
import 'screens/datatable.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}
const notificationChannelId = 'my_foreground';
const notificationId = 888;
// initialize service

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'NET GORILLA SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // if (Platform.isIOS) {
  //   await flutterLocalNotificationsPlugin.initialize(
  //     const InitializationSettings(
  //       iOS: IOSInitializationSettings(),
  //     ),
  //   );
  // }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,
      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'NET GORILLA',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        flutterLocalNotificationsPlugin.show(
          notificationId,
          'NET GORILLA',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        // if you don't using custom notification, uncomment this
        // service.setForegroundNotificationInfo(
        //   title: "My App Service",
        //   content: "Updated at ${DateTime.now()}",
        // );
      }
    }

    /// you can see this log in logcat
    // print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');



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
      dynamic primaryCellInfo;
      dynamic neighborCellInfo;
      dynamic primarySimInfo;
      dynamic neighborSimInfo;

      String bandTypeCap = '';
      String bandTypeSmall = '';
      String nBandTypeCap = '';
      String nBandTypeSmall = '';

      double lat = 0;
      double lon = 0;
      var getLocation = _determinePosition();
      await getLocation.then((currentlocation) => {
              lat = currentlocation.latitude,
              lon = currentlocation.longitude
          });

          List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
              Placemark place = placemarks[0];
              String currentLocation = '${place.street}, ${place.subLocality},${place.subAdministrativeArea}, ${place.postalCode}';

          
      
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
              lattitude: lat,
              longitude: lon,
              location: currentLocation,
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
              lattitude: lat,
              longitude: lon,
              location: currentLocation,
              timingadvance: neighborCellInfo[nBandTypeSmall]['signal$nBandTypeCap']['timingAdvance'],
            );
        }
      
    } on PlatformException {
      debugPrint('Failed to get battery level.');
    }



    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
      },
    );
  });
}

Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Net Gorilla',
      theme: ThemeData(
        brightness: Brightness.light,
        /* light theme settings */
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.dark,
      home: const Home(),
    );
  }
}
