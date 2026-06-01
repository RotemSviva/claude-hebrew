import AppKit
import WebKit

let app = NSApplication.shared
app.setActivationPolicy(.regular)

class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate, WKUIDelegate {
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
        config.websiteDataStore = .default()

        config.userContentController.addUserScript(
            WKUserScript(source: hebrewScript(), injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        )

        webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 1200, height: 800), configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.6 Safari/605.1.15"
        webView.load(URLRequest(url: URL(string: "https://claude.ai/new")!))

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

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            NSWorkspace.shared.open(url)
        }
        return nil
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(hebrewScript()) { _, _ in }
    }

    func hebrewScript() -> String {
        return """
        (function(){
            if(window.__hebrewRTL)return;
            window.__hebrewRTL=true;
            function fix(e){
                e.style.setProperty('direction','rtl','important');
                e.style.setProperty('text-align','right','important');
            }
            function run(){
                var ed=document.querySelector('.ProseMirror[contenteditable],.tiptap[contenteditable],[data-lexical-editor][contenteditable]');
                if(ed){
                    ed.style.setProperty('direction','rtl','important');
                    ed.style.setProperty('unicode-bidi','plaintext','important');
                }
                function isHeb(s){for(var i=0;i<s.length;i++){var c=s.charCodeAt(i);if(c>=1424&&c<=1535)return true;}return false;}
                document.querySelectorAll('p,li,h1,h2,h3,blockquote').forEach(function(e){
                    if(e.style.direction==='rtl')return;
                    if(isHeb(e.textContent||''))fix(e);
                });
            }
            run();
            var t=null;
            new MutationObserver(function(){
                clearTimeout(t);
                t=setTimeout(run,600);
            }).observe(document.body,{childList:true,subtree:true});
        })();
        """
    }
}

let delegate = AppDelegate()
app.delegate = delegate
app.run()
