import 'dart:typed_data';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrinterHelper {
  // Fungsi untuk mendapatkan daftar printer yang sudah dipairing
  static Future<List<BluetoothInfo>> getBluetoothDevices() async {
    return await PrintBluetoothThermal.pairedBluetooths;
  }

  // Fungsi untuk menghubungkan ke printer
  static Future<bool> connect(String macAddress) async {
    return await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
  }

  // Fungsi cetak struk sederhana
  static Future<void> printStruk() async {
    bool isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected) {
      // Package ini menggunakan byte array (ESC/POS)
      // Kamu bisa memakai package 'esc_pos_utils_plus' untuk mempermudah formatnya
      // Tapi untuk tes simpel, kita kirim teks langsung:
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList("STRUK KASIR\n\n".codeUnits));
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList("Barang A   10.000\n".codeUnits));
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList("----------------\n".codeUnits));
      await PrintBluetoothThermal.writeBytes(Uint8List.fromList("TOTAL      10.000\n\n\n".codeUnits));
    }
  }
}