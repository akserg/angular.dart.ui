part of angular.ui.typeahead;

class TypeaheadParseResult {
  String itemName;
  Expression source;
  Expression viewMapper;
  Expression modelMapper;

  TypeaheadParseResult(this.itemName, this.source, this.viewMapper, this.modelMapper);
}

@Injectable()
class TypeaheadParser {
  static final RegExp _SYNTAX = new RegExp(r'^\s*(.*?)(?:\s+as\s+(.*?))?\s+for\s+(?:([\$\w][\$\w\d]*))\s+in\s+(.*)$');
  final Parser _parser;

  TypeaheadParser(this._parser);

  TypeaheadParseResult parse(String input) {
    input = input.replaceAll('\n', '');
    var match = _SYNTAX.firstMatch(input);
    var itemName = match.group(3);
    var sourceExpression = match.group(4);
    var modelExpression = match.group(1);

    var viewExpression = match.group(2);
    if(viewExpression == null) {
      viewExpression = modelExpression;
    }
    return new TypeaheadParseResult(itemName, _parser(sourceExpression), _parser(viewExpression), _parser(modelExpression));
  }
}