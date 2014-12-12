part of angular_ui_test;

void typeaheadHighlightFilterTests() {
  
  describe("[TypeaheadHighlightFilterComponent]", () {

    beforeEach(setUpInjector);
    afterEach(tearDownInjector);
  
    TypeaheadHighlightFilter highlightFilter;
  
    beforeEach(module((Module module){
      module.install(new TypeaheadModule());
  
      return (Injector injector) {
        highlightFilter = injector.get(TypeaheadHighlightFilter);
      };
    }));
  
    it('should higlight a match', async(inject((){
      expect(highlightFilter('before match after', 'match')).toEqual('before <strong>match</strong> after');
    })));
  
    it('should higlight a match with mixed case', async(inject((){
      expect(highlightFilter('before MaTch after', 'match')).toEqual('before <strong>MaTch</strong> after');
    })));
  
    it('should higlight all matches', async(inject((){
      expect(highlightFilter('before MaTch after match', 'match')).toEqual('before <strong>MaTch</strong> after <strong>match</strong>');
    })));
  
    it('should do nothing if no match', async(inject((){
      expect(highlightFilter('before match after', 'nomatch')).toEqual('before match after');
    })));
  
    it('should do nothing if no or empty query', async(inject((){
      expect(highlightFilter('before match after', '')).toEqual('before match after');
      expect(highlightFilter('before match after', null)).toEqual('before match after');
    })));
  
    it('should work correctly for regexp reserved words', async(inject((){
      expect(highlightFilter('before (match after', '(match')).toEqual('before <strong>(match</strong> after');
    })));
  
    it('should work correctly with numeric values', async(inject((){
      expect(highlightFilter('123', '2')).toEqual('1<strong>2</strong>3');
    })));
  });
}