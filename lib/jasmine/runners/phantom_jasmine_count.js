(function() {
  var port = phantom.args[0], filter = phantom.args[1];

  if (!parseInt(port, 10) || phantom.args.length > 2) {
    console.log('Usage: run-jasmine.js PORT [spec_name_filter]');
    phantom.exit(1);
  }

  var page = require('webpage').create(), fs = require('fs');

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
        var topLevelSuites = [], suites = jasmine.getEnv().currentRunner().topLevelSuites();
        for (var i = 0; i < suites.length; i++) {
          var suite = suites[i];
          topLevelSuites.push({
            id: suite.id,
            description: suite.description
          });
        }
        return JSON.stringify({
          suites: jsApiReporter.suites(),
          top_level_suites: topLevelSuites
        });
      });
      console.log(json);
      phantom.exit(0);
    }
  });
}).call(this);
