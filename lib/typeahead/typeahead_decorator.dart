part of angular.ui.typeahead;

@Decorator(selector : '[typeahead]', map: const {
    'typeahead': '@expression'
})
class TypeaheadDecorator implements AttachAware {

  final TypeaheadParser _typeaheadParser;
  final NgModel _ngModel;
  final Scope _scope;
  final dom.Element _element;

  final FormatterMap _formatters;
  final Compiler _compiler;
  final DirectiveMap _directiveMap;
  final Injector _injector;

   TypeaheadDecorator(this._ngModel, this._scope, this._element, this._typeaheadParser, this._compiler, this._directiveMap, this._injector);

  set expression(value) {
    assert(value != null);

    final TypeaheadParseResult typeaheadResult = _typeaheadParser.parse(value);

    _setupModelFormatter(typeaheadResult);
  }

  void attach() {
    _createPopup();
    _setupEventListeners();
  }

  void _setupEventListeners() {

    var handler = (dom.Event event) {
      _scope.apply(() => _openPopup());
    };

    _element..onChange.listen(handler)
      ..onCut.listen(handler)
      ..onPaste.listen(handler)..onInput.listen(handler);
  }

  void _createPopup() {
    String html = '<typeahead-popup matches="matches"></typeahead-popup>';
    // Convert to html
    List<dom.Element> rootElements = toNodeList(html);

    _compiler(rootElements, _directiveMap)(_injector, rootElements);

    _element.parent.append(rootElements.first);
  }

  void _openPopup() {
    _setMatches();
  }

  void _setMatches() {
    _scope.context['matches'] = ['abc', 'xyz'];
  }

  void _cleanupMatches() {
    _scope.context['macthes'] = null;
  }


  void _setupModelFormatter(TypeaheadParseResult typeaheadResult) {
    var formatterFunc = (modelValue) {
      try {
        var locals = {typeaheadResult.itemName : modelValue};
        return typeaheadResult.viewMapper.eval(new ScopeLocals(_scope.context, locals), _formatters);
      } catch(e, s) {
        return modelValue;
      }
    };

    _ngModel.converter = new TypeaheadConverter(formatterFunc);
  }
}

typedef FormatterFunc(value);

class TypeaheadConverter extends NgModelConverter {
  final name = 'typeahead';
  final FormatterFunc _formatter;

  TypeaheadConverter(this._formatter);

  format(value) => _formatter(value);
}