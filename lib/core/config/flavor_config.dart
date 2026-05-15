enum Flavor { basic, pro, advanced}

class FlavorConfig {
  final Flavor flavor;
  final String appTitle;

  static FlavorConfig? _instance;

  FlavorConfig._internal(this.flavor, this.appTitle);

  static void set(Flavor flavor, String title) {
    _instance = FlavorConfig._internal(flavor, title);
  }

  static FlavorConfig get instance => _instance!;
  static bool isPro() => _instance?.flavor == Flavor.pro;
  static bool isBasic() => _instance?.flavor == Flavor.basic;
  static bool isAdvanced() => _instance?.flavor == Flavor.advanced;
}