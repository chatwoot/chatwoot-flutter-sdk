/// Forward widget events after InAppWebView has installed its native bridge.
///
/// Android WebViews without DOCUMENT_START_SCRIPT can load the widget before
/// callHandler exists. Retain those events, including `loaded`, until ready.
const chatwootJavaScriptBridge = r'''
(function () {
  var pendingMessages = [];
  var flushing = false;

  function flushMessages() {
    var bridge = window.flutter_inappwebview;
    if (flushing || !bridge || typeof bridge.callHandler !== 'function') {
      return;
    }

    flushing = true;
    try {
      while (pendingMessages.length > 0) {
        // Keep the event queued if the native bridge is not ready yet.
        bridge.callHandler('ReactNativeWebView', pendingMessages[0]);
        pendingMessages.shift();
      }
    } catch (error) {
      // The platform-ready event (or the next message) will retry delivery.
    } finally {
      flushing = false;
    }
  }

  window.addEventListener('flutterInAppWebViewPlatformReady', flushMessages);
  window.ReactNativeWebView = {
    postMessage: function (message) {
      pendingMessages.push(message);
      flushMessages();
    }
  };
})();
''';
