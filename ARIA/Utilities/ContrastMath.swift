import UIKit

/// WCAG contrast math (WCAG 2.1 §1.4.3 / 1.4.11) plus pixel sampling from a screenshot.
enum ContrastMath {

    /// Relative luminance of a color, per the WCAG definition.
    static func relativeLuminance(_ color: UIColor) -> Double {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        func channel(_ c: CGFloat) -> Double {
            let cs = Double(c)
            return cs <= 0.03928 ? cs / 12.92 : pow((cs + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)
    }

    /// Contrast ratio between two colors (1.0 … 21.0).
    static func ratio(_ c1: UIColor, _ c2: UIColor) -> Double {
        let l1 = relativeLuminance(c1)
        let l2 = relativeLuminance(c2)
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// A single WCAG pass/fail check.
    struct Check: Identifiable {
        let id = UUID()
        let label: String
        let threshold: Double
        let passes: Bool
    }

    /// The standard set of checks for a given ratio.
    static func checks(for ratio: Double) -> [Check] {
        [
            Check(label: "AA · Normal text", threshold: 4.5, passes: ratio >= 4.5),
            Check(label: "AA · Large text", threshold: 3.0, passes: ratio >= 3.0),
            Check(label: "AAA · Normal text", threshold: 7.0, passes: ratio >= 7.0),
            Check(label: "AAA · Large text", threshold: 4.5, passes: ratio >= 4.5),
            Check(label: "UI components & graphics", threshold: 3.0, passes: ratio >= 3.0),
        ]
    }
}

extension UIImage {
    /// Average color in a small square region around a normalized (0–1) point.
    /// Averaging a few pixels avoids noise from anti-aliasing on a single pixel.
    func averageColor(atNormalized point: CGPoint, sampleRadius: Int = 3) -> UIColor? {
        guard let cg = cgImage, cg.width > 0, cg.height > 0 else { return nil }
        let w = cg.width, h = cg.height
        let cx = min(max(Int(point.x * CGFloat(w)), 0), w - 1)
        let cy = min(max(Int(point.y * CGFloat(h)), 0), h - 1)
        let x0 = max(cx - sampleRadius, 0)
        let y0 = max(cy - sampleRadius, 0)
        let x1 = min(cx + sampleRadius, w - 1)
        let y1 = min(cy + sampleRadius, h - 1)
        let rw = x1 - x0 + 1
        let rh = y1 - y0 + 1
        guard rw > 0, rh > 0,
              let cropped = cg.cropping(to: CGRect(x: x0, y: y0, width: rw, height: rh)) else { return nil }

        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * rw
        var data = [UInt8](repeating: 0, count: bytesPerRow * rh)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: &data, width: rw, height: rh, bitsPerComponent: 8,
            bytesPerRow: bytesPerRow, space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        ctx.draw(cropped, in: CGRect(x: 0, y: 0, width: rw, height: rh))

        var rSum = 0.0, gSum = 0.0, bSum = 0.0
        let count = Double(rw * rh)
        for i in stride(from: 0, to: data.count, by: bytesPerPixel) {
            rSum += Double(data[i])
            gSum += Double(data[i + 1])
            bSum += Double(data[i + 2])
        }
        return UIColor(
            red: rSum / count / 255.0,
            green: gSum / count / 255.0,
            blue: bSum / count / 255.0,
            alpha: 1.0
        )
    }
}
