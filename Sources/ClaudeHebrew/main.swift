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
        // CSS encoded as base64 — avoids all Swift/JS quote escaping issues
        let css = """
            /* Input area: force RTL so Hebrew flows right-to-left */
            textarea,
            [contenteditable],
            [role=textbox],
            [data-lexical-editor] {
                direction: rtl !important;
                text-align: right !important;
                unicode-bidi: plaintext !important;
            }
            /* Message text: force RTL, inline English words stay readable */
            p, li, blockquote {
                direction: rtl !important;
                text-align: right !important;
                unicode-bidi: embed !important;
            }
            /* Code blocks stay LTR */
            code, pre {
                direction: ltr !important;
                text-align: left !important;
                unicode-bidi: embed !important;
            }
            """
        let b64 = Data(css.utf8).base64EncodedString()
        return """
            (function(){
                if (document.getElementById('claude-hebrew-rtl')) return;
                var s = document.createElement('style');
                s.id = 'claude-hebrew-rtl';
                s.textContent = atob('\(b64)');
                (document.head || document.documentElement).appendChild(s);
            })();
            """
    }
}

let delegate = AppDelegate()
app.delegate = delegate
app.run()
