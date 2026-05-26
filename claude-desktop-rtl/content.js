(function () {
  if (document.getElementById('claude-rtl-style')) return;
  const css = `
    textarea, [contenteditable], [role=textbox], [data-lexical-editor] {
      direction: rtl !important;
      text-align: right !important;
      unicode-bidi: plaintext !important;
    }
    p, li, blockquote {
      direction: rtl !important;
      text-align: right !important;
      unicode-bidi: embed !important;
    }
    code, pre {
      direction: ltr !important;
      text-align: left !important;
      unicode-bidi: embed !important;
    }
  `;
  const s = document.createElement('style');
  s.id = 'claude-rtl-style';
  s.textContent = css;
  (document.head || document.documentElement).appendChild(s);
})();
