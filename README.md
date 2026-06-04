# ARIA

Accessibility evidence workflow for mobile design QA. Helps designers verify that accessibility survived the handoff from design to development.

<!-- ![App Screenshot](Screenshots/hero.png) -->

## The Problem

Designers annotate accessibility in Figma. Developers build the product. Somewhere between those two steps, accessibility breaks — and nobody has a structured way to find out what survived. Existing tools are either design-phase (Stark, Figma plugins) or dev-phase (axe DevTools at $15K+/yr). Nothing bridges the gap for designers reviewing built products.

## What It Does

- **Screenshot annotation** — drop numbered pins on screenshots to mark exact violation locations
- **WCAG 2.2 criterion picker** — searchable, with plain-language descriptions (not just codes)
- **Severity assignment** — Critical, Major, Minor, Advisory with clear definitions
- **PDF report generation** — shareable with developers and stakeholders who'll never open the app
- **Learn section** — common mobile violations with explanations and testing guides

## Tech

- SwiftUI + SwiftData (iOS 17+)
- PDFKit for report generation
- WCAG 2.2 criteria database (18 criteria with search and categorization)
- No backend — all data stays on device

## Architecture

```
ARIA/
├── Models/          Audit, AuditScreen, Finding, WCAGCriterion (SwiftData)
├── Views/
│   ├── Audits/      Audit list, detail, creation
│   ├── Annotate/    Screenshot canvas, pin placement, finding form, criterion picker
│   ├── Report/      PDF preview and export
│   └── Learn/       WCAG reference, common violations, testing guides
├── Components/      AnnotationPin, SeverityBadge
├── Services/        MockDataService
└── Utilities/       Design tokens (ColorTokens, Typography, Spacing)
```

## Running It

1. Clone this repo
2. Open `ARIA.xcodeproj` in Xcode 15+
3. Select an iPhone simulator or your device
4. Build and run (Cmd+R)

Ships with a sample accessibility audit of Spotify iOS (5 screens, 13 findings across 4 severity levels) so you can see the full workflow immediately.

## Design Decisions

**Pin-drop annotation** — Preserves spatial context. A violation's location on screen matters as much as its description.

**Plain-language WCAG descriptions** — 70% of designers don't know WCAG codes by heart. The criterion picker teaches while you use it.

**ARIA itself meets WCAG AAA** — An accessibility tool that fails its own standards has no credibility. Every component is built with VoiceOver, Dynamic Type, and color independence.
