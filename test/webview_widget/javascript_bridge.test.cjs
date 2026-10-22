const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const vm = require('node:vm');

const bridgeFile = process.env.CHATWOOT_BRIDGE_SOURCE || path.join(
  __dirname, '../../lib/ui/webview_widget/javascript_bridge.dart');
const source = fs.readFileSync(bridgeFile, 'utf8');
const script = source.match(/r'''([\s\S]*?)'''/)[1];

function createPage(initialBridge) {
  const listeners = new Map();
  const pagePostMessage = () => {};
  const window = {
    postMessage: pagePostMessage,
    addEventListener(name, listener) {
      const callbacks = listeners.get(name) || [];
      callbacks.push(listener);
      listeners.set(name, callbacks);
    },
  };
  if (initialBridge) window.flutter_inappwebview = initialBridge;
  vm.runInNewContext(script, {window}, {timeout: 1000});
  return {
    window,
    pagePostMessage,
    ready() {
      for (const listener of listeners.get('flutterInAppWebViewPlatformReady') || []) {
        listener();
      }
    },
  };
}

test('queues the loaded event before Android installs the bridge', () => {
  const page = createPage();
  const loaded = 'chatwoot-widget:{"event":"loaded","config":{"authToken":"test-only"}}';
  assert.doesNotThrow(() => page.window.ReactNativeWebView.postMessage(loaded));
  const calls = [];
  page.window.flutter_inappwebview = {callHandler: (...args) => calls.push(args)};
  page.ready();
  assert.deepEqual(calls, [['ReactNativeWebView', loaded]]);
});

test('replays queued events in order without duplicates on repeated readiness', () => {
  const page = createPage();
  page.window.ReactNativeWebView.postMessage('loaded');
  page.window.ReactNativeWebView.postMessage('close-widget');
  const messages = [];
  page.window.flutter_inappwebview = {callHandler: (_, message) => messages.push(message)};
  page.ready();
  page.ready();
  page.window.ReactNativeWebView.postMessage('later');
  assert.deepEqual(messages, ['loaded', 'close-widget', 'later']);
});

test('delivers immediately when the bridge was ready before script injection', () => {
  const messages = [];
  const page = createPage({callHandler: (_, message) => messages.push(message)});
  page.window.ReactNativeWebView.postMessage('loaded');
  assert.deepEqual(messages, ['loaded']);
});

test('waits when the bridge object exists without callHandler', () => {
  const bridge = {};
  const page = createPage(bridge);
  assert.doesNotThrow(() => page.window.ReactNativeWebView.postMessage('loaded'));
  const messages = [];
  bridge.callHandler = (_, message) => messages.push(message);
  page.ready();
  assert.deepEqual(messages, ['loaded']);
});

test('retains an event if native handoff throws before readiness', () => {
  let ready = false;
  const messages = [];
  const page = createPage({callHandler: (_, message) => {
    if (!ready) throw new Error('native bridge not ready');
    messages.push(message);
  }});
  assert.doesNotThrow(() => page.window.ReactNativeWebView.postMessage('loaded'));
  ready = true;
  page.ready();
  assert.deepEqual(messages, ['loaded']);
});

test('flushes earlier events when a later message finds the bridge ready', () => {
  const page = createPage();
  page.window.ReactNativeWebView.postMessage('loaded');
  const messages = [];
  page.window.flutter_inappwebview = {callHandler: (_, message) => messages.push(message)};
  page.window.ReactNativeWebView.postMessage('later');
  assert.deepEqual(messages, ['loaded', 'later']);
});

test('handles reentrant messages without delivering the first event twice', () => {
  const page = createPage();
  const messages = [];
  page.window.flutter_inappwebview = {callHandler: (_, message) => {
    messages.push(message);
    if (message === 'loaded') page.window.ReactNativeWebView.postMessage('nested');
  }};
  page.window.ReactNativeWebView.postMessage('loaded');
  assert.deepEqual(messages, ['loaded', 'nested']);
});

test('preserves page postMessage for user, locale and custom-attribute commands', () => {
  const page = createPage();
  assert.equal(page.window.postMessage, page.pagePostMessage);
});
