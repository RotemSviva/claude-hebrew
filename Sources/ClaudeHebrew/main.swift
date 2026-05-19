import AppKit
import WebKit

let app = NSApplication.shared
app.setActivationPolicy(.regular)

class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate {
    var window: NSWindow!
    var webView: WKWebView!

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenu()
        setupWindow()
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    func setupMenu() {
        let menu = NSMenu()

        let appItem = NSMenuItem()
        menu.addItem(appItem)
        let appMenu = NSMenu()
        appItem.submenu = appMenu
        appMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        // Edit menu — needed for copy/paste keyboard shortcuts in WebView
        let editItem = NSMenuItem(title: "Edit", action: nil, keyEquivalent: "")
        menu.addItem(editItem)
        let editMenu = NSMenu(title: "Edit")
        editItem.submenu = editMenu
        editMenu.addItem(NSMenuItem(title: "Cut",        action: #selector(NSText.cut(_:)),       keyEquivalent: "x"))
        editMenu.addItem(NSMenuItem(title: "Copy",       action: #selector(NSText.copy(_:)),      keyEquivalent: "c"))
        editMenu.addItem(NSMenuItem(title: "Paste",      action: #selector(NSText.paste(_:)),     keyEquivalent: "v"))
        editMenu.addItem(NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))

        NSApp.mainMenu = menu
    }

    func setupWindow() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()   // persistent login cookies

        config.userContentController.addUserScript(
            WKUserScript(source: hebrewScript(), injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        )

        webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 1200, height: 800), configuration: config)
        webView.navigationDelegate = self
        if #available(macOS 13.3, *) { webView.isInspectable = true }
        // Identify as Safari so claude.ai doesn't block the WebView
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15"
        webView.load(URLRequest(url: URL(string: "https://claude.ai")!))

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1200, height: 800),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Claude"
        window.minSize = NSSize(width: 600, height: 400)
        window.contentView = webView
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    // Re-inject after SPA navigations
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(hebrewScript()) { _, _ in }
    }

    func hebrewScript() -> String {
        return """
        (function(){
            if (window.__hebrewRTLActive) return;
            window.__hebrewRTLActive = true;

            // CSS for input area
            var s = document.createElement('style');
            s.textContent = [
                'textarea,[contenteditable],[role=textbox],[data-lexical-editor]{',
                '  direction:rtl!important;text-align:right!important;unicode-bidi:plaintext!important}',
                'code,pre,pre *{direction:ltr!important;text-align:left!important}'
            ].join('');
            (document.head||document.documentElement).appendChild(s);

            var hebrew = /[\\u0590-\\u05FF\\uFB1D-\\uFB4F]/;
            var skip   = /^(SCRIPT|STYLE|CODE|PRE|INPUT|TEXTAREA)$/;

            function fixEl(el) {
                if (!el || el.nodeType !== 1 || skip.test(el.tagName)) return;
                if (hebrew.test(el.innerText || '')) {
                    el.style.direction  = 'rtl';
                    el.style.textAlign  = 'right';
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
        })();
        """
    }
}

let delegate = AppDelegate()
app.delegate = delegate
app.run()
