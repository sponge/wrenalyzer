import "io" for Directory, File
import "os" for Process
import "./json" for JSON

import "./lexer" for Lexer
import "./parser" for Parser
import "./reporter" for JsonReporter, PrettyReporter, NullReporter
import "./resolver" for Resolver
import "./source_file" for SourceFile
import "./token" for Token
import "./ast" for ClassStmt, ImportStmt

class JSONASTPrinter {
  construct new () {}

  parseFile(path) {
//    System.print("Parsing %(path)")
    var code = File.read(path)
    var source = SourceFile.new(path, code)
    var lexer = Lexer.new(source)

//    while (true) {
//      var token = lexer.readToken()
//      System.print("%(token.type) '%(token.text)'")
//      if (token.type == Token.eof) break
//    }

    var parser = Parser.new(lexer, _reporter)
    var ast = parser.parseModule()

    var tree = []
    for (entry in ast.statements) {
        if (entry is ClassStmt) {
            for (m in entry.methods) {
                var params = []
                if (m.parameters != null) {
                    for (p in m.parameters) {
                        params.add(p.text)
                    }
                }
                tree.add({ "type":"method", "name":m.name.toString, "class":entry.name.toString, "params":params })
            }
        } else if (entry is ImportStmt) {
            tree.add({ "type":"import", "path":entry.path.toString.replace("\"", ""), "variables":[] })
        }
    }


    //for (entry in tree) {
    //    System.print(entry)
    //}

    System.print(JSON.stringify(tree))
  }

  processDirectory(path) {
    for (entry in Directory.list(path)) {
      if (entry.endsWith(".wren") && File.exists(entry)) {
        parseFile(entry)
      }
    }
  }

  run(arguments) {
     _reporter = NullReporter.new()

    if (arguments.count != 1) {
      System.print("Usage: json_ast <source file>")
      return
    }

    var path = arguments[0]
    if (Directory.exists(path)) {
      processDirectory(path)
    } else {
      parseFile(path)
    }
  }
}

JSONASTPrinter.new().run(Process.arguments)

