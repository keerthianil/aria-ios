# ARIA — Mobile Accessibility Audit Tool: UX Research Document

## 1. Competitive Audit

### Tool Landscape

| Tool | Platform | Target User | Mobile App Testing | Design-Phase | Pricing |
|---|---|---|---|---|---|
| **axe DevTools** (Deque) | Browser ext, iOS/Android SDK, CI/CD | Developers, QA | Yes (strong) | No | Free tier + enterprise ($15K–$250K/yr) |
| **Stark** | Figma/Sketch/XD plugin, browser ext | Designers, PMs | No (mockups only) | Yes (strong) | Free basic; $198/user/yr–$21K/yr |
| **Apple Accessibility Inspector** | Xcode (macOS only) | iOS developers | Yes (iOS only) | No | Free (with Xcode) |
| **WAVE** (WebAIM) | Browser ext, API | Web authors, devs | No (web only) | No | Free ext; API $0.04/credit |
| **Accessibility Insights** (Microsoft) | Chrome/Edge ext, Windows, Android | Developers, testers | Partial (Android only) | No | Free, open-source |
| **BrowserStack** | Cloud platform | QA teams | Yes (real devices) | No | Enterprise pricing |
| **Google Accessibility Scanner** | Android app | Manual testers | Yes (Android only) | No | Free |

### Key Findings

1. **Every tool picks design OR development** — nobody bridges the handoff gap where accessibility intent gets lost.
2. **Automated scanning catches only 30–40% of WCAG issues** — the remaining 60–70% requires human judgment that designers are best positioned to provide.
3. **No tool produces a cross-functional artifact** that designers, developers, and PMs can all read and act on.
4. **Screen reader testing produces zero documentation** — testing happens, evidence vanishes.
5. **No iOS on-device audit app exists** — Android has Google's Accessibility Scanner; iOS has nothing equivalent for non-developers.

---

## 2. Designer Pain Points

### Pain Point 1: Developer Tool Lock-Out
Nearly all mobile accessibility testing tools (axe DevTools, Accessibility Inspector, XCUITest) require Xcode, Android Studio, or CLI proficiency. Designers without code access are locked out of meaningful auditing.

### Pain Point 2: Design-Phase Tools Check a Narrow Slice
Stark can check contrast and simulate vision impairments in Figma, but cannot detect focus behavior, form label associations, navigation consistency, or semantic structure — issues that only emerge in built products.

### Pain Point 3: Pricing Walls
Stark's advanced features (focus order, landmarks, alt-text annotations, touch targets) are locked behind paid plans ($198–$21,000/yr). Individual designers and small teams are priced out.

### Pain Point 4: Mobile-Specific Issues Are Invisible During Design
Buttons that look fine at desktop viewport shrink below touch target minimums on mobile. Contrast failures at narrow widths, drag gesture alternatives, and focus indicator visibility only emerge on real devices.

### Pain Point 5: Screen Reader Testing Requires Expertise Designers Don't Have
VoiceOver/TalkBack testing requires genuine proficiency. NNGroup research found sessions require 30+ extra minutes for setup, remote testing distorts screen reader output, and mobile screen readers parse content sequentially — fundamentally different from visual scanning.

### Pain Point 6: WCAG Documentation Is Dense
Around 80% of accessibility issues originate from design decisions, but WCAG documentation is impenetrable for designers. The W3C's "Guidance on Applying WCAG 2.2 to Mobile Applications" is still a draft as of 2026.

### Pain Point 7: Design-to-Development Handoff Loses Accessibility Intent
Accessibility requirements aren't visually represented in mockups. Engineers make assumptions, accessibility enters late, and only 28% of organizations address accessibility during design (down from 32% in 2024).

*Sources: NNGroup, Level Access State of Digital Accessibility Report 2025–2026, Sparkbox Stark review, G2 user reviews, A11Y Collective, W3C*

---

## 3. Gap Analysis

### The Verification Gap

```
Design Phase          Handoff          Built Product          QA/Release
─────────────         ──────           ──────────────         ──────────
Stark, Figma          ??? GAP ???      Xcode Inspector        axe DevTools
plugins                                (dev-only)             BrowserStack
                                                              (enterprise)

                      ▲▲▲ ARIA sits here ▲▲▲
```

ARIA occupies the **post-build, pre-QA verification gap** — the moment when a designer has a build on their phone and wants to check: "Did my accessibility intent survive the handoff?"

### What Makes ARIA Unique

| Dimension | Current Tools | ARIA |
|---|---|---|
| **Who** | Developers or certified auditors | Designers, design QA leads, PMs |
| **Platform** | Web browser, macOS desktop, CI/CD | iOS-native, on your phone |
| **Input** | Live DOM, accessibility tree API | Screenshots — works on any app |
| **Output** | JSON/HTML developer reports | Visual PDF audit report |
| **Learning curve** | WCAG expertise required | WCAG criterion picker teaches as you go |
| **Price** | $0 (limited) to $250K/yr | Free (standalone app) |

