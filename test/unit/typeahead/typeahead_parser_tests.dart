part of angular_ui_test;

void typeaheadParserTests() {

  describe("[TypeaheadParserComponent]", () {
  
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    TypeaheadParser typeaheadParser;
    Scope rootScope;
    FormatterMap formatters;

    beforeEach(() {
      module((Module _) => _
        ..install(new TypeaheadModule())
      );
      inject((TypeaheadParser t) => typeaheadParser = t);
      inject((Scope s) => rootScope = s);
      inject((FormatterMap f) => formatters = f);
    });

    dynamic evaluateExpression(expression, locals) {
      return expression.eval(new ContextLocals(rootScope.context, locals), formatters);
    }

    it('should parse the simplest array-based syntax', async(inject((){
      rootScope.context['states'] = ['Alabama', 'California', 'Delaware'];
      var result = typeaheadParser.parse(r'state for state in states | filter:$viewValue');
      var itemName = result.itemName;
      var locals = {r'$viewValue':'al'};
      expect(evaluateExpression(result.source, locals)).toEqual(['Alabama', 'California']);

      locals[itemName] = 'Alabama';
      expect(evaluateExpression(result.viewMapper, locals)).toEqual('Alabama');
      expect(evaluateExpression(result.modelMapper, locals)).toEqual('Alabama');
    })));

    it('should parse the simplest function-based syntax', async(inject((Filter filter){
      rootScope.context['getStates'] = (viewValue) => filter(['Alabama', 'California', 'Delaware'], viewValue);
      var result = typeaheadParser.parse(r'state for state in getStates($viewValue)');
      var itemName = result.itemName;
      var locals = {r'$viewValue':'al'};
      expect(evaluateExpression(result.source, locals)).toEqual(['Alabama', 'California']);

      locals[itemName] = 'Alabama';
      expect(evaluateExpression(result.viewMapper, locals)).toEqual('Alabama');
      expect(evaluateExpression(result.modelMapper, locals)).toEqual('Alabama');
    })));

    it('should allow to specify custom model mapping that is used as a label as well', async(inject((){
      rootScope.context['states'] = [{'code' : 'AL', 'name' : 'Alabama'}, {'code' : 'CA', 'name':'California'}, {'code' : 'DE', 'name':'Delaware'}];
      var result = typeaheadParser.parse(r'state.name for state in states | filter:$viewValue | orderBy:"name":true');
      var itemName = result.itemName;
      expect(itemName).toEqual('state');
      var locals = {r'$viewValue':'al'};
      expect(evaluateExpression(result.source, locals)).toEqual([{'code' : 'CA', 'name':'California'}, {'code' : 'AL', 'name' : 'Alabama'}]);

      locals[itemName] = {'code':'AL', 'name':'Alabama'};
      expect(evaluateExpression(result.viewMapper, locals)).toEqual('Alabama');
      expect(evaluateExpression(result.modelMapper, locals)).toEqual('Alabama');
    })));

    it('should allow to specify custom view and model mappers', async(inject((){
      rootScope.context['states'] = [{'code' : 'AL', 'name' : 'Alabama'}, {'code' : 'CA', 'name':'California'}, {'code' : 'DE', 'name':'Delaware'}];
      var result = typeaheadParser.parse(r'state.code as state.name + " ("+state.code+")" for state in states | filter:$viewValue | orderBy:"name":true');
      var itemName = result.itemName;
      var locals = {r'$viewValue':'al'};
      expect(evaluateExpression(result.source, locals)).toEqual([{'code' : 'CA', 'name':'California'}, {'code' : 'AL', 'name' : 'Alabama'}]);

      locals[itemName] = {'code':'AL', 'name':'Alabama'};
      expect(evaluateExpression(result.viewMapper, locals)).toEqual('Alabama (AL)');
      expect(evaluateExpression(result.modelMapper, locals)).toEqual('AL');
    })));

    it('should parse the multiline array-based syntax', async(inject((){
      rootScope.context['states'] = ['Alabama', 'California', 'Delaware'];
      var result = typeaheadParser.parse(r'''state for state in states
       | filter:$viewValue''');
      var itemName = result.itemName;
      var locals = {r'$viewValue':'al'};
      expect(evaluateExpression(result.source, locals)).toEqual(['Alabama', 'California']);

      locals[itemName] = 'Alabama';
      expect(evaluateExpression(result.viewMapper, locals)).toEqual('Alabama');
      expect(evaluateExpression(result.modelMapper, locals)).toEqual('Alabama');
    })));
  });
}