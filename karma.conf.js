module.exports = function(config) {
  config.set({
    basePath: '.',
    frameworks: ['dart-unittest'],

    files: [
      {pattern: 'test/angular_ui_tests.dart',  included: true},
      {pattern: '**/*.dart', included: false},
      {pattern: '**/*.html', included: false}
    ],

    exclude: [
    ],

    autoWatch: true,
    captureTimeout: 60000,
    browserNoActivityTimeout: 300000,
    

    plugins: [
      'karma-dart',
      'karma-chrome-launcher'
    ],

    browsers: ['Dartium']
  });
};
