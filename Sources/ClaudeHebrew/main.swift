import AppKit
import Foundation

let app = NSApplication.shared
app.setActivationPolicy(.regular)

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Small status window — needed so macOS shows the Automation permission dialog
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 80),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        window.title = "Claude עברית"
        window.center()
        window.makeKeyAndOrderFront(nil)

        let label = NSTextField(labelWithString: "פותח Claude עם עברית...")
        label.frame = NSRect(x: 20, y: 25, width: 240, height: 30)
        label.font = NSFont.systemFont(ofSize: 15)
        label.alignment = .center
        window.contentView?.addSubview(label)

        NSApp.activate(ignoringOtherApps: true)

        DispatchQueue.global(qos: .userInitiated).async {
            self.openAndInject()
            DispatchQueue.main.async { NSApp.terminate(nil) }
        }
    }

    func openAndInject() {
        let js = "(function(){" +
            "if(window.__hebrewRTL)return;" +
            "window.__hebrewRTL=true;" +
            "function fix(e){" +
                "e.style.setProperty('direction','rtl','important');" +
                "e.style.setProperty('text-align','right','important');" +
            "}" +
            "function run(){" +
                "var ed=document.querySelector('[data-lexical-editor][contenteditable]');" +
                "if(ed){" +
                    "ed.style.setProperty('direction','rtl','important');" +
                    "ed.style.setProperty('unicode-bidi','plaintext','important');" +
                "}" +
                "var heb=/[\\u0590-\\u05FF]/;" +
                "document.querySelectorAll('p,li,h1,h2,h3,blockquote').forEach(function(e){" +
                    "if(e.style.direction==='rtl')return;" +
                    "if(e.closest('button,a,[role=\"button\"]'))return;" +
                    "if(heb.test(e.textContent||''))fix(e);" +
                "});" +
            "}" +
            "run();" +
            "new MutationObserver(function(mutations){" +
                "mutations.forEach(function(m){" +
                    "m.addedNodes.forEach(function(node){" +
                        "if(node.nodeType!==1)return;" +
                        "node.querySelectorAll('p,li,h1,h2,h3,blockquote').forEach(function(e){" +
                            "if(e.style.direction==='rtl')return;" +
                            "if(e.closest('button,a,[role=\"button\"]'))return;" +
                            "if(heb.test(e.textContent||''))fix(e);" +
                        "});" +
                    "});" +
                "});" +
            "}).observe(document.body,{childList:true,subtree:true});" +
        "})();"

        let script = """
        tell application "Safari"
            activate
            open location "https://claude.ai/new"
            repeat 40 times
                delay 1
                try
                    if URL of front document contains "claude.ai" then
                        if (do JavaScript "document.readyState" in front document) is "complete" then
                            if (do JavaScript "!!document.querySelector('[data-lexical-editor]')" in front document) is "true" then
                                do JavaScript "\(js)" in front document
                                return
                            end if
                        end if
                    end if
                end try
            end repeat
        end tell
        """

        var err: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&err)
    }
}

let delegate = AppDelegate()
app.delegate = delegate
app.run()
