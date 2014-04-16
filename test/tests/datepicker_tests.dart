// Copyright (C) 2013 - 2014 Angular Dart UI authors. Please see AUTHORS.md.
// https://github.com/akserg/angular.dart.ui
// All rights reserved.  Please see the LICENSE.md file.

part of angular.ui.test;

void datepickerTests() {

  
  describe('Testing datepicker:', () {
    TestBed _;
    Scope scope;
    
    beforeEach(() {
      setUpInjector();
      module((Module module) {
        module.install(new DatepickerModule());
      });
      
      inject((TestBed tb, Scope s, TemplateCache cache) {
        _ = tb;
        scope = s;
        addToTemplateCache(cache, 'packages/angular_ui/datepicker/datepicker.html');
        addToTemplateCache(cache, 'packages/angular_ui/datepicker/popup.html');
      });
    });
    
    afterEach(tearDownInjector);

    dom.Element createDatapicker() {
      scope.context['date'] = new DateTime(2010, 9, 30, 15, 30);
      
      dom.Element element = _.compile('<datepicker ng-model="date"></datepicker>');

      microLeap();
      scope.apply();
      
      return element;
    }
    
    String getTitle(dom.Element element) {
      List ths = element.shadowRoot.querySelectorAll('th');
      List<dom.ButtonElement> btns = ths[1].querySelectorAll('button');
      return btns.first.text;
    }
    
    void clickTitleButton(dom.Element element, [int times = 1]) {
      List els = element.shadowRoot.querySelectorAll('th');
      dom.ButtonElement btn = els[1].querySelector('button');
      for (var i = 0; i < times; i++) {
        btn.click();
      }
    }
    
    void clickPreviousButton(dom.Element element, [int times = 1]) {
      List els = element.shadowRoot.querySelectorAll('th');
      List<dom.ButtonElement> btns = els[0].querySelectorAll('button');
      for (var i = 0; i < times; i++) {
        _.triggerEvent(btns.first, 'click');
      }
    }
    
    void clickNextButton(dom.Element element, [int times = 1]) {
      List els = element.shadowRoot.querySelectorAll('th');
      List<dom.ButtonElement> btns = els[2].querySelectorAll('button');
      for (var i = 0; i < times; i++) {
        _.triggerEvent(btns.first, 'click');
      }
    }
    
    dom.TableRowElement getLabelsRow(dom.Element element) {
      List<dom.TableRowElement> rows = element.shadowRoot.querySelectorAll('thead > tr');
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
      List rows = element.shadowRoot.querySelectorAll('tbody > tr');
      List weeks = [];
      for (var i = 0; i < rows.length; i++) {
        weeks.add(rows[i].querySelectorAll('td').first.text);
      }
      return weeks;
    }
    
    List getOptions(dom.Element element) {
      List tr = element.shadowRoot.querySelectorAll('tbody > tr');
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
      return element.shadowRoot.querySelectorAll('tbody > tr')[rowIndex].querySelectorAll('td')[colIndex + 1];
    }
    
    void clickOption(dom.Element element, rowIndex, colIndex) {
      _getOptionEl(element, rowIndex, colIndex).querySelector('button').click();
    }
    
    bool isDisabledOption(dom.Element element, rowIndex, colIndex) {
      return (_getOptionEl(element, rowIndex, colIndex).querySelector('button') as dom.ButtonElement).disabled;
    }
    
    List getAllOptionsEl(dom.Element element) {
      var tr = element.shadowRoot.querySelectorAll('tbody > tr');
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
      
      it('is a \'<table>\' element', async(inject(() {
        dom.Element element = createDatapicker();
        
        expect(element.shadowRoot.children.length).toBe(2);
        expect(element.shadowRoot.children[1].tagName).toEqual('TABLE');
        expect(element.shadowRoot.children[1].querySelectorAll('thead > tr').length).toBe(2);
      })));
      
      it('shows the correct title', async(inject(() {
        dom.Element element = createDatapicker();
        
        expect(getTitle(element)).toEqual('September 2010');
      })));
      
      it('shows the label row & the correct day labels', async(inject(() {
        dom.Element element = createDatapicker();
        
        expect(getLabelsRow(element).style.display).not.toEqual('none');
        expect(getLabels(element)).toEqual(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
      })));
      
      it('renders the calendar days correctly', async(inject(() {
        dom.Element element = createDatapicker();
        
        expect(getOptions(element)).toEqual([
          ['30', '31', '01', '02', '03', '04', '05'],
          ['06', '07', '08', '09', '10', '11', '12'],
          ['13', '14', '15', '16', '17', '18', '19'],
          ['20', '21', '22', '23', '24', '25', '26'],
          ['27', '28', '29', '30', '01', '02', '03']
        ]);
      })));
      
      it('renders the week numbers based on ISO 8601', async(inject(() {
        dom.Element element = createDatapicker();
        
        expect(getWeeks(element)).toEqual(['35', '36', '37', '38', '39']);
      })));
      
      it('value is correct', async(inject(() {
        dom.Element element = createDatapicker();
        
        expect(scope.context['date']).toEqual(new DateTime(2010, 9, 30, 15, 30));
      })));
      
      it('has \'selected\' only the correct day', async(inject(() {
        dom.Element element = createDatapicker();
        
        expectSelectedElement(element, 4, 3);
      })));
      
      it('has no \'selected\' day when model is cleared', async(inject(() {
        dom.Element element = createDatapicker();
        
        scope.context['date'] = null;
        scope.apply();

        expect(scope.context['date']).toBe(null);
        expectSelectedElement(element, null, null );
      })));
      
      it('does not change current view when model is cleared', async(inject(() {
        dom.Element element = createDatapicker();
        
        scope.context['date'] = null;
        scope.rootScope.apply();

        expect(scope.context['date']).toBe(null);
        expect(getTitle(element)).toEqual('September 2010');
      })));
      
      it('\'disables\' visible dates from other months', async(inject(() {
        dom.Element element = createDatapicker();
        
        var options = getAllOptionsEl(element);
        for (var i = 0; i < 5; i ++) {
          for (var j = 0; j < 7; j ++) {
            dom.Element el = options[i][j].querySelector('button > span');
            if (el.classes.contains('text-muted')) {
              expect((i == 0 && j < 2) || (i == 4 && j > 3)).toBeTruthy();
            }
          }
        }
      })));
      
      it('updates the model when a day is clicked', async(inject(() {
        dom.Element element = createDatapicker();
        
        clickOption(element, 2, 2);
        microLeap();
        scope.rootScope.apply();

        expect(scope.context['date']).toEqual(new DateTime(2010, 9, 15, 15, 30));
      })));
      
      it('moves to the previous month & renders correctly when \'previous\' button is clicked', async(inject(() {
        dom.Element element = createDatapicker();
        
        clickPreviousButton(element);
        microLeap();

        expect(getTitle(element)).toEqual('August 2010');
        expect(getLabels(element)).toEqual(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
        expect(getOptions(element)).toEqual([
          ['26', '27', '28', '29', '30', '31', '01'],
          ['02', '03', '04', '05', '06', '07', '08'],
          ['09', '10', '11', '12', '13', '14', '15'],
          ['16', '17', '18', '19', '20', '21', '22'],
          ['23', '24', '25', '26', '27', '28', '29'],
          ['30', '31', '01', '02', '03', '04', '05']
        ]);

        expectSelectedElement(element, null, null );
      })));
      
      it('updates the model only when when a day is clicked in the \'previous\' month', async(inject(() {
        dom.Element element = createDatapicker();
        
        clickPreviousButton(element);
        microLeap();
        expect(scope.context['date']).toEqual(new DateTime(2010, 9, 30, 15, 30));

        clickOption(element, 2, 3);
        microLeap();
        expect(scope.context['date']).toEqual(new DateTime(2010, 8, 12, 15, 30));
      })));
      
      it('moves to the next month & renders correctly when \'next\' button is clicked', async(inject(() {
        dom.Element element = createDatapicker();
        
        clickNextButton(element);
        microLeap();

        expect(getTitle(element)).toEqual('October 2010');
        expect(getLabels(element)).toEqual(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
        expect(getOptions(element)).toEqual([
          ['27', '28', '29', '30', '01', '02', '03'],
          ['04', '05', '06', '07', '08', '09', '10'],
          ['11', '12', '13', '14', '15', '16', '17'],
          ['18', '19', '20', '21', '22', '23', '24'],
          ['25', '26', '27', '28', '29', '30', '31'],
          ['01', '02', '03', '04', '05', '06', '07']
        ]);

        expectSelectedElement(element, 0, 3);
      })));
      
      it('updates the model only when when a day is clicked in the \'next\' month', async(inject(() {
        dom.Element element = createDatapicker();
        
        clickNextButton(element); 
        microLeap();
        expect(scope.context['date']).toEqual(new DateTime(2010, 9, 30, 15, 30));

        clickOption(element, 2, 2); 
        microLeap();
        expect(scope.context['date']).toEqual(new DateTime(2010, 10, 13, 15, 30));
      })));
      
      it('updates the calendar when a day of another month is selected', async(inject(() {
        dom.Element element = createDatapicker();
        
        clickOption(element, 4, 4); 
        microLeap();
        expect(scope.context['date']).toEqual(new DateTime(2010, 10, 1, 15, 30));
        expect(getTitle(element)).toEqual('October 2010');
        expect(getLabels(element)).toEqual(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
        expect(getOptions(element)).toEqual([
          ['27', '28', '29', '30', '01', '02', '03'],
          ['04', '05', '06', '07', '08', '09', '10'],
          ['11', '12', '13', '14', '15', '16', '17'],
          ['18', '19', '20', '21', '22', '23', '24'],
          ['25', '26', '27', '28', '29', '30', '31'],
          ['01', '02', '03', '04', '05', '06', '07']
        ]);

        expectSelectedElement(element, 0, 4);
      })));
      
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
          it('updates', async(inject(() {
            dom.Element element = createDatapicker();
            
            scope.context['date'] = new DateTime(2005, 11, 7, 23, 30);
            scope.rootScope.apply();
            
            testCalendar(element);
            expect(scope.context['date'] is DateTime).toBe(true);
          })));
        });

        describe('not to a Date object', () {

          it('to a Number, it updates calendar', async(inject(() {
            dom.Element element = createDatapicker();
            
            scope.context['date'] = new DateTime(2005, 11, 7, 23, 30).millisecondsSinceEpoch;
            scope.rootScope.apply();
            testCalendar(element);
            expect(scope.context['date'] is num).toBe(true);
          })));

          it('to a string that can be parsed by Date, it updates calendar', async(inject(() {
            dom.Element element = createDatapicker();
            
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
            testCalendar(element);
            expect(scope.context['date'] is String).toBe(true);
          })));

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
      
      it('loops between different modes', async(inject(() {
        dom.Element element = createDatapicker();
        
        expect(getTitle(element)).toEqual('September 2010');

        clickTitleButton(element);
        microLeap();
        expect(getTitle(element)).toEqual('2010');

        clickTitleButton(element);
        microLeap();
        expect(getTitle(element)).toEqual('2001 - 2020');

        clickTitleButton(element);
        microLeap();
        expect(getTitle(element)).toEqual('September 2010');
      })));
      
      describe('month selection mode', () {
        it('shows the year as title', async(inject(() {
          dom.Element element = createDatapicker();
          clickTitleButton(element);
          microLeap();

          expect(getTitle(element)).toEqual('2010');
        })));

        it('shows months as options', async(inject(() {
          dom.Element element = createDatapicker();
          clickTitleButton(element);
          microLeap();
                    
          expect(getLabels(element)).toEqual([]);
          expect(getOptions(element)).toEqual([
            ['January', 'February', 'March'],
            ['April', 'May', 'June'],
            ['July', 'August', 'September'],
            ['October', 'November', 'December']
          ]);
        })));

        it('does not change the model', async(inject(() {
          dom.Element element = createDatapicker();
          clickTitleButton(element);
          microLeap();
                    
          expect(scope.context['date']).toEqual(new DateTime(2010, 9, 30, 15, 30));
        })));

        it('has \'selected\' only the correct month', async(inject(() {
          dom.Element element = createDatapicker();
          clickTitleButton(element);
          microLeap();
          
          expectSelectedElement(element, 2, 2);
        })));

        it('moves to the previous year when \'previous\' button is clicked', async(inject(() {
          dom.Element element = createDatapicker();
          clickTitleButton(element);
          microLeap();
          
          clickPreviousButton(element);
          microLeap();

          expect(getTitle(element)).toEqual('2009');
          expect(getLabels(element)).toEqual([]);
          expect(getOptions(element)).toEqual([
            ['January', 'February', 'March'],
            ['April', 'May', 'June'],
            ['July', 'August', 'September'],
            ['October', 'November', 'December']
          ]);

          expectSelectedElement(element, null, null);
        })));

        it('moves to the next year when \'next\' button is clicked', async(inject(() {
          dom.Element element = createDatapicker();
          clickTitleButton(element);
          microLeap();
                    
          clickNextButton(element);
          microLeap();

          expect(getTitle(element)).toEqual('2011');
          expect(getLabels(element)).toEqual([]);
          expect(getOptions(element)).toEqual([
            ['January', 'February', 'March'],
            ['April', 'May', 'June'],
            ['July', 'August', 'September'],
            ['October', 'November', 'December']
          ]);

          expectSelectedElement(element, null, null);
        })));

        it('renders correctly when a month is clicked', async(inject(() {
          dom.Element element = createDatapicker();
          clickTitleButton(element);
          microLeap();
                    
          clickPreviousButton(element, 5);
          microLeap();
          expect(getTitle(element)).toEqual('2005');

          clickOption(element, 3, 1);
          microLeap();
          expect(scope.context['date']).toEqual(new DateTime(2010, 9, 30, 15, 30));
          expect(getTitle(element)).toEqual('November 2005');
          expect(getOptions(element)).toEqual([
            ['31', '01', '02', '03', '04', '05', '06'],
            ['07', '08', '09', '10', '11', '12', '13'],
            ['14', '15', '16', '17', '18', '19', '20'],
            ['21', '22', '23', '24', '25', '26', '27'],
            ['28', '29', '30', '01', '02', '03', '04']
          ]);

          clickOption(element, 2, 2);
          microLeap();
          expect(scope.context['date']).toEqual(new DateTime(2005, 11, 16, 15, 30));
        })));
      });
      
      describe('year selection mode', () {

        it('shows the year range as title', async(inject(() {
          dom.Element element = createDatapicker();
          clickTitleButton(element, 2);
          expect(getTitle(element)).toEqual('2001 - 2020');
        })));

        it('shows years as options', async(inject(() {
          dom.Element element = createDatapicker();
          clickTitleButton(element, 2);
          microLeap();
          
          expect(getLabels(element)).toEqual([]);
          expect(getOptions(element)).toEqual([
            ['2001', '2002', '2003', '2004', '2005'],
            ['2006', '2007', '2008', '2009', '2010'],
            ['2011', '2012', '2013', '2014', '2015'],
            ['2016', '2017', '2018', '2019', '2020']
          ]);
        })));

        it('does not change the model', async(inject(() {
          dom.Element element = createDatapicker();
          clickTitleButton(element, 2);
          microLeap();
                    
          expect(scope.context['date']).toEqual(new DateTime(2010, 9, 30, 15, 30));
        })));

        it('has \'selected\' only the selected year', async(inject(() {
          dom.Element element = createDatapicker();
          clickTitleButton(element, 2);
          microLeap();
                    
          expectSelectedElement(element, 1, 4);
        })));

        it('moves to the previous year set when \'previous\' button is clicked', async(inject(() {
          dom.Element element = createDatapicker();
          clickTitleButton(element, 2);
          microLeap();
          
          clickPreviousButton(element);
          microLeap();

          expect(getTitle(element)).toEqual('1981 - 2000');
          expect(getLabels(element)).toEqual([]);
          expect(getOptions(element)).toEqual([
            ['1981', '1982', '1983', '1984', '1985'],
            ['1986', '1987', '1988', '1989', '1990'],
            ['1991', '1992', '1993', '1994', '1995'],
            ['1996', '1997', '1998', '1999', '2000']
          ]);
          expectSelectedElement(element, null, null);
        })));

        it('moves to the next year set when \'next\' button is clicked', async(inject(() {
          dom.Element element = createDatapicker();
          clickTitleButton(element, 2);
          microLeap();
                    
          clickNextButton(element);
          microLeap();

          expect(getTitle(element)).toEqual('2021 - 2040');
          expect(getLabels(element)).toEqual([]);
          expect(getOptions(element)).toEqual([
            ['2021', '2022', '2023', '2024', '2025'],
            ['2026', '2027', '2028', '2029', '2030'],
            ['2031', '2032', '2033', '2034', '2035'],
            ['2036', '2037', '2038', '2039', '2040']
          ]);

          expectSelectedElement(element, null, null);
        })));
      });
      
      describe('attribute \'starting-day\'', () {
        dom.Element createDatapicker() {
          scope.context['date'] = new DateTime(2010, 9, 30, 15, 30);
          dom.Element element = _.compile('<datepicker ng-model="date" starting-day="1"></datepicker>', scope:scope);

          microLeap();
          scope.rootScope.apply();
          microLeap();
          scope.rootScope.apply();
          
          return element;
        }

        it('shows the day labels rotated', async(inject(() {
          dom.Element element = createDatapicker();
          
          expect(getLabels(element)).toEqual(['Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon']);
        })));

        it('renders the calendar days correctly', async(inject(() {
          dom.Element element = createDatapicker();
          
          expect(getOptions(element)).toEqual([
            ['31', '01', '02', '03', '04', '05', '06'],
            ['07', '08', '09', '10', '11', '12', '13'],
            ['14', '15', '16', '17', '18', '19', '20'],
            ['21', '22', '23', '24', '25', '26', '27'],
            ['28', '29', '30', '01', '02', '03', '04']
          ]);
        })));

        it('renders the week numbers correctly', async(inject(() {
          dom.Element element = createDatapicker();
          
          expect(getWeeks(element)).toEqual(['35', '36', '37', '38', '39']);
        })));
      });
      
      describe('attribute \'show-weeks\'', () {
        dom.Element weekHeader, weekElement;
        
        dom.Element createDatapicker() {
          scope.context['showWeeks'] = false;
          dom.Element element = _.compile('<datepicker ng-model="date" show-weeks="showWeeks"></datepicker>', scope:scope);

          microLeap();
          scope.rootScope.apply();
          
          weekHeader = getLabelsRow(element).querySelectorAll('td').first; // TODO: TH
          weekElement = element.shadowRoot.querySelectorAll('tbody > tr')[1].querySelectorAll('td').first;
          
          return element;
        }
        
        it('hides week numbers based on variable', async(inject(() {
          dom.Element element = createDatapicker();
          
          expect(weekHeader.text).toEqual('#');
          expect(weekHeader.classes).toContain('ng-hide');
          expect(weekElement.classes).toContain('ng-hide');
        })));

        it('toggles week numbers', async(inject(() {
          dom.Element element = createDatapicker();
          
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
        })));
      });
     
      describe('min attribute', () {
        dom.Element createDatapicker() {
          scope.context['date'] = new DateTime(2010, 9, 30, 15, 30);
          scope.context['mindate'] = new DateTime(2010, 9, 13);
          dom.Element element = _.compile('<datepicker ng-model="date" min="mindate"></datepicker>', scope:scope);

          microLeap();
          scope.rootScope.apply();
          
          return element;
        }

        it('disables appropriate days in current month', async(inject(() {
          dom.Element element = createDatapicker();
          
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(element, i, j)).toBe( (i < 2) );
            }
          }
        })));

        it('disables appropriate days when min date changes', async(inject(() {
          dom.Element element = createDatapicker();
          
          scope.context['mindate'] = new DateTime(2010, 9, 6);
          scope.rootScope.apply();
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(element, i, j)).toBe( (i < 1) );
            }
          }
        })));

        it('invalidates when model is a disabled date', async(inject(() {
          dom.Element element = createDatapicker();
          
          scope.context['mindate'] = new DateTime(2010, 9, 6);
          scope.context['date'] = new DateTime(2010, 9, 2);
          scope.rootScope.apply();
//          expect(element.classes.contains('ng-invalid')).toBeTruthy();
//          expect(element.classes.contains('ng-invalid-date-disabled')).toBeTruthy();
        })));

        it('disables all days in previous month', async(inject(() {
          dom.Element element = createDatapicker();
          
          clickPreviousButton(element);
          microLeap();
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(element, i, j)).toBe(true);
            }
          }
        })));

        it('disables no days in next month', async(inject(() {
          dom.Element element = createDatapicker();
          
          clickNextButton(element);
          microLeap();
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(element, i, j)).toBe(false);
            }
          }
        })));

        it('disables appropriate months in current year', async(inject(() {
          dom.Element element = createDatapicker();
          
          clickTitleButton(element);
          microLeap();
          for (var i = 0; i < 4; i ++) {
            for (var j = 0; j < 3; j ++) {
              expect(isDisabledOption(element, i, j)).toBe( (i < 2 || (i == 2 && j < 2)) );
            }
          }
        })));

        it('disables all months in previous year', async(inject(() {
          dom.Element element = createDatapicker();
          
          clickTitleButton(element);
          microLeap();
          clickPreviousButton(element);
          microLeap();
          for (var i = 0; i < 4; i ++) {
            for (var j = 0; j < 3; j ++) {
              expect(isDisabledOption(element, i, j)).toBe(true);
            }
          }
        })));

        it('disables no months in next year', async(inject(() {
          dom.Element element = createDatapicker();
          
          clickTitleButton(element);
          microLeap();
          clickNextButton(element);
          microLeap();
          for (var i = 0; i < 4; i ++) {
            for (var j = 0; j < 3; j ++) {
              expect(isDisabledOption(element, i, j)).toBe(false);
            }
          }
        })));

        it('enables everything before if it is cleared', async(inject(() {
          dom.Element element = createDatapicker();
          
          scope.context['mindate'] = null;
          scope.context['date'] = new DateTime(1949, 12, 20);
          scope.rootScope.apply();

          clickTitleButton(element);
          microLeap();
          for (var i = 0; i < 4; i ++) {
            for (var j = 0; j < 3; j ++) {
              expect(isDisabledOption(element, i, j)).toBe(false);
            }
          }
        })));
      });
      
      describe('max attribute', () {
        dom.Element createDatapicker() {
          scope.context['date'] = new DateTime(2010, 9, 30, 15, 30);
          scope.context['maxdate'] = new DateTime(2010, 9, 26);
          dom.Element element = _.compile('<datepicker ng-model="date" max="maxdate"></datepicker>', scope:scope);

          microLeap();
          scope.rootScope.apply();
          
          return element;
        }

        it('disables appropriate days in current month', async(inject(() {
          dom.Element element = createDatapicker();
          
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(element, i, j)).toBe( (i == 4) );
            }
          }
        })));

        it('disables appropriate days when max date changes', async(inject(() {
          dom.Element element = createDatapicker();
          
          scope.context['maxdate'] = new DateTime(2010, 9, 19);
          scope.rootScope.apply();
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(element, i, j)).toBe( (i > 2) );
            }
          }
        })));

        it('invalidates when model is a disabled date', async(inject(() {
          dom.Element element = createDatapicker();
          
          scope.context['maxdate'] = new DateTime(2010, 9, 19);
          scope.rootScope.apply();
//          expect(element.classes.contains('ng-invalid')).toBeTruthy();
//          expect(element.classes.contains('ng-invalid-date-disabled')).toBeTruthy();
        })));

        it('disables no days in previous month', async(inject(() {
          dom.Element element = createDatapicker();
          
          clickPreviousButton(element);
          microLeap();
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(element, i, j)).toBe( false );
            }
          }
        })));

        it('disables all days in next month', async(inject(() {
          dom.Element element = createDatapicker();
          
          clickNextButton(element);
          microLeap();
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(element, i, j)).toBe( true );
            }
          }
        })));

        it('disables appropriate months in current year', async(inject(() {
          dom.Element element = createDatapicker();
          
          clickTitleButton(element);
          microLeap();
          for (var i = 0; i < 4; i ++) {
            for (var j = 0; j < 3; j ++) {
              expect(isDisabledOption(element, i, j)).toBe( (i > 2 || (i == 2 && j > 2)) );
            }
          }
        })));

        it('disables no months in previous year', async(inject(() {
          dom.Element element = createDatapicker();
          
          clickTitleButton(element);
          microLeap();
          clickPreviousButton(element);
          microLeap();
          for (var i = 0; i < 4; i ++) {
            for (var j = 0; j < 3; j ++) {
              expect(isDisabledOption(element, i, j)).toBe( false );
            }
          }
        })));

        it('disables all months in next year', async(inject(() {
          dom.Element element = createDatapicker();
          
          clickTitleButton(element);
          microLeap();
          clickNextButton(element);
          microLeap();
          for (var i = 0; i < 4; i ++) {
            for (var j = 0; j < 3; j ++) {
              expect(isDisabledOption(element, i, j)).toBe( true );
            }
          }
        })));

        it('enables everything after if it is cleared', async(inject(() {
          dom.Element element = createDatapicker();
          
          scope.context['maxdate'] = null;
          scope.rootScope.apply();
          for (var i = 0; i < 5; i ++) {
            for (var j = 0; j < 7; j ++) {
              expect(isDisabledOption(element, i, j)).toBe( false );
            }
          }
        })));
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
        dom.Element createDatapicker() {
          scope.context['date'] = new DateTime(2010, 9, 30, 15, 30);
          dom.Element element = _.compile('<datepicker ng-model="date" day-format="\'d\'" day-header-format="\'EEEE\'" day-title-format="\'MMMM, yy\'" month-format="\'MMM\'" month-title-format="\'yy\'" year-format="\'yy\'" year-range="10"></datepicker>', scope:scope);

          microLeap();
          scope.rootScope.apply();
          
          return element;
        }
        
        it('changes the title format in \'day\' mode', async(inject(() {
          dom.Element element = createDatapicker();
          
          expect(getTitle(element)).toEqual('September, 10');
        })));

        it('changes the title & months format in \'month\' mode', async(inject(() {
          dom.Element element = createDatapicker();
          
          clickTitleButton(element);
          microLeap();

          expect(getTitle(element)).toEqual('10');
          expect(getOptions(element)).toEqual([
            ['Jan', 'Feb', 'Mar'],
            ['Apr', 'May', 'Jun'],
            ['Jul', 'Aug', 'Sep'],
            ['Oct', 'Nov', 'Dec']
          ]);
        })));

        it('changes the title, year format & range in \'year\' mode', async(inject(() {
          dom.Element element = createDatapicker();
          
          clickTitleButton(element, 2);
          microLeap();

          expect(getTitle(element)).toEqual('01 - 10');
          expect(getOptions(element)).toEqual([
            ['01', '02', '03', '04', '05'],
            ['06', '07', '08', '09', '10']
          ]);
        })));

        it('shows day labels', async(inject(() {
          dom.Element element = createDatapicker();
          
          expect(getLabels(element)).toEqual(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']);
        })));

        it('changes the day format', async(inject(() {
          dom.Element element = createDatapicker();
          
          expect(getOptions(element)).toEqual([
            ['30', '31', '1', '2', '3', '4', '5'],
            ['6', '7', '8', '9', '10', '11', '12'],
            ['13', '14', '15', '16', '17', '18', '19'],
            ['20', '21', '22', '23', '24', '25', '26'],
            ['27', '28', '29', '30', '1', '2', '3']
          ]);
        })));
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
        
        dom.Element createDatapicker() {
          scope.context['date'] = new DateTime(2010, 9, 30, 15, 30);
          dom.Element element = _.compile('<datepicker ng-model="date"></datepicker>', scope:scope);

          microLeap();
          scope.rootScope.apply();
          
          return element;
        }


        it('changes the title format in \'day\' mode', async(inject(() {
          dom.Element element = createDatapicker();
          
          expect(getTitle(element)).toEqual('September, 10');
        })));

        it('changes the title & months format in \'month\' mode', async(inject(() {
          dom.Element element = createDatapicker();
          
          clickTitleButton(element);
          microLeap();

          expect(getTitle(element)).toEqual('10');
          expect(getOptions(element)).toEqual([
            ['Jan', 'Feb', 'Mar'],
            ['Apr', 'May', 'Jun'],
            ['Jul', 'Aug', 'Sep'],
            ['Oct', 'Nov', 'Dec']
          ]);
        })));

        it('changes the title, year format & range in \'year\' mode', async(inject(() {
          dom.Element element = createDatapicker();
          
          clickTitleButton(element, 2);
          microLeap();

          expect(getTitle(element)).toEqual('01 - 10');
          expect(getOptions(element)).toEqual([
            ['01', '02', '03', '04', '05'],
            ['06', '07', '08', '09', '10']
          ]);
        })));

        it('changes the \'starting-day\' & day headers & format', async(inject(() {
          dom.Element element = createDatapicker();
          
          expect(getLabels(element)).toEqual(['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']);
          expect(getOptions(element)).toEqual([
            ['29', '30', '31', '1', '2', '3', '4'],
            ['5', '6', '7', '8', '9', '10', '11'],
            ['12', '13', '14', '15', '16', '17', '18'],
            ['19', '20', '21', '22', '23', '24', '25'],
            ['26', '27', '28', '29', '30', '1', '2']
          ]);
        })));

        it('changes initial visibility for weeks', async(inject(() {
          dom.Element element = createDatapicker();
          
          // TODO: TH
          expect(getLabelsRow(element).querySelectorAll('td').first.classes).toContain('ng-hide');
          var tr = element.shadowRoot.querySelectorAll('tbody > tr');
          for (var i = 0; i < 5; i++) {
            expect(tr[i].querySelectorAll('td').first.classes).toContain('ng-hide');
          }
        })));
      });
      
      describe('controller', () {
        
        Datepicker ctrl;
        
        beforeEach(inject((DatepickerConfig datepickerConfig, Scope scope, Injector injector, DateFilter dateFilter) {
          var element = new dom.DivElement();
          var attrs = new NodeAttrs(element);
          ctrl = new Datepicker.forTests(element, datepickerConfig, attrs, scope, dateFilter);
        }));
        
        
        describe('modes', () {
          var currentMode;

          it('to be an array', async(inject(() {
            expect(ctrl.modes.length).toBe(3);
          })));

          describe('\'day\'', () {
            beforeEach(inject(() {
              currentMode = ctrl.modes[0];
            }));

            it('has the appropriate name', async(inject(() {
              expect(currentMode.name).toEqual('day');
            })));

            it('returns the correct date objects', async(inject(() {
              var objs = currentMode.getVisibleDates(new DateTime(2010, 9, 1), new DateTime(2010, 9, 30)).objects;
              expect(objs.length).toBe(35);
              expect(objs[1].selected).toBeFalsy();
              expect(objs[31].selected).toBeTruthy();
            })));

            it('can compare two dates', async(inject(() {
              expect(currentMode.compare(new DateTime(2010, 9, 30), new DateTime(2010, 9, 1)) > 0).toBeTruthy();
              expect(currentMode.compare(new DateTime(2010, 9, 1), new DateTime(2010, 9, 30)) < 0).toBeTruthy();
              expect(currentMode.compare(new DateTime(2010, 9, 30, 15, 30), new DateTime(2010, 9, 30, 20, 30))).toBe(0);
            })));
          });

          describe('\'month\'', () {
            beforeEach(inject(() {
              currentMode = ctrl.modes[1];
            }));

            it('has the appropriate name', async(inject(() {
              expect(currentMode.name).toBe('month');
            })));

            it('returns the correct date objects', async(inject(() {
              var objs = currentMode.getVisibleDates(new DateTime(2010, 9, 1), new DateTime(2010, 9, 30)).objects;
              expect(objs.length).toBe(12);
              expect(objs[1].selected).toBeFalsy();
              expect(objs[8].selected).toBeTruthy();
            })));

            it('can compare two dates', async(inject(() {
              expect(currentMode.compare(new DateTime(2010, 10, 30), new DateTime(2010, 9, 1)) > 0).toBeTruthy();
              expect(currentMode.compare(new DateTime(2010, 9, 1), new DateTime(2010, 10, 30)) < 0).toBeTruthy();
              expect(currentMode.compare(new DateTime(2010, 9, 1), new DateTime(2010, 9, 30))).toBe(0);
            })));
          });

          describe('\'year\'', () {
            beforeEach(inject(() {
              currentMode = ctrl.modes[2];
            }));

            it('has the appropriate name', async(inject(() {
              expect(currentMode.name).toBe('year');
            })));

            it('returns the correct date objects', async(inject(() {
              var objs = currentMode.getVisibleDates(new DateTime(2010, 9, 1), new DateTime(2010, 9, 1)).objects;
              expect(objs.length).toBe(20);
              expect(objs[1].selected).toBeFalsy();
              expect(objs[9].selected).toBeTruthy();
            })));

            it('can compare two dates', async(inject(() {
              expect(currentMode.compare(new DateTime(2011, 9, 1), new DateTime(2010, 10, 30)) > 0).toBeTruthy();
              expect(currentMode.compare(new DateTime(2010, 10, 30), new DateTime(2011, 9, 1)) < 0).toBeTruthy();
              expect(currentMode.compare(new DateTime(2010, 11, 9), new DateTime(2010, 9, 30))).toBe(0);
            })));
          });
        });
        
        
        describe('\'isDisabled\' function', () {
          var date = new DateTime(2010, 9, 30, 15, 30);

          it('to return false if no limit is set', async(inject(() {
            expect(ctrl.isDisabled(date, 0)).toBeFalsy();
          })));

          it('to handle correctly the \'min\' date', async(inject(() {
            ctrl.minDate = new DateTime(2010, 10, 1);
            expect(ctrl.isDisabled(date, 0)).toBeTruthy();
            expect(ctrl.isDisabled(date)).toBeTruthy();

            ctrl.minDate = new DateTime(2010, 9, 1);
            expect(ctrl.isDisabled(date, 0)).toBeFalsy();
          })));

          it('to handle correctly the \'max\' date', async(inject(() {
            ctrl.maxDate = new DateTime(2010, 10, 1);
            expect(ctrl.isDisabled(date, 0)).toBeFalsy();

            ctrl.maxDate = new DateTime(2010, 9, 1);
            expect(ctrl.isDisabled(date, 0)).toBeTruthy();
            expect(ctrl.isDisabled(date)).toBeTruthy();
          })));

//          it('to handle correctly the scope \'dateDisabled\' expression', async(inject(() {
//            ctrl.setDateDisabled((attribs) {
//              return false;
//            });
//            
//            expect(ctrl.isDisabled(date, 0)).toBeFalsy();
//
//            ctrl.setDateDisabled((attribs) {
//              return true;
//            });
//            expect(ctrl.isDisabled(date, 0)).toBeTruthy();
//          })));
//        });
      });
      
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
  });
}