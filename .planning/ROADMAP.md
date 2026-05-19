# Roadmap — claude-hebrew

## Summary
**2 phases** | **4 requirements** | Coarse granularity

---

## Phase 1: שיפור RTL ב-claude-hebrew

**Goal:** טקסט מעורב עברית/אנגלית מיושר נכון לימין בכל מצב

**Requirements:** RTL-01, RTL-03

**Plans:**
1. שיפור CSS לפסקאות המתחילות במילה אנגלית
2. בדיקה ותיקון של קוד-בלוקים (LTR)
3. עדכון ה-.app ב-/Applications

**Success Criteria:**
1. פסקה המתחילה ב-"GSD הוא..." מוצגת מיושרת לימין
2. בלוק קוד נשאר שמאלה ב-LTR
3. טקסט עברית טהור — מיושר לימין ✓
4. המשתמש מאשר שהחוויה טבעית לעברית

**Status:** 🔄 בתהליך (RTL-01 כמעט מוכן, RTL-03 מוכן)

---

## Phase 2: RTL ב-Claude Desktop

**Goal:** Claude Desktop המותקן מציג RTL ללא שינוי ב-signed bundle

**Requirements:** RTL-02, RTL-04

**Plans:**
1. מחקר: Electron user data directory — אפשרויות CSS injection
2. בדיקת launch wrapper עם flags
3. יישום ובדיקה
4. שמירת הגדרות בין הפעלות

**Success Criteria:**
1. Claude Desktop נפתח עם RTL ללא הודעת אבטחה
2. כתיבה בעברית מיושרת לימין
3. תגובות מיושרות לימין (כולל טקסט מעורב)
4. RTL נשמר לאחר סגירה ופתיחה מחדש

**Status:** ⏳ ממתין לשלב 1

---

## Depends On
- Phase 2 depends on Phase 1 (CSS pattern validated first)
