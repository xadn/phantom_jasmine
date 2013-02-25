(function() {
  var port = phantom.args[0];
  var filter = phantom.args[1];

  if (!parseInt(port, 10) || phantom.args.length > 2) {
    console.log('Usage: run-jasmine.js PORT [spec_name_filter]');
    phantom.exit(1);
  }

  var page = require('webpage').create();
  var fs = require('fs');

  var url = 'http://localhost:' + port;
  if (filter) {
    url += '?spec=' + encodeURIComponent(filter);
  }

  page.open(url, function(status) {
    if (status !== "success") {
      console.log("Unable to access network");
      phantom.exit(1);
    } else {
      var json = page.evaluate(function() {
        var jasmineEnv = {
          suites: jsApiReporter.suites(),
          top_level_suites: jasmine.getEnv().currentRunner().topLevelSuites().map(function(suite) {
            return {
              id: suite.id,
              description: suite.description
            };
          })
        };
        return JSON.stringify(jasmineEnv);
      });
      fs.write('/dev/stdout', json, 'w');
      phantom.exit(0);
    }
  });
}).call(this);
