# Claude Hebrew RTL — Solution

## What Was the Problem

The original app was a **WKWebView wrapper** — a "frame" that displayed claude.ai inside a macOS app using Safari's embedded web engine. This approach failed because:

- claude.ai froze during streaming responses (even with zero CSS/JS injected)
- Page layout broke (sidebar overlapped main content)
- Proven root cause: WKWebView cannot reliably run claude.ai

## What Was Tried and Failed

1. Various CSS fixes — broke the layout in different ways
2. Removing all JavaScript — still froze
3. Chrome user-agent — broke the layout differently
4. Bookmarklet — blocked by claude.ai's Content Security Policy

## What Fixed It

Rebuilt the app using a completely different architecture:

1. **Opens claude.ai in real Safari** (not WKWebView) via AppleScript
2. **Waits for the page to fully load** — polls until `document.readyState === "complete"` AND the Lexical editor element exists
3. **Injects RTL via `element.style.setProperty()`** — direct DOM manipulation, NOT a `<style>` tag. This bypasses CSP restrictions that block `<style>` injection.
4. **MutationObserver with 600ms debounce** — applies RTL to new Hebrew content as Claude streams responses
5. **Small status window** — required so macOS shows the Automation permission dialog ("ClaudeHebrew wants to control Safari") on first run

## Key Technical Insight

CSP (Content Security Policy) blocks `document.createElement('style')` injection.
`element.style.setProperty('direction', 'rtl', 'important')` is **not** blocked by CSP — it is pure JavaScript DOM manipulation.

## First Run

macOS will ask: **"ClaudeHebrew wants to control Safari"** — click OK once.

## File Structure

- `Sources/ClaudeHebrew/main.swift` — the Swift app (AppleScript launcher)
- `ClaudeHebrew.app` — the clickable app with icon
- `AppIcon.icns` — the app icon

## Rebuild Command

```bash
cd /Users/home-work/claude-hebrew
swift build -c release
cp .build/release/ClaudeHebrew ClaudeHebrew.app/Contents/MacOS/ClaudeHebrew
codesign --force --sign - ClaudeHebrew.app
```
