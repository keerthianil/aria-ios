# ARIA

An accessibility evidence workflow for mobile design QA — built for designers, not developers.

<!-- ![App Screenshot](Screenshots/hero.png) -->

## About

ARIA helps product designers verify that the accessibility they annotated in Figma actually survived implementation. It provides a structured, mobile-native workflow for collecting evidence, documenting violations against WCAG 2.2, and generating reports that developers and stakeholders can act on.

## The Problem

Every accessibility tool falls into one of two camps: design-phase tools that check Figma files but can't verify built products, or developer tools that test code but cost $15K+ and produce reports designers can't use. The gap between them is where accessibility breaks — in the handoff from design to development.

## Key Features

- **Screenshot Annotation** — Drop pins on screenshots to mark exact violation locations
- **WCAG 2.2 Criterion Picker** — Searchable, with plain-language descriptions
- **Severity Assignment** — Critical, Major, Minor, Advisory with clear definitions
- **PDF Report Generation** — Shareable reports for developers and stakeholders
- **Learn Section** — Common mobile violations with visual examples

## Tech Stack

- SwiftUI
- SwiftData
- PDFKit
- iOS 17+

## Running the Project

1. Clone this repo
2. Open `ARIA.xcodeproj` in Xcode 15+
3. Build and run on Simulator (iPhone 15 Pro recommended)

## Architecture

```
ARIA/
├── Models/          SwiftData models (Audit, AuditScreen, Finding, WCAGCriterion)
├── Views/           Screen views organized by section (Audits, Annotate, Report, Learn)
├── Components/      Reusable UI (AnnotationPin, ContrastChecker, SeverityBadge)
├── Services/        PDF generation, photo import, mock data
├── Utilities/       Design tokens (ColorTokens, Typography, Spacing)
└── Resources/       Asset catalog, WCAG criteria data
```

## License

This project is for educational and portfolio purposes.
