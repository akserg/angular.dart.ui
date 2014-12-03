// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular_ui_test;

testDatepickerComponent() {
  
  describe("[DatepickerComponent]", () {
        
    TestBed _;
    
    beforeEach(setUpInjector);
    afterEach(tearDownInjector);

    beforeEach(() {
      module((Module _) => _
        ..install(new DatepickerModule())
      );
      inject((TestBed tb) => _ = tb);
//      return loadTemplates(['/datepicker/datepicker.html', '/datepicker/popup.html']);
    });

    String getHtml({String extra:''}) {
      return r'<datepicker ng-model="date"></datepicker>';
    };
    
    Map getScopeContent() {
      return {'date': new DateTime(2010, 9, 30, 15, 30)};
    };
    
    String getTitle(dom.Element element) {
      List ths = element.querySelectorAll('th');
      List<dom.ButtonElement> btns = ths[1].querySelectorAll('button');
      return btns.first.text;
    }
    
    void clickTitleButton(dom.Element element, [int times = 1]) {
      List els = element.querySelectorAll('th');
      dom.ButtonElement btn = els[1].querySelector('button');
      for (var i = 0; i < times; i++) {
        btn.click();
      }
    }
    
    void clickPreviousButton(dom.Element element, [int times = 1]) {
      List els = element.querySelectorAll('th');
      List<dom.ButtonElement> btns = els[0].querySelectorAll('button');
      for (var i = 0; i < times; i++) {
        _.triggerEvent(btns.first, 'click');
      }
    }
    
    void clickNextButton(dom.Element element, [int times = 1]) {
      List els = element.querySelectorAll('th');
      List<dom.ButtonElement> btns = els[2].querySelectorAll('button');
      for (var i = 0; i < times; i++) {
        _.triggerEvent(btns.first, 'click');
      }
    }
    
    dom.TableRowElement getLabelsRow(dom.Element element) {
      List<dom.TableRowElement> rows = element.querySelectorAll('thead > tr');
      return rows[1];
    }
    
    List getLabels(dom.Element element) {
      List els = getLabelsRow(element).querySelectorAll('td'); // TODO: Must be TH

      var labels = [];
      for (var i = 1; i < els.length; i++) {
        labels.add(els[i].text);
      }
      return labels;
    }
    
    List getWeeks(dom.Element element) {
      List rows = element.querySelectorAll('tbody > tr');
      List weeks = [];
      for (var i = 0; i < rows.length; i++) {
        weeks.add(rows[i].querySelectorAll('td').first.text);
      }
      return weeks;
    }
    
    List getOptions(dom.Element element) {
      List tr = element.querySelectorAll('tbody > tr');
      List rows = [];

      for (var j = 0; j < tr.length; j++) {
        List cols = tr[j].querySelectorAll('td');
        List days = [];
        for (var i = 1; i < cols.length; i++) {
          days.add(cols[i].querySelector('button').text);
        }
        rows.add(days);
      }
      return rows;
    }
    
    dom.Element _getOptionEl(dom.Element element, rowIndex, colIndex) {
      return element.querySelectorAll('tbody > tr')[rowIndex].querySelectorAll('td')[colIndex + 1];
    }
    
    void clickOption(dom.Element element, rowIndex, colIndex) {
      _getOptionEl(element, rowIndex, colIndex).querySelector('button').click();
    }
    
    bool isDisabledOption(dom.Element element, rowIndex, colIndex) {
      return (_getOptionEl(element, rowIndex, colIndex).querySelector('button') as dom.ButtonElement).disabled;
    }
    
    List getAllOptionsEl(dom.Element element) {
      var tr = element.querySelectorAll('tbody > tr');
      List rows = [];
      for (var i = 0; i < tr.length; i++) {
        List tds = tr[i].querySelectorAll('td');
        List cols = [];
        for (var j = 0; j < tds.length - 1; j++) {
          cols.add(tds[j + 1]);
        }
        rows.add(cols);
      }
      return rows;
    }
    
    void expectSelectedElement(dom.Element element, row, col ) {
      var options = getAllOptionsEl(element);
      for (var i = 0; i < options.length; i++) {
        List optionsRow = options[i];
        for (var j = 0; j < optionsRow.length; j ++) {
          dom.ButtonElement btn = optionsRow[j].querySelector('button');
          if (btn.classes.contains('btn-info')) {
            expect(i == row && j == col).toBeTruthy();
          }
        }
      }
    }

    describe('', () {
      it('is a \'<table>\' element', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        expect(datepicker.children.length).toBe(1);
        expect(datepicker.children[0].tagName).toEqual('TABLE');
        expect(datepicker.children[0].querySelectorAll('thead > tr').length).toBe(2);
      }));
      
      it('shows the correct title', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        expect(getTitle(datepicker)).toEqual('September 2010');
      }));
      
      it('shows the label row & the correct day labels', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        expect(getLabelsRow(datepicker).style.display).not.toEqual('none');
        expect(getLabels(datepicker)).toEqual(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
      }));
      
      it('renders the calendar days correctly', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        expect(getOptions(datepicker)).toEqual([
          ['30', '31', '01', '02', '03', '04', '05'],
          ['06', '07', '08', '09', '10', '11', '12'],
          ['13', '14', '15', '16', '17', '18', '19'],
          ['20', '21', '22', '23', '24', '25', '26'],
          ['27', '28', '29', '30', '01', '02', '03']
        ]);
      }));
      
      it('renders the week numbers based on ISO 8601', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        expect(getWeeks(datepicker)).toEqual(['35', '36', '37', '38', '39']);
      }));
      
      it('value is correct', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        
        expect(scope.context['date']).toEqual(new DateTime(2010, 9, 30, 15, 30));
      }));
      
      it('has \'selected\' only the correct day', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        expectSelectedElement(datepicker, 4, 3);
      }));
      
      it('has no \'selected\' day when model is cleared', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        scope.context['date'] = null;
        scope.apply();

        expect(scope.context['date']).toBe(null);
        expectSelectedElement(datepicker, null, null );
      }));
      
      it('does not change current view when model is cleared', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        scope.context['date'] = null;
        scope.rootScope.apply();

        expect(scope.context['date']).toBe(null);
        expect(getTitle(datepicker)).toEqual('September 2010');
      }));
      
      it('\'disables\' visible dates from other months', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        var options = getAllOptionsEl(datepicker);
        for (var i = 0; i < 5; i ++) {
          for (var j = 0; j < 7; j ++) {
            dom.Element el = options[i][j].querySelector('button > span');
            if (el.classes.contains('text-muted')) {
              expect((i == 0 && j < 2) || (i == 4 && j > 3)).toBeTruthy();
            }
          }
        }
      }));
      
      it('updates the model when a day is clicked', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        clickOption(datepicker, 2, 2);
        microLeap();
        scope.rootScope.apply();

        expect(scope.context['date']).toEqual(new DateTime(2010, 9, 15, 15, 30));
      }));
      
      it('moves to the previous month & renders correctly when \'previous\' button is clicked', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        clickPreviousButton(datepicker);
        microLeap();

        expect(getTitle(datepicker)).toEqual('August 2010');
        expect(getLabels(datepicker)).toEqual(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
        expect(getOptions(datepicker)).toEqual([
          ['26', '27', '28', '29', '30', '31', '01'],
          ['02', '03', '04', '05', '06', '07', '08'],
          ['09', '10', '11', '12', '13', '14', '15'],
          ['16', '17', '18', '19', '20', '21', '22'],
          ['23', '24', '25', '26', '27', '28', '29'],
          ['30', '31', '01', '02', '03', '04', '05']
        ]);

        expectSelectedElement(datepicker, null, null );
      }));
      
      it('updates the model only when when a day is clicked in the \'previous\' month', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        clickPreviousButton(datepicker);
        microLeap();
        expect(scope.context['date']).toEqual(new DateTime(2010, 9, 30, 15, 30));

        clickOption(datepicker, 2, 3);
        microLeap();
        expect(scope.context['date']).toEqual(new DateTime(2010, 8, 12, 15, 30));
      }));
      
      it('moves to the next month & renders correctly when \'next\' button is clicked', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        clickNextButton(datepicker);
        microLeap();

        expect(getTitle(datepicker)).toEqual('October 2010');
        expect(getLabels(datepicker)).toEqual(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
        expect(getOptions(datepicker)).toEqual([
          ['27', '28', '29', '30', '01', '02', '03'],
          ['04', '05', '06', '07', '08', '09', '10'],
          ['11', '12', '13', '14', '15', '16', '17'],
          ['18', '19', '20', '21', '22', '23', '24'],
          ['25', '26', '27', '28', '29', '30', '31'],
          ['01', '02', '03', '04', '05', '06', '07']
        ]);

        expectSelectedElement(datepicker, 0, 3);
      }));
      
      it('updates the model only when when a day is clicked in the \'next\' month', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        clickNextButton(datepicker); 
        microLeap();
        expect(scope.context['date']).toEqual(new DateTime(2010, 9, 30, 15, 30));

        clickOption(datepicker, 2, 2); 
        microLeap();
        expect(scope.context['date']).toEqual(new DateTime(2010, 10, 13, 15, 30));
      }));
      
      it('updates the calendar when a day of another month is selected', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        clickOption(datepicker, 4, 4); 
        microLeap();
        expect(scope.context['date']).toEqual(new DateTime(2010, 10, 1, 15, 30));
        expect(getTitle(datepicker)).toEqual('October 2010');
        expect(getLabels(datepicker)).toEqual(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
        expect(getOptions(datepicker)).toEqual([
          ['27', '28', '29', '30', '01', '02', '03'],
          ['04', '05', '06', '07', '08', '09', '10'],
          ['11', '12', '13', '14', '15', '16', '17'],
          ['18', '19', '20', '21', '22', '23', '24'],
          ['25', '26', '27', '28', '29', '30', '31'],
          ['01', '02', '03', '04', '05', '06', '07']
        ]);

        expectSelectedElement(datepicker, 0, 4);
      }));
      
      describe('when \'model\' changes', () {
        void testCalendar(dom.Element element) {
          expect(getTitle(element)).toEqual('November 2005');
          expect(getOptions(element)).toEqual([
            ['31', '01', '02', '03', '04', '05', '06'],
            ['07', '08', '09', '10', '11', '12', '13'],
            ['14', '15', '16', '17', '18', '19', '20'],
            ['21', '22', '23', '24', '25', '26', '27'],
            ['28', '29', '30', '01', '02', '03', '04']
          ]);

          expectSelectedElement(element, 1, 0);
        }

        describe('to a Date object', () {
          it('updates', compileComponent(
              getHtml(), 
              getScopeContent(), 
              (Scope scope, dom.HtmlElement shadowRoot) {
            final datepicker = shadowRoot.querySelector('datepicker');
            
            scope.context['date'] = new DateTime(2005, 11, 7, 23, 30);
            scope.rootScope.apply();
            
            testCalendar(datepicker);
            expect(scope.context['date'] is DateTime).toBe(true);
          }));
        });

        describe('not to a Date object', () {

          it('to a Number, it updates calendar', compileComponent(
              getHtml(), 
              getScopeContent(), 
              (Scope scope, dom.HtmlElement shadowRoot) {
            final datepicker = shadowRoot.querySelector('datepicker');
            
            scope.context['date'] = new DateTime(2005, 11, 7, 23, 30).millisecondsSinceEpoch;
            scope.rootScope.apply();
            testCalendar(datepicker);
            expect(scope.context['date'] is num).toBe(true);
          }));

          it('to a string that can be parsed by Date, it updates calendar', compileComponent(
              getHtml(), 
              getScopeContent(), 
              (Scope scope, dom.HtmlElement shadowRoot) {
            final datepicker = shadowRoot.querySelector('datepicker');
            
            /* The function parses a subset of ISO 8601. Examples of accepted strings:
             *
             * * `"2012-02-27 13:27:00"`
             * * `"2012-02-27 13:27:00.123456z"`
             * * `"20120227 13:27:00"`
             * * `"20120227T132700"`
             * * `"20120227"`
             * * `"+20120227"`
             * * `"2012-02-27T14Z"`
             * * `"2012-02-27T14+00:00"`
             * * `"-123450101 00:00:00 Z"`: in the year -12345.
             */
            scope.context['date'] = '2005-11-07 23:30:00';
            scope.rootScope.apply();
            testCalendar(datepicker);
            expect(scope.context['date'] is String).toBe(true);
          }));

//          it('to a string that cannot be parsed by Date, it gets invalid', async(inject(() {
//            dom.Element element = createDatapicker();
//            
//            scope.context['date'] = 'pizza';
//            scope.rootScope.apply();
//            expect(element.classes.contains('ng-invalid')).toBeTruthy();
//            expect(element.classes.contains('ng-invalid-date')).toBeTruthy();
//            expect(scope.context['date']).toBe('pizza');
//          })));
        });
      });
      
      it('loops between different modes', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        expect(getTitle(datepicker)).toEqual('September 2010');

        clickTitleButton(datepicker);
        microLeap();
        expect(getTitle(datepicker)).toEqual('2010');

        clickTitleButton(datepicker);
        microLeap();
        expect(getTitle(datepicker)).toEqual('2001 - 2020');

        clickTitleButton(datepicker);
        microLeap();
        expect(getTitle(datepicker)).toEqual('September 2010');
      }));
      
      describe('month selection mode', () {
        it('shows the year as title', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker);
          microLeap();

          expect(getTitle(datepicker)).toEqual('2010');
        }));

        it('shows months as options', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker);
          microLeap();
                    
          expect(getLabels(datepicker)).toEqual([]);
          expect(getOptions(datepicker)).toEqual([
            ['January', 'February', 'March'],
            ['April', 'May', 'June'],
            ['July', 'August', 'September'],
            ['October', 'November', 'December']
          ]);
        }));

        it('does not change the model', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker);
          microLeap();
                    
          expect(scope.context['date']).toEqual(new DateTime(2010, 9, 30, 15, 30));
        }));

        it('has \'selected\' only the correct month', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker);
          microLeap();
          
          expectSelectedElement(datepicker, 2, 2);
        }));

        it('moves to the previous year when \'previous\' button is clicked', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker);
          microLeap();
          
          clickPreviousButton(datepicker);
          microLeap();

          expect(getTitle(datepicker)).toEqual('2009');
          expect(getLabels(datepicker)).toEqual([]);
          expect(getOptions(datepicker)).toEqual([
            ['January', 'February', 'March'],
            ['April', 'May', 'June'],
            ['July', 'August', 'September'],
            ['October', 'November', 'December']
          ]);

          expectSelectedElement(datepicker, null, null);
        }));

        it('moves to the next year when \'next\' button is clicked', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker);
          microLeap();
                    
          clickNextButton(datepicker);
          microLeap();

          expect(getTitle(datepicker)).toEqual('2011');
          expect(getLabels(datepicker)).toEqual([]);
          expect(getOptions(datepicker)).toEqual([
            ['January', 'February', 'March'],
            ['April', 'May', 'June'],
            ['July', 'August', 'September'],
            ['October', 'November', 'December']
          ]);

          expectSelectedElement(datepicker, null, null);
        }));

        it('renders correctly when a month is clicked', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker);
          microLeap();
                    
          clickPreviousButton(datepicker, 5);
          microLeap();
          expect(getTitle(datepicker)).toEqual('2005');

          clickOption(datepicker, 3, 1);
          microLeap();
          expect(scope.context['date']).toEqual(new DateTime(2010, 9, 30, 15, 30));
          expect(getTitle(datepicker)).toEqual('November 2005');
          expect(getOptions(datepicker)).toEqual([
            ['31', '01', '02', '03', '04', '05', '06'],
            ['07', '08', '09', '10', '11', '12', '13'],
            ['14', '15', '16', '17', '18', '19', '20'],
            ['21', '22', '23', '24', '25', '26', '27'],
            ['28', '29', '30', '01', '02', '03', '04']
          ]);

          clickOption(datepicker, 2, 2);
          microLeap();
          expect(scope.context['date']).toEqual(new DateTime(2005, 11, 16, 15, 30));
        }));
      });
      
      describe('year selection mode', () {

        it('shows the year range as title', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker, 2);
          expect(getTitle(datepicker)).toEqual('2001 - 2020');
        }));

        it('shows years as options', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker, 2);
          microLeap();
          
          expect(getLabels(datepicker)).toEqual([]);
          expect(getOptions(datepicker)).toEqual([
            ['2001', '2002', '2003', '2004', '2005'],
            ['2006', '2007', '2008', '2009', '2010'],
            ['2011', '2012', '2013', '2014', '2015'],
            ['2016', '2017', '2018', '2019', '2020']
          ]);
        }));

        it('does not change the model', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker, 2);
          microLeap();
                    
          expect(scope.context['date']).toEqual(new DateTime(2010, 9, 30, 15, 30));
        }));

        it('has \'selected\' only the selected year', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker, 2);
          microLeap();
                    
          expectSelectedElement(datepicker, 1, 4);
        }));

        it('moves to the previous year set when \'previous\' button is clicked', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker, 2);
          microLeap();
          
          clickPreviousButton(datepicker);
          microLeap();

          expect(getTitle(datepicker)).toEqual('1981 - 2000');
          expect(getLabels(datepicker)).toEqual([]);
          expect(getOptions(datepicker)).toEqual([
            ['1981', '1982', '1983', '1984', '1985'],
            ['1986', '1987', '1988', '1989', '1990'],
            ['1991', '1992', '1993', '1994', '1995'],
            ['1996', '1997', '1998', '1999', '2000']
          ]);
          expectSelectedElement(datepicker, null, null);
        }));

        it('moves to the next year set when \'next\' button is clicked', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker, 2);
          microLeap();
                    
          clickNextButton(datepicker);
          microLeap();

          expect(getTitle(datepicker)).toEqual('2021 - 2040');
          expect(getLabels(datepicker)).toEqual([]);
          expect(getOptions(datepicker)).toEqual([
            ['2021', '2022', '2023', '2024', '2025'],
            ['2026', '2027', '2028', '2029', '2030'],
            ['2031', '2032', '2033', '2034', '2035'],
            ['2036', '2037', '2038', '2039', '2040']
          ]);

          expectSelectedElement(datepicker, null, null);
        }));
      });
      
      describe('attribute \'starting-day\'', () {
        
        String getHtml({String extra:''}) {
          return r'<datepicker ng-model="date" starting-day="1"></datepicker>';
        };
        
        Map getScopeContent() {
          return {'date': new DateTime(2010, 9, 30, 15, 30)};
        };
            
        it('shows the day labels rotated', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          microLeap();
          digest();
          final datepicker = shadowRoot.querySelector('datepicker');
          
          expect(getLabels(datepicker)).toEqual(['Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon']);
        }));

        it('renders the calendar days correctly', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          microLeap();
          digest();
          final datepicker = shadowRoot.querySelector('datepicker');
          
          expect(getOptions(datepicker)).toEqual([
            ['31', '01', '02', '03', '04', '05', '06'],
            ['07', '08', '09', '10', '11', '12', '13'],
            ['14', '15', '16', '17', '18', '19', '20'],
            ['21', '22', '23', '24', '25', '26', '27'],
            ['28', '29', '30', '01', '02', '03', '04']
          ]);
        }));

        it('renders the week numbers correctly', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          microLeap();
          digest();
          final datepicker = shadowRoot.querySelector('datepicker');
          
          expect(getWeeks(datepicker)).toEqual(['35', '36', '37', '38', '39']);
        }));
      });
      
      describe('attribute \'show-weeks\'', () {
        dom.Element weekHeader, weekElement;
        
        String getHtml({String extra:''}) {
          return r'<datepicker ng-model="date" show-weeks="showWeeks"></datepicker>';
        };
        
        Map getScopeContent() {
          return {
            'date': new DateTime(2010, 9, 30, 15, 30),
            'showWeeks': false
          };
        };
        
        it('hides week numbers based on variable', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          microLeap();
          digest();
          final datepicker = shadowRoot.querySelector('datepicker');
          dom.Element weekHeader = getLabelsRow(datepicker).querySelectorAll('td').first; // TODO: TH
          dom.Element weekElement = datepicker.querySelectorAll('tbody > tr')[1].querySelectorAll('td').first;
          
          expect(weekHeader.text).toEqual('#');
          expect(weekHeader.classes).toContain('ng-hide');
          expect(weekElement.classes).toContain('ng-hide');
        }));

        it('toggles week numbers', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          microLeap();
          digest();
          final datepicker = shadowRoot.querySelector('datepicker');
          dom.Element weekHeader = getLabelsRow(datepicker).querySelectorAll('td').first; // TODO: TH
          dom.Element weekElement = datepicker.querySelectorAll('tbody > tr')[1].querySelectorAll('td').first;
          
          scope.context['showWeeks'] = true;
          scope.rootScope.apply();
          expect(weekHeader.text).toEqual('#');
          expect(weekHeader.classes).not.toContain('ng-hide');
          expect(weekElement.classes).not.toContain('ng-hide');
                    
          scope.context['showWeeks'] = false;
          scope.rootScope.apply();
          expect(weekHeader.text).toEqual('#');
          expect(weekHeader.classes).toContain('ng-hide');
          expect(weekElement.classes).toContain('ng-hide');
        }));
      });
 
      describe('min attribute', () {
        String getHtml() {
          return r'<datepicker ng-model="date" min="mindate"></datepicker>';
        };
        
        Map getScopeContent() {
          return {
            'date': new DateTime(2010, 9, 30, 15, 30),
            'mindate': new DateTime(2010, 9, 13)
          };
        };
                
        it('disables appropriate days in current month', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe( (i < 2) );
            }
          }
        }));

        it('disables appropriate days when min date changes', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          scope.context['mindate'] = new DateTime(2010, 9, 6);
          scope.rootScope.apply();
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe( (i < 1) );
            }
          }
        }));

        it('invalidates when model is a disabled date', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          scope.context['mindate'] = new DateTime(2010, 9, 6);
          scope.context['date'] = new DateTime(2010, 9, 2);
          scope.rootScope.apply();
//          expect(datepicker.classes.contains('ng-invalid')).toBeTruthy();
//          expect(datepicker.classes.contains('ng-invalid-date-disabled')).toBeTruthy();
        }));

        it('disables all days in previous month', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickPreviousButton(datepicker);
          microLeap();
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe(true);
            }
          }
        }));

        it('disables no days in next month', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickNextButton(datepicker);
          microLeap();
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe(false);
            }
          }
        }));

        it('disables appropriate months in current year', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker);
          microLeap();
          for (var i = 0; i < 4; i ++) {
            for (var j = 0; j < 3; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe( (i < 2 || (i == 2 && j < 2)) );
            }
          }
        }));

        it('disables all months in previous year', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker);
          microLeap();
          clickPreviousButton(datepicker);
          microLeap();
          for (var i = 0; i < 4; i ++) {
            for (var j = 0; j < 3; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe(true);
            }
          }
        }));

        it('disables no months in next year', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker);
          microLeap();
          clickNextButton(datepicker);
          microLeap();
          for (var i = 0; i < 4; i ++) {
            for (var j = 0; j < 3; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe(false);
            }
          }
        }));

        it('enables everything before if it is cleared', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          scope.context['mindate'] = null;
          scope.context['date'] = new DateTime(1949, 12, 20);
          scope.rootScope.apply();

          clickTitleButton(datepicker);
          microLeap();
          for (var i = 0; i < 4; i ++) {
            for (var j = 0; j < 3; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe(false);
            }
          }
        }));
      });
      
      describe('max attribute', () {
        String getHtml() {
          return r'<datepicker ng-model="date" max="maxdate"></datepicker>';
        };
        
        Map getScopeContent() {
          return {
            'date': new DateTime(2010, 9, 30, 15, 30),
            'maxdate': new DateTime(2010, 9, 26)
          };
        };

        it('disables appropriate days in current month', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe( (i == 4) );
            }
          }
        }));

        it('disables appropriate days when max date changes', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          scope.context['maxdate'] = new DateTime(2010, 9, 19);
          scope.rootScope.apply();
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe( (i > 2) );
            }
          }
        }));

        it('invalidates when model is a disabled date', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          scope.context['maxdate'] = new DateTime(2010, 9, 19);
          scope.rootScope.apply();
//          expect(datepicker.classes.contains('ng-invalid')).toBeTruthy();
//          expect(datepicker.classes.contains('ng-invalid-date-disabled')).toBeTruthy();
        }));

        it('disables no days in previous month', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickPreviousButton(datepicker);
          microLeap();
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe( false );
            }
          }
        }));

        it('disables all days in next month', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickNextButton(datepicker);
          microLeap();
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe( true );
            }
          }
        }));

        it('disables appropriate months in current year', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker);
          microLeap();
          for (var i = 0; i < 4; i ++) {
            for (var j = 0; j < 3; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe( (i > 2 || (i == 2 && j > 2)) );
            }
          }
        }));

        it('disables no months in previous year', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker);
          microLeap();
          clickPreviousButton(datepicker);
          microLeap();
          for (var i = 0; i < 4; i ++) {
            for (var j = 0; j < 3; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe( false );
            }
          }
        }));

        it('disables all months in next year', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          clickTitleButton(datepicker);
          microLeap();
          clickNextButton(datepicker);
          microLeap();
          for (var i = 0; i < 4; i ++) {
            for (var j = 0; j < 3; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe( true );
            }
          }
        }));

        it('enables everything after if it is cleared', compileComponent(
            getHtml(), 
            getScopeContent(), 
            (Scope scope, dom.HtmlElement shadowRoot) {
          final datepicker = shadowRoot.querySelector('datepicker');
          
          scope.context['maxdate'] = null;
          scope.rootScope.apply();
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(datepicker, i, j)).toBe( false );
            }
          }
        }));
      });

