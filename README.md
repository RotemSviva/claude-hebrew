# Claude עברית 🇮🇱

## הבעיה
claude.ai לא תומך בעברית — הטקסט מופיע מיושר לשמאל, מה שהופך שיחות בעברית לבלתי נוחות לקריאה.

## הפתרון
פתרון פשוט שלא נוגע בקלוד עצמו — רק משנה את האופן שבו הדפדפן מציג את הדף. פותחים את האפליקציה במקום claude.ai הרגיל, והיא מיישרת אוטומטית את כל הטקסט העברי לימין — הן את מה שאתה כותב והן את המענה של קלוד.

כולל אייקון משלה, כך שהיא יושבת ב-Dock כמו כל אפליקציה רגילה.

**חשוב לדעת:** עובד רק על Mac ורק עם Safari.

---

## התקנה

1. הורד את הקובץ `ClaudeHebrew.app` מדף [Releases](../../releases)
2. גרור אותו לתיקיית Applications
3. פתח אותו — בפעם הראשונה macOS יבקש אישור לשלוט ב-Safari, לחץ OK
4. גרור את האייקון ל-Dock לנוחות

---

## For English speakers

### The Problem
claude.ai doesn't support RTL (right-to-left) text alignment, making Hebrew conversations uncomfortable to read.

### The Solution
A simple Mac app that opens claude.ai in Safari and automatically aligns all Hebrew text to the right — both what you type and Claude's responses — without touching Claude itself.

**Note:** Works on Mac with Safari only.

### Installation
1. Download `ClaudeHebrew.app` from the [Releases](../../releases) page
2. Drag it to your Applications folder
3. Open it — on first run macOS will ask permission to control Safari, click OK
4. Optionally drag the icon to your Dock

---

## For Developers

The app is written in Swift. It opens Safari via AppleScript, waits for the page to fully load, then injects JavaScript that adds `direction: rtl` to all text elements containing Hebrew content. Injection is done via `element.style.setProperty()` rather than a `<style>` tag — because claude.ai's CSP blocks external stylesheets. A MutationObserver keeps the alignment intact as Claude streams new content into the page.

### Build from source
```bash
cd claude-hebrew
swift build -c release
cp .build/release/ClaudeHebrew ClaudeHebrew.app/Contents/MacOS/ClaudeHebrew
codesign --force --sign - ClaudeHebrew.app
```

---

## License
MIT
