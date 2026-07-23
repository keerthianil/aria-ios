import UIKit
import PDFKit
import AVFoundation

struct PDFReportService {

    static func generateReport(for audit: Audit) -> Data {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let contentWidth = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = renderer.pdfData { context in
            var yPosition: CGFloat = 0

            func startNewPage() {
                context.beginPage()
                yPosition = margin
            }

            func ensureSpace(_ needed: CGFloat) {
                if yPosition + needed > pageHeight - margin {
                    startNewPage()
                }
            }

            func drawText(_ text: String, font: UIFont, color: UIColor = .label, maxWidth: CGFloat = contentWidth) -> CGFloat {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 2
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraphStyle
                ]
                let boundingRect = (text as NSString).boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                                                                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                                    attributes: attrs, context: nil)
                (text as NSString).draw(in: CGRect(x: margin, y: yPosition, width: maxWidth, height: boundingRect.height), withAttributes: attrs)
                let height = ceil(boundingRect.height)
                yPosition += height
                return height
            }

            func drawDivider() {
                ensureSpace(20)
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: yPosition + 8))
                path.addLine(to: CGPoint(x: pageWidth - margin, y: yPosition + 8))
                UIColor.separator.setStroke()
                path.lineWidth = 0.5
                path.stroke()
                yPosition += 16
            }

            func drawSeverityDot(color: UIColor, x: CGFloat, y: CGFloat) {
                let dotRect = CGRect(x: x, y: y + 3, width: 8, height: 8)
                let path = UIBezierPath(ovalIn: dotRect)
                color.setFill()
                path.fill()
            }

            let brandColor = UIColor(named: "BrandPrimary") ?? .systemBlue

            /// Draws the screen's screenshot at a bounded size with numbered severity pins overlaid,
            /// so the report shows *where* each finding is — not just a text list.
            func drawAnnotatedScreenshot(_ screen: AuditScreen) {
                guard let image = screen.screenshotImage else { return }
                let maxThumbWidth: CGFloat = 180
                let maxThumbHeight: CGFloat = 320
                let box = CGRect(x: margin, y: yPosition,
                                 width: maxThumbWidth, height: maxThumbHeight)
                let fitted = AVMakeRect(aspectRatio: image.size, insideRect: box)
                ensureSpace(fitted.height + 12)
                let drawRect = CGRect(x: margin, y: yPosition, width: fitted.width, height: fitted.height)
                image.draw(in: drawRect)

                for (index, finding) in screen.sortedFindings.enumerated() {
                    let cx = drawRect.minX + CGFloat(finding.pinX) * drawRect.width
                    let cy = drawRect.minY + CGFloat(finding.pinY) * drawRect.height
                    let r: CGFloat = 9
                    let circle = UIBezierPath(ovalIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
                    finding.severity.uiColor.setFill()
                    UIColor.white.setStroke()
                    circle.lineWidth = 1.5
                    circle.fill()
                    circle.stroke()
                    let num = "\(index + 1)"
                    let numAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 10, weight: .bold),
                        .foregroundColor: UIColor.white
                    ]
                    let size = (num as NSString).size(withAttributes: numAttrs)
                    (num as NSString).draw(at: CGPoint(x: cx - size.width / 2, y: cy - size.height / 2),
                                           withAttributes: numAttrs)
                }
                yPosition += drawRect.height + 12
            }

            // MARK: - Cover Page
            startNewPage()
            yPosition = pageHeight * 0.3

            // Brand mark
            let markRect = CGRect(x: margin, y: yPosition - 56, width: 40, height: 40)
            let markPath = UIBezierPath(roundedRect: markRect, cornerRadius: 10)
            brandColor.setFill()
            markPath.fill()
            let markLetter = "A"
            let markAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let markSize = (markLetter as NSString).size(withAttributes: markAttrs)
            (markLetter as NSString).draw(
                at: CGPoint(x: markRect.midX - markSize.width / 2, y: markRect.midY - markSize.height / 2),
                withAttributes: markAttrs)

            _ = drawText("Accessibility", font: .systemFont(ofSize: 32, weight: .bold), color: .label)
            yPosition += 2
            _ = drawText("Audit Report", font: .systemFont(ofSize: 32, weight: .bold), color: .label)
            yPosition += 24

            drawDivider()
            yPosition += 8

            _ = drawText(audit.appName, font: .systemFont(ofSize: 20, weight: .medium), color: .secondaryLabel)
            yPosition += 4
            _ = drawText(audit.name, font: .systemFont(ofSize: 14), color: .secondaryLabel)
            yPosition += 16

            if !audit.auditorName.isEmpty {
                _ = drawText("Auditor: \(audit.auditorName)", font: .systemFont(ofSize: 12), color: .tertiaryLabel)
                yPosition += 4
            }
            _ = drawText("Platform: \(audit.platform.displayName)", font: .systemFont(ofSize: 12), color: .tertiaryLabel)
            yPosition += 4

            let formatter = DateFormatter()
            formatter.dateStyle = .long
            _ = drawText("Date: \(formatter.string(from: audit.createdDate))", font: .systemFont(ofSize: 12), color: .tertiaryLabel)
            yPosition += 4
            _ = drawText("Generated by ARIA", font: .systemFont(ofSize: 10), color: .quaternaryLabel)

            // MARK: - Summary Page
            startNewPage()
            _ = drawText("Executive Summary", font: .systemFont(ofSize: 22, weight: .bold))
            yPosition += 16

            _ = drawText("Total findings: \(audit.totalFindings)", font: .systemFont(ofSize: 14, weight: .medium))
            yPosition += 4
            _ = drawText("Screens audited: \(audit.screens.count)", font: .systemFont(ofSize: 14, weight: .medium))
            yPosition += 16

            // Colors come straight from the Severity enum's shared token — no duplicated RGB here.
            let severities: [(String, Int, UIColor)] = Severity.allCases.map {
                ($0.displayName, audit.findingsCount(for: $0), $0.uiColor)
            }

            _ = drawText("Resolved: \(audit.resolvedCount) of \(audit.totalFindings)",
                         font: .systemFont(ofSize: 14, weight: .medium), color: .secondaryLabel)
            yPosition += 16

            for (label, count, color) in severities {
                ensureSpace(24)
                drawSeverityDot(color: color, x: margin, y: yPosition)
                let saved = yPosition
                let xOffset: CGFloat = margin + 16
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 13, weight: .medium),
                    .foregroundColor: UIColor.label
                ]
                let text = "\(count) \(label)"
                (text as NSString).draw(at: CGPoint(x: xOffset, y: saved), withAttributes: attrs)
                yPosition = saved + 20
            }

            drawDivider()

            // MARK: - Findings by Screen
            for screen in audit.sortedScreens {
                ensureSpace(60)
                _ = drawText(screen.name, font: .systemFont(ofSize: 18, weight: .semibold))
                yPosition += 4
                _ = drawText("\(screen.findings.count) finding\(screen.findings.count == 1 ? "" : "s")",
                             font: .systemFont(ofSize: 11), color: .secondaryLabel)
                yPosition += 12

                drawAnnotatedScreenshot(screen)

                for finding in screen.sortedFindings {
                    ensureSpace(80)

                    let severityColor = finding.severity.uiColor

                    drawSeverityDot(color: severityColor, x: margin, y: yPosition)

                    let headerX = margin + 16
                    var headerText = finding.severity.displayName
                    if !finding.wcagCriterionID.isEmpty {
                        headerText += "  ·  \(finding.wcagCriterionID)"
                        if let criterion = WCAGDatabase.criterion(for: finding.wcagCriterionID) {
                            headerText += " \(criterion.name)"
                        }
                    }
                    if finding.isFixed {
                        headerText += "  ✓ Fixed"
                    }

                    let headerAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
                        .foregroundColor: severityColor
                    ]
                    (headerText as NSString).draw(at: CGPoint(x: headerX, y: yPosition), withAttributes: headerAttrs)
                    yPosition += 18

                    if !finding.findingDescription.isEmpty {
                        let savedX = margin + 16
                        let descWidth = contentWidth - 16
                        let descAttrs: [NSAttributedString.Key: Any] = [
                            .font: UIFont.systemFont(ofSize: 11),
                            .foregroundColor: UIColor.label
                        ]
                        let descRect = (finding.findingDescription as NSString).boundingRect(
                            with: CGSize(width: descWidth, height: .greatestFiniteMagnitude),
                            options: [.usesLineFragmentOrigin],
                            attributes: descAttrs, context: nil)
                        (finding.findingDescription as NSString).draw(
                            in: CGRect(x: savedX, y: yPosition, width: descWidth, height: ceil(descRect.height)),
                            withAttributes: descAttrs)
                        yPosition += ceil(descRect.height) + 4
                    }

                    if !finding.recommendation.isEmpty {
                        let recX = margin + 16
                        let recWidth = contentWidth - 16
                        let recAttrs: [NSAttributedString.Key: Any] = [
                            .font: UIFont.italicSystemFont(ofSize: 10),
                            .foregroundColor: UIColor.secondaryLabel
                        ]
                        let prefix = "Recommendation: "
                        let fullRec = prefix + finding.recommendation
                        let recRect = (fullRec as NSString).boundingRect(
                            with: CGSize(width: recWidth, height: .greatestFiniteMagnitude),
                            options: [.usesLineFragmentOrigin],
                            attributes: recAttrs, context: nil)
                        (fullRec as NSString).draw(
                            in: CGRect(x: recX, y: yPosition, width: recWidth, height: ceil(recRect.height)),
                            withAttributes: recAttrs)
                        yPosition += ceil(recRect.height) + 4
                    }

                    yPosition += 12
                }

                drawDivider()
            }

            // MARK: - Footer on last page
            ensureSpace(40)
            yPosition = pageHeight - margin - 20
            _ = drawText("Generated by ARIA · Mobile Accessibility Audit Tool",
                         font: .systemFont(ofSize: 9), color: .tertiaryLabel)
        }

        return data
    }
}
