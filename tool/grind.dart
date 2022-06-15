import 'dart:convert';
import 'dart:io';
import 'package:charcode/ascii.dart';
import 'package:cli_pkg/cli_pkg.dart' as pkg;
import 'package:grinder/grinder.dart';
import 'package:source_span/source_span.dart';
import 'package:path/path.dart' as p;

export 'grind/sanity_check.dart';

void main(List<String> args) {
  pkg.humanName.value = 'Topl';
  pkg.botName.value = 'Topl Bot';
  pkg.botEmail.value = 'topl.bot.beep.boop@gmail.com';
  pkg.githubUser.fn = () => Platform.environment['GH_USER']!;
  pkg.githubPassword.fn = () => Platform.environment['GH_TOKEN']!;
  pkg.standaloneName.value = 'brambldart';
  pkg.githubReleaseNotes.fn = () => 'To install brambldart ${pkg.version}, download one of the packages below '
      'and [add it to your PATH][], or see [the Developer Hub website][] for full '
      'installation instructions.\n'
      '\n'
      '[add it to your PATH]: https://katiek2.github.io/path-doc/\n'
      '[the Developer Hub website]: https://topl.readme.io/docs/installing\n'
      '\n'
      '# Changes\n'
      '\n'
      '${pkg.githubReleaseNotes.defaultValue}';
  pkg.npmPackageJson.fn = () => json.decode(File('package/package.json').readAsStringSync()) as Map<String, dynamic>;
  pkg.npmReadme.fn = () => _readAndResolveMarkdown('package/README.npm.md');
  pkg.addAllTasks();
  grind(args);
}

@DefaultTask('Compile async code and reformat.')
@Depends(format)
void all() {}

@Task('Run the Dart formatter.')
void format() {
  Pub.run('dart_style', script: 'format', arguments: ['--overwrite', '--fix', '.']);
}

@Task('Installs dependencies from npm.')
void npmInstall() => run(Platform.isWindows ? 'npm.cmd' : 'npm', arguments: ['install']);

@Task('Runs the tasks that are required for running tests.')
@Depends(format, 'pkg-standalone-dev', 'pkg-npm-dev', npmInstall)
void beforeTest() {}

final _readAndResolveRegExp = RegExp(
    r'^<!-- +#include +([^\s]+) +'
    '"([^"\n]+)"'
    r' +-->$',
    multiLine: true);

/// Reads a Markdown file from [path] and resolves include directives.
///
/// Include directives have the syntax `"<!-- #include" PATH HEADER "-->"`,
/// which must appear on its own line. PATH is a relative file: URL to another
/// Markdown file, and HEADER is the name of a header in that file whose
/// contents should be included as-is.
String _readAndResolveMarkdown(String path) =>
    File(path).readAsStringSync().replaceAllMapped(_readAndResolveRegExp, (match) {
      late String included;
      try {
        included = File(p.join(p.dirname(path), p.fromUri(match[1]))).readAsStringSync();
      } on Exception catch (error) {
        _matchError(match, error.toString(), url: p.toUri(path));
      }

      late Match headerMatch;
      try {
        headerMatch = '# ${match[2]}'.allMatches(included).first;
        // ignore: avoid_catching_errors
      } on StateError {
        _matchError(match, 'Could not find header.', url: p.toUri(path));
      }

      var headerLevel = 0;
      var index = headerMatch.start;
      while (index >= 0 && included.codeUnitAt(index) == $hash) {
        headerLevel++;
        index--;
      }

      // The section goes until the next header of the same level, or the end
      // of the document.
      var sectionEnd = included.indexOf('#' * headerLevel, headerMatch.end);
      if (sectionEnd == -1) sectionEnd = included.length;

      return included.substring(headerMatch.end, sectionEnd).trim();
    });

/// Throws a nice [SourceSpanException] associated with [match].
void _matchError(Match match, String message, {Object? url}) {
  final file = SourceFile.fromString(match.input, url: url);
  throw SourceSpanException(message, file.span(match.start, match.end));
}
