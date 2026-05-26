// inject-rtl.js — injects Hebrew RTL CSS into Claude Desktop via CDP
const http = require('http');

const INJECTION = `(function(){
  if (window.__hebrewRTLActive) return;
  window.__hebrewRTLActive = true;

  var s = document.createElement('style');
  s.textContent = 'textarea,[contenteditable],[role=textbox]{direction:rtl!important;text-align:right!important;unicode-bidi:plaintext!important}code,pre,pre *{direction:ltr!important;text-align:left!important}';
  (document.head||document.documentElement).appendChild(s);

  var hebrew = /[\\u0590-\\u05FF\\uFB1D-\\uFB4F]/;
  var skip   = /^(SCRIPT|STYLE|CODE|PRE|INPUT|TEXTAREA)$/;

  function fixEl(el) {
    if (!el || el.nodeType !== 1 || skip.test(el.tagName)) return;
    if (hebrew.test(el.innerText || '')) {
      el.style.direction = 'rtl';
      el.style.textAlign = 'right';
    }
  }

  function fixAll(root) {
    (root||document).querySelectorAll('p,li,h1,h2,h3,h4,h5,h6,blockquote,td,div')
      .forEach(fixEl);
  }

  fixAll(document);

  new MutationObserver(function(muts){
    muts.forEach(function(m){
      m.addedNodes.forEach(function(n){
        if (n.nodeType === 1) fixAll(n);
      });
    });
  }).observe(document.body, {childList:true, subtree:true});
})();`;

function getPages(callback) {
  http.get('http://localhost:9222/json', res => {
    let data = '';
    res.on('data', d => data += d);
    res.on('end', () => {
      try { callback(null, JSON.parse(data)); }
      catch(e) { callback(e); }
    });
  }).on('error', callback);
}

function injectToPage(wsUrl) {
  const ws = new WebSocket(wsUrl);
  ws.addEventListener('open', () => {
    ws.send(JSON.stringify({
      id: 1,
      method: 'Runtime.evaluate',
      params: { expression: INJECTION }
    }));
    console.log('✓ RTL injected');
  });
  ws.addEventListener('close', () => {
    console.log('Connection closed — retrying in 3s...');
    setTimeout(() => injectToPage(wsUrl), 3000);
  });
  ws.addEventListener('error', () => {});
}

function run() {
  getPages((err, pages) => {
    if (err || !pages || pages.length === 0) {
      process.stdout.write('.');
      setTimeout(run, 1000);
      return;
    }
    const page = pages.find(p => p.type === 'page') || pages[0];
    if (!page || !page.webSocketDebuggerUrl) {
      setTimeout(run, 1000);
      return;
    }
    console.log('\nConnected to Claude Desktop');
    injectToPage(page.webSocketDebuggerUrl);
  });
}

console.log('Waiting for Claude Desktop', process.version);
setTimeout(run, 2000);
