import AppKit

func drawIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else { return image }

    // Background: Claude orange gradient
    let bgPath = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: s, height: s),
                               xRadius: s * 0.22, yRadius: s * 0.22)
    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.72, green: 0.33, blue: 0.18, alpha: 1),
        NSColor(calibratedRed: 0.93, green: 0.53, blue: 0.28, alpha: 1)
    ], atLocations: [0, 1], colorSpace: .genericRGB)!
    gradient.draw(in: bgPath, angle: -60)

    // Three right-aligned text lines (representing RTL alignment)
    let lineColor = NSColor(white: 1.0, alpha: 0.95)
    let lineH = s * 0.065
    let gap   = s * 0.055
    let right = s * 0.80
    let y1    = s * 0.58
    let widths: [CGFloat] = [s * 0.52, s * 0.38, s * 0.28]

    for (i, w) in widths.enumerated() {
        let y = y1 - CGFloat(i) * (lineH + gap)
        let rect = NSRect(x: right - w, y: y, width: w, height: lineH)
        let path = NSBezierPath(roundedRect: rect, xRadius: lineH / 2, yRadius: lineH / 2)
        lineColor.setFill()
        path.fill()
    }

    // Hebrew alef א — top center, white
    let fontSize = s * 0.36
    let font = NSFont(name: "Arial Hebrew", size: fontSize)
               ?? NSFont.systemFont(ofSize: fontSize, weight: .medium)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(white: 1.0, alpha: 0.92)
    ]
    let letter = NSAttributedString(string: "ע", attributes: attrs)
    let letterSize = letter.size()
    let letterX = (s - letterSize.width)  / 2 - s * 0.02
    let letterY = s * 0.60
    letter.draw(at: NSPoint(x: letterX, y: letterY))

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to path: String) {
    guard let tiff = image.tiffRepresentation,
          let rep  = NSBitmapImageRep(data: tiff),
          let png  = rep.representation(using: .png, properties: [:]) else {
        print("Failed: \(path)"); return
    }
    do { try png.write(to: URL(fileURLWithPath: path)) }
    catch { print("Error writing \(path): \(error)") }
}

let iconset = "AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: iconset,
                                          withIntermediateDirectories: true)

let sizes: [(String, Int)] = [
    ("icon_16x16.png",       16),
    ("icon_16x16@2x.png",    32),
    ("icon_32x32.png",       32),
    ("icon_32x32@2x.png",    64),
    ("icon_128x128.png",    128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png",    256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png",    512),
    ("icon_512x512@2x.png",1024),
]

for (name, size) in sizes {
    let img = drawIcon(size: size)
    savePNG(img, to: "\(iconset)/\(name)")
    print("  \(name)")
}
print("Done.")
