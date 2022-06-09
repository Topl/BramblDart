import 'dart:io';

import 'package:bip_topl/src/utils/utils.dart';
import 'package:grinder/grinder.dart';
import 'package:cli_pkg/cli_pkg.dart' as pkg;

@Task('verify that the package is in a good state to release')
void sanityCheckBeforeRelease() {
  final ref = environment('GITHUB_REF');
  if (ref != 'refs/tags/${pkg.version}') {
    fail('GITHUB_REF $ref is different than pubspec version ${pkg.version}.');
  }

  if (listEquals(pkg.version.preRelease, ['dev'])) {
    fail('${pkg.version} is a dev release.');
  }

  final versionHeader = RegExp('^## ${RegExp.escape(pkg.version.toString())}\$', multiLine: true);
  if (!File('CHANGELOG.md').readAsStringSync().contains(versionHeader)) {
    fail("There's no CHANGELOG entry for ${pkg.version}.");
  }
}

/// Returns the environment variable named [name], or throws an exception if it
/// can't be found.
String environment(String name) {
  final value = Platform.environment[name];
  if (value == null) fail('Required environment variable $name not found.');
  return value;
}