//      describe('date-disabled expression', () {
//        dom.Element createDatapicker() {
//          scope.context['date'] = new DateTime(2010, 9, 30, 15, 30);
//          scope.context['dateDisabledHandler'] = jasmine.createSpy('dateDisabledHandler');
//          dom.Element element = _.compile('<datepicker ng-model="date" date-disabled="dateDisabledHandler(date, mode)"></datepicker>', scope:scope);
//
//          microLeap();
//          scope.rootScope.apply();
//          
//          return element;
//        }
//        
//        it('executes the dateDisabled expression for each visible day plus one for validation', async(inject(() {
//          dom.Element element = createDatapicker();
//          
//          expect(scope.context['dateDisabledHandler'].count).toEqual(35 + 1);
//        })));
//
//        it('executes the dateDisabled expression for each visible month plus one for validation', async(inject(() {
//          dom.Element element = createDatapicker();
//          
//          scope.context['disabledHandler'].reset();
//          clickTitleButton(element);
//          microLeap();
//          expect(scope.context['disabledHandler'].calls.length).toEqual(12 + 1);
//        })));
//
//        it('executes the dateDisabled expression for each visible year plus one for validation', async(inject(() {
//          dom.Element element = createDatapicker();
//          
//          clickTitleButton(element);
//          microLeap();
//          scope.context['disabledHandler'].reset();
//          clickTitleButton(element);
//          microLeap();
//          expect(scope.context['disabledHandler'].calls.length).toEqual(20 + 1);
//        })));
    });
    
    describe('formatting attributes', () {
      
      String getHtml() {
        return '<datepicker ng-model="date" day-format="\'d\'" day-header-format="\'EEEE\'" day-title-format="\'MMMM, yy\'" month-format="\'MMM\'" month-title-format="\'yy\'" year-format="\'yy\'" year-range="10"></datepicker>';
      };
      
      Map getScopeContent() {
        return {
          'date': new DateTime(2010, 9, 30, 15, 30),
          'maxdate': new DateTime(2010, 9, 26)
        };
      };
      
      it('changes the title format in \'day\' mode', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        expect(getTitle(datepicker)).toEqual('September, 10');
      }));

      it('changes the title & months format in \'month\' mode', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        clickTitleButton(datepicker);
        microLeap();

        expect(getTitle(datepicker)).toEqual('10');
        expect(getOptions(datepicker)).toEqual([
          ['Jan', 'Feb', 'Mar'],
          ['Apr', 'May', 'Jun'],
          ['Jul', 'Aug', 'Sep'],
          ['Oct', 'Nov', 'Dec']
        ]);
      }));

      it('changes the title, year format & range in \'year\' mode', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        clickTitleButton(datepicker, 2);
        microLeap();

        expect(getTitle(datepicker)).toEqual('01 - 10');
        expect(getOptions(datepicker)).toEqual([
          ['01', '02', '03', '04', '05'],
          ['06', '07', '08', '09', '10']
        ]);
      }));

      it('shows day labels', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        expect(getLabels(datepicker)).toEqual(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']);
      }));

      it('changes the day format', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        expect(getOptions(datepicker)).toEqual([
          ['30', '31', '1', '2', '3', '4', '5'],
          ['6', '7', '8', '9', '10', '11', '12'],
          ['13', '14', '15', '16', '17', '18', '19'],
          ['20', '21', '22', '23', '24', '25', '26'],
          ['27', '28', '29', '30', '1', '2', '3']
        ]);
      }));
    });
    
    describe('setting datepickerConfig', () {
            
      beforeEach(() {
        inject((DatepickerConfig dc) { 
          dc
          ..startingDay = 6
          ..showWeeks = false
          ..dayFormat = 'd'
          ..monthFormat = 'MMM'
          ..yearFormat = 'yy'
          ..yearRange = 10
          ..dayHeaderFormat = 'EEEE'
          ..dayTitleFormat = 'MMMM, yy'
          ..monthTitleFormat = 'yy';
        });
      });
      
      String getHtml() {
        return '<datepicker ng-model="date"></datepicker>';
      };
      
      Map getScopeContent() {
        return {
          'date': new DateTime(2010, 9, 30, 15, 30),
          'maxdate': new DateTime(2010, 9, 26)
        };
      };

      it('changes the title format in \'day\' mode', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        expect(getTitle(datepicker)).toEqual('September, 10');
      }));

      it('changes the title & months format in \'month\' mode', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        clickTitleButton(datepicker);
        microLeap();

        expect(getTitle(datepicker)).toEqual('10');
        expect(getOptions(datepicker)).toEqual([
          ['Jan', 'Feb', 'Mar'],
          ['Apr', 'May', 'Jun'],
          ['Jul', 'Aug', 'Sep'],
          ['Oct', 'Nov', 'Dec']
        ]);
      }));

      it('changes the title, year format & range in \'year\' mode', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        clickTitleButton(datepicker, 2);
        microLeap();

        expect(getTitle(datepicker)).toEqual('01 - 10');
        expect(getOptions(datepicker)).toEqual([
          ['01', '02', '03', '04', '05'],
          ['06', '07', '08', '09', '10']
        ]);
      }));

      it('changes the \'starting-day\' & day headers & format', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        expect(getLabels(datepicker)).toEqual(['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']);
        expect(getOptions(datepicker)).toEqual([
          ['29', '30', '31', '1', '2', '3', '4'],
          ['5', '6', '7', '8', '9', '10', '11'],
          ['12', '13', '14', '15', '16', '17', '18'],
          ['19', '20', '21', '22', '23', '24', '25'],
          ['26', '27', '28', '29', '30', '1', '2']
        ]);
      }));

      it('changes initial visibility for weeks', compileComponent(
          getHtml(), 
          getScopeContent(), 
          (Scope scope, dom.HtmlElement shadowRoot) {
        final datepicker = shadowRoot.querySelector('datepicker');
        
        // TODO: TH
        expect(getLabelsRow(datepicker).querySelectorAll('td').first.classes).toContain('ng-hide');
        var tr = datepicker.querySelectorAll('tbody > tr');
        for (var i = 0; i < 5; i++) {
          expect(tr[i].querySelectorAll('td').first.classes).toContain('ng-hide');
        }
      }));
    });
    
