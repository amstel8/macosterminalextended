import AppKit
let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 128, pixelsHigh: 128, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
NSColor(calibratedWhite: 0.15, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 6, y: 6, width: 116, height: 116), xRadius: 24, yRadius: 24).fill()
NSColor(calibratedWhite: 0.9, alpha: 1).setStroke()
let path = NSBezierPath()
path.lineWidth = 9
path.lineCapStyle = .round
path.move(to: NSPoint(x: 32, y: 87))
path.line(to: NSPoint(x: 55, y: 65))
path.line(to: NSPoint(x: 32, y: 43))
path.move(to: NSPoint(x: 68, y: 42))
path.line(to: NSPoint(x: 94, y: 42))
path.stroke()
NSGraphicsContext.restoreGraphicsState()
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
