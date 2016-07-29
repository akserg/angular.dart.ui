part of angular.ui.typeahead;

@Formatter(name : 'highlight')
class TypeaheadHighlightFilter implements Function {

  escapeRegexp(String queryToEscape) {
    var result = queryToEscape.replaceAllMapped(new RegExp(r'([.?*+^$[\]\\(){}|-])'), (Match m)=> '\\${m[0]}');
    return result;
  }

  String call(String matchItem, String query) {
    if (query == null || query.isEmpty) {
      return matchItem;
    } else {
      var queryArray = escapeRegexp(query).split(" ");
      StringBuffer queryString = new StringBuffer();
      if (queryArray.length > 1) {
        queryString.writeAll(queryArray,'|');
      } else {
        queryString.write(queryArray[0]);
      }
      return ('$matchItem')
          .replaceAllMapped(new RegExp(
          queryString.toString().trim(), caseSensitive: false), (
          Match m) =>  '<strong>${m[0]}</strong>');
    }
  }
}