//    describe('controller', () {
//            
//      Datepicker ctrl;
//      
//      beforeEach(inject((DatepickerConfig datepickerConfig, Scope scope, Injector injector, Date dateFilter) {
//        var element = new dom.DivElement();
//        var attrs = new NodeAttrs(element);
//        ctrl = new Datepicker.forTests(element, datepickerConfig, attrs, scope, dateFilter);
//      }));
//      
//      
//      describe('modes', () {
//        var currentMode;
//
//        it('to be an array', async(inject(() {
//          expect(ctrl.modes.length).toBe(3);
//        })));
//
//        describe('\'day\'', () {
//          beforeEach(inject(() {
//            currentMode = ctrl.modes[0];
//          }));
//
//          it('has the appropriate name', async(inject(() {
//            expect(currentMode.name).toEqual('day');
//          })));
//
//          it('returns the correct date objects', async(inject(() {
//            var objs = currentMode.getVisibleDates(new DateTime(2010, 9, 1), new DateTime(2010, 9, 30)).objects;
//            expect(objs.length).toBe(35);
//            expect(objs[1].selected).toBeFalsy();
//            expect(objs[31].selected).toBeTruthy();
//          })));
//
//          it('can compare two dates', async(inject(() {
//            expect(currentMode.compare(new DateTime(2010, 9, 30), new DateTime(2010, 9, 1)) > 0).toBeTruthy();
//            expect(currentMode.compare(new DateTime(2010, 9, 1), new DateTime(2010, 9, 30)) < 0).toBeTruthy();
//            expect(currentMode.compare(new DateTime(2010, 9, 30, 15, 30), new DateTime(2010, 9, 30, 20, 30))).toBe(0);
//          })));
//        });
//
//        describe('\'month\'', () {
//          beforeEach(inject(() {
//            currentMode = ctrl.modes[1];
//          }));
//
//          it('has the appropriate name', async(inject(() {
//            expect(currentMode.name).toBe('month');
//          })));
//
//          it('returns the correct date objects', async(inject(() {
//            var objs = currentMode.getVisibleDates(new DateTime(2010, 9, 1), new DateTime(2010, 9, 30)).objects;
//            expect(objs.length).toBe(12);
//            expect(objs[1].selected).toBeFalsy();
//            expect(objs[8].selected).toBeTruthy();
//          })));
//
//          it('can compare two dates', async(inject(() {
//            expect(currentMode.compare(new DateTime(2010, 10, 30), new DateTime(2010, 9, 1)) > 0).toBeTruthy();
//            expect(currentMode.compare(new DateTime(2010, 9, 1), new DateTime(2010, 10, 30)) < 0).toBeTruthy();
//            expect(currentMode.compare(new DateTime(2010, 9, 1), new DateTime(2010, 9, 30))).toBe(0);
//          })));
//        });
//
//        describe('\'year\'', () {
//          beforeEach(inject(() {
//            currentMode = ctrl.modes[2];
//          }));
//
//          it('has the appropriate name', async(inject(() {
//            expect(currentMode.name).toBe('year');
//          })));
//
//          it('returns the correct date objects', async(inject(() {
//            var objs = currentMode.getVisibleDates(new DateTime(2010, 9, 1), new DateTime(2010, 9, 1)).objects;
//            expect(objs.length).toBe(20);
//            expect(objs[1].selected).toBeFalsy();
//            expect(objs[9].selected).toBeTruthy();
//          })));
//
//          it('can compare two dates', async(inject(() {
//            expect(currentMode.compare(new DateTime(2011, 9, 1), new DateTime(2010, 10, 30)) > 0).toBeTruthy();
//            expect(currentMode.compare(new DateTime(2010, 10, 30), new DateTime(2011, 9, 1)) < 0).toBeTruthy();
//            expect(currentMode.compare(new DateTime(2010, 11, 9), new DateTime(2010, 9, 30))).toBe(0);
//          })));
//        });
//      });
//      
//      
//      describe('\'isDisabled\' function', () {
//        var date = new DateTime(2010, 9, 30, 15, 30);
//
//        it('to return false if no limit is set', async(inject(() {
//          expect(ctrl.isDisabled(date, 0)).toBeFalsy();
//        })));
//
//        it('to handle correctly the \'min\' date', async(inject(() {
//          ctrl.minDate = new DateTime(2010, 10, 1);
//          expect(ctrl.isDisabled(date, 0)).toBeTruthy();
//          expect(ctrl.isDisabled(date)).toBeTruthy();
//
//          ctrl.minDate = new DateTime(2010, 9, 1);
//          expect(ctrl.isDisabled(date, 0)).toBeFalsy();
//        })));
//
//        it('to handle correctly the \'max\' date', async(inject(() {
//          ctrl.maxDate = new DateTime(2010, 10, 1);
//          expect(ctrl.isDisabled(date, 0)).toBeFalsy();
//
//          ctrl.maxDate = new DateTime(2010, 9, 1);
//          expect(ctrl.isDisabled(date, 0)).toBeTruthy();
//          expect(ctrl.isDisabled(date)).toBeTruthy();
//        })));
//
////          it('to handle correctly the scope \'dateDisabled\' expression', async(inject(() {
////            ctrl.setDateDisabled((attribs) {
////              return false;
////            });
////            
////            expect(ctrl.isDisabled(date, 0)).toBeFalsy();
//    //
////            ctrl.setDateDisabled((attribs) {
////              return true;
////            });
////            expect(ctrl.isDisabled(date, 0)).toBeTruthy();
////          })));
////        });
//    });
         