---

## 4. WCAG 2.2 Mobile Criteria Summary

### The ~30 Most Relevant Mobile Criteria (organized by category)

**Perceivable (11 criteria)**
- 1.1.1 Non-text Content (A) — alt text for images/icons
- 1.3.1 Info and Relationships (A) — semantic structure
- 1.3.4 Orientation (AA) — no forced orientation
- 1.3.5 Identify Input Purpose (AA) — autofill support
- 1.4.1 Use of Color (A) — color isn't the only indicator
- 1.4.3 Contrast Minimum (AA) — 4.5:1 for text, 3:1 for large text
- 1.4.4 Resize Text (AA) — Dynamic Type support
- 1.4.10 Reflow (AA) — no horizontal scrolling at 320px
- 1.4.11 Non-text Contrast (AA) — 3:1 for UI components
- 1.4.12 Text Spacing (AA) — adjustable spacing
- 1.4.13 Content on Hover or Focus (AA) — dismissible/hoverable

**Operable (11 criteria)**
- 2.1.1 Keyboard (A) — works with external keyboard/Switch Control
- 2.1.2 No Keyboard Trap (A) — focus can always escape
- 2.4.3 Focus Order (A) — logical focus sequence
- 2.4.6 Headings and Labels (AA) — descriptive headings
- 2.4.7 Focus Visible (AA) — visible focus indicator
- 2.4.11 Focus Not Obscured (AA) — *WCAG 2.2 new*
- 2.5.1 Pointer Gestures (A) — single-pointer alternatives
- 2.5.5 Target Size Enhanced (AAA) — 44x44pt (Apple HIG)
- 2.5.7 Dragging Movements (AA) — *WCAG 2.2 new*
- 2.5.8 Target Size Minimum (AA) — 24x24pt *WCAG 2.2 new*

**Understandable (6 criteria)**
- 3.1.1 Language of Page (A)
- 3.2.1 On Focus (A) — no unexpected context changes
- 3.2.6 Consistent Help (A) — *WCAG 2.2 new*
- 3.3.1 Error Identification (A)
- 3.3.2 Labels or Instructions (A)
- 3.3.7 Redundant Entry (A) — *WCAG 2.2 new*

**Robust (2 criteria)**
- 4.1.2 Name, Role, Value (A) — accessible API exposure
- 4.1.3 Status Messages (AA) — announced without focus

---

## 5. Annotation Pattern Analysis

### How Current Tools Mark Violations

| Pattern | Used By | Pros | Cons |
|---|---|---|---|
| **Colored icon overlays** | WAVE | At-a-glance overview | Clutters complex pages |
| **Red rectangular outlines** | Android Scanner, BrowserStack | Clear element highlighting | No severity differentiation |
| **Numbered circles** | Accessibility Insights, VA.gov | Shows sequence/focus order | Requires separate detail panel |
| **Pin drops + detail cards** | VA.gov, Stark | Spatial context + explanation | Can overlap on dense UIs |
| **Element screenshot + highlight** | axe DevTools | Shareable individual context | One issue at a time |

### ARIA's Annotation Approach: Numbered Pin Markers

We chose **numbered pins with severity-color fill** because:
1. **Spatial context matters** — a finding about a button's touch target is meaningless without seeing WHERE on the screen it is
2. **Numbered markers create a shared reference language** — "Finding #3 on the Search screen" is unambiguous in a team discussion
3. **Severity colors provide instant triage** — red (critical), orange (major), yellow (moderate), gray-blue (minor)
4. **Pin-on-screenshot is the most portable format** — it works in PDFs, slides, and screenshots without interactive tooling

### Professional Audit Report Structure

Based on research of VPAT reports, Deque audit deliverables, and W3C report templates:

1. **Cover page** — app name, auditor, date, platform
2. **Executive summary** — total findings by severity, screens audited
3. **Findings by screen** — each finding with WCAG criterion, severity, description, recommendation
4. **Annotated screenshots** — pins on screenshots showing violation locations
5. **Remediation roadmap** — prioritized fixes by severity

ARIA generates sections 1–3 as a shareable PDF. Section 4 is visible in-app during annotation.

---

## 6. Design Principles

### Principle 1: Evidence Over Opinion
Every finding is anchored to a specific location on a specific screen, tagged with a WCAG criterion, and rated by severity. This transforms "I think this might have a contrast issue" into "Finding #3: Text contrast is 2.8:1, needs 4.5:1 per WCAG 1.4.3, Critical severity."

