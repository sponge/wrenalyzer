import "io" for File

// Generates the boilerplate-y "ast.wren" file from a short description of the
// data stored in each AST node. This makes it much easier to add or change AST
// classes.

// TODO: Eventually want to store references to every relevant token in the AST
// nodes. Right now they have some, but not all.
var EXPRS = {
  "Assignment": ["target", "equal", "value"],
  "Bool": ["value"],
  "Call": ["receiver", "name", "arguments", "blockArgument"],
  "Conditional": ["condition", "question", "thenBranch", "colon", "elseBranch"],
  "Field": ["name"],
  "Grouping": ["leftParen", "expression", "rightParen"],
  "Infix": ["left", "operator", "right"],
  "Interpolation": ["strings", "expressions"],
  "List": ["leftBracket", "elements", "rightBracket"],
  "Map": ["leftBrace", "entries", "rightBrace"],
  "Null": ["value"],
  "Num": ["value"],
  "Prefix": ["operator", "right"],
  "StaticField": ["name"],
  "String": ["value"],
  "Subscript": ["receiver", "leftBracket", "arguments", "rightBracket"],
  "Super": ["name", "arguments", "blockArgument"],
  "This": ["keyword"]
}

var STMTS = {
  "Block": ["statements"],
  "Break": ["keyword"],
  "Class": ["foreignKeyword", "name", "superclass", "methods"],
  "For": ["variable", "iterator", "body"],
  "If": ["condition", "thenBranch", "elseBranch"],
  "Import": ["path", "variables"],
  "Return": ["keyword", "value"],
  "While": ["condition", "body"],
  "Var": ["name", "initializer"],
}

class AstBuilder {
  construct new() {}

  build() {
    _file = File.create("ast.wren")

    writeLine("class Node {}

class Expr is Node {}

class Stmt is Node {}

class Module is Node {
  construct new(statements) {
    _statements = statements
  }

  statements { _statements }

  accept(visitor) { visitor.visitModule(this) }

  toString { \"Module(\%(_statements))\" }
}

class MapEntry {
  construct new(key, value) {
    _key = key
    _value = value
  }

  key { _key }
  value { _value }

  toString { \"\%(_key): \%(_value)\" }
}

class Method {
  construct new(foreignKeyword, staticKeyword, constructKeyword, name, body) {
    _foreignKeyword = foreignKeyword
    _staticKeyword = staticKeyword
    _constructKeyword = constructKeyword
    _name = name
    _body = body
  }

  foreignKeyword { _foreignKeyword }
  staticKeyword { _staticKeyword }
  constructKeyword { _constructKeyword }
  name { _name }
  body { _body }

  accept(visitor) { visitor.visitMethod(this) }

  toString {
    return \"Method(\%(_staticKeyword) \%(_constructKeyword) \%(_name) \%(_body))\"
  }
}

/// A block argument or method body.
class Body {
  construct new(parameters, expression, statements) {
    _parameters = parameters
    _expression = expression
    _statements = statements
  }

  parameters { _parameters }
  expression { _expression }
  statements { _statements }

  accept(visitor) { visitor.visitBody(this) }

  toString {
    return \"Body(\%(_parameters) \%(_expression) \%(_statements))\"
  }
}")

    writeClasses(EXPRS, "Expr")
    writeClasses(STMTS, "Stmt")

    _file.close()
  }

  writeClasses(classes, superclass) {
    for (name in classes.keys) {
      var fields = classes[name]
      var params = fields.join(", ")
      writeLine()
      writeLine("class %(name)%(superclass) is %(superclass) {")
      writeLine("  construct new(%(params)) {")

      for (field in fields) {
        writeLine("    _%(field) = %(field)")
      }

      writeLine("  }")
      writeLine()

      for (field in fields) {
        writeLine("  %(field) { _%(field) }")
      }

      writeLine()
      writeLine("  accept(visitor) { visitor.visit%(name)%(superclass)(this) }")
      writeLine()
      writeLine("  toString {")
      var interpolation = fields.map {|field| "\%(_%(field))"}.join(" ")
      writeLine("    return \"%(name)(%(interpolation))\"")
      writeLine("  }")

      writeLine("}")
    }
  }

  writeLine() {
    _file.writeBytes("\n")
  }

  writeLine(line) {
    _file.writeBytes(line + "\n")
  }
}

AstBuilder.new().build()