//      describe('as popup', () {
//        dom.Element divElement, dropdownEl, element;
//        InputElement inputEl;
//        var changeInputValueTo;
//
//        void assignElements(dom.Element wrapElement) {
//          inputEl = ngQuery(wrapElement, 'input').first;
//          dropdownEl = ngQuery(wrapElement, 'ul').first;
//          element = ngQuery(wrapElement, 'table').first;
//        }
//        
//        void createPopup() {
//          scope.context['date'] = new DateTime(2010, 9, 30, 15, 30);
//          dom.Element wrapElement = _.compile('<div><input datepicker-popup ng-model="date"></div>', scope:scope);
//
//          microLeap();
//          scope.apply();
  
//          assignElements(wrapElement);
//          
//          changeInputValueTo = (InputElement el, value) {
//            el.value = value;
////            el.trigger($sniffer.hasEvent('input') ? 'input' : 'change');
//            scope.rootScope.apply();
//          };
//        };

//        describe('', () {
//
//          it('to display the correct value in input', async(inject(() {
//            createPopup();
//            
//            expect(inputEl.value).toEqual('2010-09-30');
//          })));
//
//          it('does not to display datepicker initially', async(inject(() {
//            createPopup();
//            
//            expect(dropdownEl.style.display).toEqual('none');
//          })));

