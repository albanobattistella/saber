
import 'package:saber/data/flavor_config.dart';
import 'main_common.dart' as common;

void main() {
  FlavorConfig.setup(
    flavor: "fdroid",
    shouldCheckForUpdatesByDefault: false,
  );

  common.main();
}
