import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:compiler/compiler.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import '../utils.dart';

class DisassembleCommand extends Command<Future<void>> {
  @override
  final String name = 'disassemble';

  @override
  final String description = 'Disassemble a compiled program.';

  @override
  String get invocation =>
      '${runner!.executableName} $name <path/to/compiled/file>';

  @override
  Future<void> run() async {
    final String? compiledFilePathRaw = argResults!.rest.firstOrNull;
    if (compiledFilePathRaw == null) {
      printInvalidInvocation('Specify a file to disassemble.');
      return;
    }

    final String compiledFilePath = p.absolute(compiledFilePathRaw);
    final File compiledFile = File(compiledFilePath);
    if (!(await compiledFile.exists())) {
      print('Specified file "${compiledFile.path}" does not exist.');
      return;
    }

    try {
      final String content = await compiledFile.readAsString();
      final List<dynamic> parsed = json.decode(content) as List<dynamic>;
      final ProgramConstant program = ProgramConstant.deserialize(parsed);
      Disassembler.disassembleProgram(program);
    } catch (err) {
      print('Disassembling "${compiledFile.path}" failed.');
      println();
      print(err);
    }
  }
}