//          it('displays datepicker on input focus', async(inject(() {
//            createPopup();
//            
//            inputEl.focus();
//            microLeap();
//            scope.rootScope.apply();
//                      
//            expect(dropdownEl.style.display).not.toEqual('none');
//          })));

//          it('renders the calendar correctly', async(inject(() {
//            createPopup();
//            
//            expect(getLabelsRow(element).style.display).not.toBe('none');
//            expect(getLabels(element)).toEqual(['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']);
//            expect(getOptions(element)).toEqual([
//              ['29', '30', '31', '01', '02', '03', '04'],
//              ['05', '06', '07', '08', '09', '10', '11'],
//              ['12', '13', '14', '15', '16', '17', '18'],
//              ['19', '20', '21', '22', '23', '24', '25'],
//              ['26', '27', '28', '29', '30', '01', '02']
//            ]);
//          })));

//          it('updates the input when a day is clicked', async(inject(() {
//            createPopup();
//            
//            clickOption(element, 2, 3);
//            expect(inputEl.value).toEqual('2010-09-15');
//            expect(scope.context['date']).toEqual(new DateTime(2010, 9, 15, 15, 30));
//          })));

//          it('should mark the input field dirty when a day is clicked', async(inject(() {
//            createPopup();
//            
//            expect(inputEl.classes.contains('ng-pristine')).toBeTruthy();
//            clickOption(element, 2, 3);
//            expect(inputEl.classes.contains('ng-dirty')).toBeTruthy();
//          })));

