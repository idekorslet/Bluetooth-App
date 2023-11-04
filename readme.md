## - Flutter Bluetooth App

App ini adalah versi upgrade dari projek [Flutter Bluetooth sebelumnya](https://github.com/idekorslet/Belajar-Flutter/tree/main/Flutter_Bluetooth_ESP32),
yang mana source code asalnya diambil dari [sini](https://blog.codemagic.io/creating-iot-based-flutter-app/)

This App is an upgraded version of the previous [Flutter Bluetooth project](https://github.com/idekorslet/Belajar-Flutter/tree/main/Flutter_Bluetooth_ESP32),
which the original source code is taken from [here](https://blog.codemagic.io/creating-iot-based-flutter-app/)
##
App yang ada disini bisa dibilang adalah versi mentahan, berbeda dengan versi yang saya upload di Playstore, jadi kalian bisa mengubah tampilan sesuai dengan yang kalian kehendaki.
Kalian bisa cek versi saya di link Playstore di bawah.

The app here is the raw version, different from the version I uploaded on the Playstore, so you can change the appearance according to what you want.
You can check my version on the Playstore link below.<br>

|  |
|--|
| <a href='https://play.google.com/store/apps/details?id=com.noobpro.bluetooth_dev_control&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Get it on Google Play' src='https://play.google.com/intl/id/badges/static/images/badges/en_badge_web_generic.png' width="240"/></a> |

## - Bluetooth Package:
flutter_bluetooth_serial: https://pub.dev/packages/flutter_bluetooth_serial

## - State Manager
State manager yang saya gunakan adalah [GetX](https://pub.dev/packages/get), tetapi dengan struktur yang seadanya.


The state manager that I use is [GetX](https://pub.dev/packages/get), but with a sober structure.

## - Notes
Total command setiap device di aplikasi ini adalah 4, tetapi yang digunakan cuma 2. Jika ingin mengganti nilai max command ditiap device, silahkan buka file constant.dart dan ganti nilai variabel <b>maxCommandCount</b>

The total command for each device in this application is 4, but only 2 are used. If you want to change the max command value for each device, please open the constant.dart file and change the value of the <b>maxCommandCount</b> variable

## - Additional Notes
untuk menonaktifkan permintaan akses lokasi ketika aplikasi pertama kali jalan, maka diperlukan edit file FlutterBluetoothSerialPlugin.java secara langsung,<br><br>

To disable location access requests when the application is first run, it is necessary to edit the FlutterBluetoothSerialPlugin.java file directly.

untuk lokasi file FlutterBluetoothSerialPlugin.java dikasus saya ada di:<br>
for the location of the FlutterBluetoothSerialPlugin.java file in my case it is at:
```dart
Project Folder --> External Library --> Flutter Plugins --> flutter_bluetooth_serial-0.40/android.src.main.java.io.github.edufolly.flutterbluetoothserial
```
<br>
source: https://github.com/edufolly/flutter_bluetooth_serial/pull/152/files

## - Untuk Android Terbaru / For The Newest Android
1. Ikuti langkah "Additional Notes" / Follow "Additional Notes" step
2. Tambahkan file permission_request.dart ke projek / add permission_request.dart file into current project.<br>
    link: https://github.com/idekorslet/Bluetooth-App/blob/main/newest_android/
    
3. - Edit method initBluetooth() dan method enableBluetooth() yang ada di file bluetooth_data.dart dan bandingkan dengan file bluetooth_data.dart yang baru (bisa dilihat di link dibawah) <br>
   - Edit initBluetooth() & enableBluetooth() method which is in the bluetooth_data.dart and compare it with the newest bluetooth_data.dart file (check this link below):<br>
   https://github.com/idekorslet/Bluetooth-App/blob/main/newest_android/

4. Edit AndroidManifest.xml, lokasi ada di / Edit AndroidManifest.xml file, location path:
```dart
   Project Folder --> External Library --> Flutter Plugins --> flutter_bluetooth_serial-0.40/android.src/
```
  &nbsp;&nbsp;&nbsp;&nbsp;menjadi seperti ini / become like this:
```xml
  <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
  <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
  <uses-permission android:name="android.permission.BLUETOOTH" />
  <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

## - Support
|  |  |  |
|--|--|--|
| <a href="https://saweria.co/idekorslet"><img alt="saweria" width="240" src="https://user-images.githubusercontent.com/80518183/216806553-4a11d0ef-6257-461b-a3f2-430910574269.svg"></a> | | <a href="https://buymeacoffee.com/idekorslet"><img alt='Buy me a coffee' width="240" src="https://user-images.githubusercontent.com/80518183/216806363-a11d0282-517a-4512-9733-567e0d547078.png"> </a> |
