part of angular.ui.typeahead;

@Formatter(name : 'highlight')
class TypeaheadHighlightFilter implements Function {

  escapeRegexp(String queryToEscape) {
    var result = queryToEscape.replaceAllMapped(new RegExp(r'([.?*+^$[\]\\(){}|-])'), (Match m)=> '\\${m[0]}');
    return result;
  }

  String call(String matchItem, String query) {
    return (query == null || query.isEmpty) ? matchItem : ('$matchItem').replaceAllMapped(new RegExp(escapeRegexp(query), caseSensitive: false), (Match m)=> '<strong>${m[0]}</strong>');
  }
}