import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterHelper {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  void printTest() async {
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected == true) {
      bluetooth.printCustom("STRUK KASIR", 3, 1);
      bluetooth.printNewLine();
      bluetooth.printLeftRight("Barang A", "10.000", 1);
      bluetooth.paperCut();
    }
  }
}