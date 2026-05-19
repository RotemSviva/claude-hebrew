# claude-hebrew — Project Context

## What This Is

macOS app that gives Hebrew speakers a fully right-aligned (RTL) interface for Claude AI.
Currently a WebView wrapper for claude.ai with CSS injection. Goal: extend the same approach
to work with Claude Desktop (Electron) so users can write Hebrew and receive right-aligned
responses — including mixed Hebrew/English text — without modifying the signed app bundle.

## Core Value

**Hebrew speakers can use Claude naturally** — writing right-to-left, reading responses
right-aligned, without fighting the interface or switching apps.

## Context

- **Users:** Hebrew-speaking professionals who need Claude for daily work
- **Platform:** macOS
- **Language:** Hebrew + mixed Hebrew/English text
- **Privacy:** No external servers beyond Anthropic — no Google/calendar integrations

## What's Already Built (Validated)

- ✓ WebView wrapper around claude.ai (`main.swift`)
- ✓ CSS injection for RTL in input area (textarea, contenteditable)
- ✓ App icon — orange (Claude brand color) + ע letter + RTL lines
- ✓ `.app` bundle with Info.plist, installed in `/Applications`
- ✓ Paragraph responses forced RTL (`direction: rtl; unicode-bidi: embed`)

## Requirements

### Validated
- ✓ Input area right-aligned for Hebrew typing — existing
- ✓ App installable and launchable from /Applications — existing

### Active
- [ ] **RTL-01**: Mixed Hebrew/English response paragraphs right-aligned (even when starting with English word)
- [ ] **RTL-02**: Claude Desktop (Electron) displays RTL without modifying signed app bundle
- [ ] **RTL-03**: Code blocks in responses remain left-aligned (LTR)
- [ ] **RTL-04**: Claude Desktop RTL persists across app restarts

### Out of Scope
- Gmail/Google Calendar integration — privacy concern, user explicitly declined
- Modifying Claude.app signed bundle — breaks macOS code signing (learned from prior incident)
- iOS/iPadOS support — macOS only

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| CSS injection via WebView | Proven approach, no code signing risk | Implemented in claude-hebrew ✓ |
| Don't touch Claude.app bundle | Prior session broke the app this way | Hard constraint |
| Electron user data approach for Claude Desktop | Only safe injection vector | To be explored in Phase 2 |
| Orange icon (#D97757) with ע | Claude brand color + first letter of עברית | Implemented ✓ |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition:**
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active

---
*Last updated: 2026-05-19 after initialization*
