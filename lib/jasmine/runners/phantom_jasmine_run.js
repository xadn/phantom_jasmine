(function() {
  /**
   * Wait until the test condition is true or a timeout occurs. Useful for waiting
   * on a server response or for a ui change (fadeIn, etc.) to occur.
   *
   * @param testFx javascript condition that evaluates to a boolean,
   * it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
   * as a callback function.
   * @param onReady what to do when testFx condition is fulfilled,
   * it can be passed in as a string (e.g.: "1 == 1" or "$('#bar').is(':visible')" or
   * as a callback function.
   * @param timeOutMillis the max amount of time to wait. If not specified, 3 sec is used.
   */
  function waitFor(testFx, onReady, timeOutMillis) {
    var maxtimeOutMillis = timeOutMillis ? timeOutMillis : 6000001, //< Default Max Timeout is 3s
        start = new Date().getTime(),
        condition = false,
        interval = setInterval(function() {
          if ((new Date().getTime() - start < maxtimeOutMillis) && !condition) {
            // If not time-out yet and condition not yet fulfilled
            condition = (typeof(testFx) === 'string' ? eval(testFx) : testFx()); //< defensive code
          } else {
            if (!condition) {
              // If condition still not fulfilled (timeout but condition is 'false')
              phantom.exit(1);
            } else {
              // Condition fulfilled (timeout and/or condition is 'true')
              if (typeof(onReady) === 'string') {
                eval(onReady);
              } else {
                onReady(); //< Do what it's supposed to do once the condition is fulfilled
              }
              clearInterval(interval); //< Stop this interval
            }
          }
        }, 100); //< repeat check every 100ms
  }

  var port = phantom.args[0];
  var filter = phantom.args[1];

  if (!parseInt(port, 10) || phantom.args.length > 2) {
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
      phantom.exit(1);
    } else {
      page.evaluate(function() {
        if (window.phantomInitialized) {
          return;
        }

        window.phantomInitialized = true;

        // don't do any setTimeout garbage
        jasmine.getEnv().updateInterval = null;
      });

      waitFor(function() {
        return page.evaluate(function() {
          return !jasmine.getEnv().currentRunner().queue.running;
        });
      }, function() {
        var json = page.evaluate(function() {
          var specIds = [], specs = jasmine.getEnv().currentRunner().specs();
          for (var i = 0; i < specs.length; i++) {
            specIds.push(specs[i].id);
          }
          return JSON.stringify(jsApiReporter.resultsForSpecs(specIds));
        });
        console.log(json);
        phantom.exit(0);
      }, 1000 * 60 * 20); // wait 20 minutes (CI can be slow)
    }
  });
}).call(this);