//          it('updates the input correctly when model changes', async(inject(() {
//            createPopup();
//          
//            scope.context['date'] = new DateTime(1983, 1, 10, 10, 0); //'January 10, 1983 10:00:00');
//            scope.apply();
//            expect(inputEl.value).toBe('1983-01-10');
//          })));

//          it('closes the dropdown when a day is clicked', async(inject(() {
//            createPopup();
//            
//            inputEl.focus();
//            expect(dropdownEl.style.display).not.toEqual('none');
//
//            clickOption(element, 2, 3);
//            expect(dropdownEl.style.display).toEqual('none');
//          })));

//          it('updates the model & calendar when input value changes', async(inject(() {
//            createPopup();
//            
//            changeInputValueTo(inputEl, 'March 5, 1980');
//
//            expect(scope.context['date'].year).toEqual(1980);
//            expect(scope.context['date'].month).toEqual(2);
//            expect(scope.context['date'].day).toEqual(5);
//
//            expect(getOptions(element)).toEqual([
//              ['24', '25', '26', '27', '28', '29', '01'],
//              ['02', '03', '04', '05', '06', '07', '08'],
//              ['09', '10', '11', '12', '13', '14', '15'],
//              ['16', '17', '18', '19', '20', '21', '22'],
//              ['23', '24', '25', '26', '27', '28', '29'],
//              ['30', '31', '01', '02', '03', '04', '05']
//            ]);
//            expectSelectedElement(element, 1, 3);
//          })));

//          it('closes when click outside of calendar', async(inject(() {
//            createPopup();
//            
//            document.body.click();
//            expect(dropdownEl.style.display).toEqual('none');
//          })));

//          it('sets `ng-invalid` for invalid input', async(inject(() {
//            createPopup();
//            
//            changeInputValueTo(inputEl, 'pizza');
//
//            expect(inputEl.classes.contains('ng-invalid')).toBeTruthy();
//            expect(inputEl.classes.contains('ng-invalid-date')).toBeTruthy();
//            expect(scope.context['date']).toBeNull();
//            expect(inputEl.value).toEqual('pizza');
//          })));
//        });
//      });

  });
}