### Principle 2: The Report Is the Product
The shareable PDF audit report is ARIA's primary output — not the app itself. The annotation experience exists to produce a document that travels to developers, PMs, and stakeholders who will never open ARIA.

### Principle 3: Extend Designer Tools, Don't Simplify Developer Tools
ARIA doesn't try to be a stripped-down Xcode Inspector. It starts from the designer's workflow (screenshots, visual annotation, severity ratings) and adds just enough WCAG structure to make findings actionable for developers.

### Principle 4: Teach Through Use
The WCAG criterion picker uses plain language so designers can find "contrast" or "touch target" without memorizing specification numbers. The Learn tab surfaces the 6 most common mobile violations with real-world prevalence stats.

### Principle 5: Accessible First
An accessibility audit tool that isn't itself accessible has no credibility. ARIA meets WCAG AA throughout: 44pt touch targets, full VoiceOver support, Dynamic Type, dark mode, and severity indicators that don't rely on color alone (each severity has a unique icon shape).

---

## 7. Key Insights

### Insight 1: The $848M accessibility testing market has a mobile-native blind spot
The market is projected to reach $1.76B by 2035, yet there is no iOS-native audit app for non-developers. Android has Google's Accessibility Scanner; iOS has nothing.

### Insight 2: 70% of accessibility issues require human judgment
Automated tools can flag contrast failures and missing alt text, but they can't evaluate whether alt text is meaningful, whether focus order is logical, or whether a gesture has a reasonable single-pointer alternative. Designers are the right humans for this judgment.

### Insight 3: Screenshot-based auditing unlocks universal coverage
Because ARIA works from screenshots rather than the accessibility API, it can audit ANY app — competitor apps, TestFlight builds, App Store apps, even Android screenshots. This is a capability no developer tool offers.

### Insight 4: The handoff gap is widening
Level Access found that only 28% of organizations address accessibility during design (down from 32% in 2024). The gap between design intent and built product is growing, making post-build verification tools more critical.

### Insight 5: Designers want to do the right thing but lack the right tools
Community research consistently shows designers care about accessibility but feel powerless without developer tools. ARIA gives them agency — the ability to audit, document, and advocate for accessibility fixes using evidence.

---

## 8. Implementation Insights (Post-Build)

### Interaction Patterns Discovered During Development

**Pin placement on screenshots**: Using `GeometryReader` to track tap positions as normalized percentages (0.0–1.0) of image dimensions ensures markers stay correctly positioned regardless of screen size, orientation, or zoom level. This was the right call — absolute pixel positions would break on different devices.

**Pinch-to-zoom with markers**: Markers are children of the same `ZStack` as the screenshot, so they scale and pan together naturally. The zoom gesture uses `MagnifyGesture` with the total zoom clamped between 1.0x and 5.0x to prevent losing context.

**PhotosPicker for screenshot import**: Using `PhotosUI`'s `PhotosPicker` with `.screenshots` filter provides a clean, native import flow. Images are compressed to JPEG at 70% quality before storage in SwiftData to keep the database manageable.

**PDF generation**: `UIGraphicsPDFRenderer` produces clean, professional PDFs with proper pagination. The report uses system fonts so it renders correctly on any device. Each finding is prefixed with a severity-colored dot and WCAG criterion code for quick scanning.

### Architecture Decisions

- **SwiftData over Core Data**: SwiftData's `@Model` macro and `@Query` property wrapper dramatically reduce boilerplate. Cascade delete rules handle cleanup automatically.
- **No separate ViewModels for simple views**: For views where `@Query` and `@Bindable` handle all state, adding a ViewModel layer would be unnecessary indirection. ViewModels were skipped in favor of keeping logic close to where it's used.
- **Severity as a single source of truth**: `Severity.color` and `Severity.iconName` computed properties eliminated 4 duplicated switch statements across the codebase.
- **WCAG database as a static struct**: With ~30 criteria, a compiled-in database is faster and simpler than a Core Data/JSON approach. The `search()` function checks ID, name, and description fields.

### What I'd Do Differently

1. **Add a contrast checker tool** — let users pick two colors from a screenshot and calculate the ratio in-app
2. **Support re-audit comparison** — show which findings were fixed between audit v1 and v2
3. **Add team collaboration** — share audits via CloudKit rather than just exporting PDFs
4. **VoiceOver recording integration** — capture what VoiceOver reads alongside the screenshot
5. **Template-based audits** — pre-fill common violation patterns for specific app types (e-commerce, social, etc.)

---

*Research conducted June–July 2026. Sources: W3C WCAG 2.2, Deque/axe DevTools documentation, Stark blog and G2 reviews, NNGroup accessibility research, Level Access State of Digital Accessibility Report 2025–2026, Sparkbox tool reviews, WebAIM Million report, A11Y Collective mobile guides.*
