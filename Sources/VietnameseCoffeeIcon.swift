import SwiftUI
import AppKit

struct VietnameseCoffeeIcon: View {
    let isActive: Bool
    var isMonochrome: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            
            // Draw spoon/straw sticking out (diagonal line)
            var spoonPath = Path()
            spoonPath.move(to: CGPoint(x: w * 0.45, y: h * 0.52))
            spoonPath.addLine(to: CGPoint(x: w * 0.72, y: h * 0.12))
            
            // Draw glass outline (sleek tapering glass shape matching vector illustration)
            var glassPath = Path()
            glassPath.move(to: CGPoint(x: w * 0.26, y: h * 0.22)) // top left
            glassPath.addLine(to: CGPoint(x: w * 0.35, y: h * 0.85)) // bottom left
            glassPath.addLine(to: CGPoint(x: w * 0.65, y: h * 0.85)) // bottom right
            glassPath.addLine(to: CGPoint(x: w * 0.74, y: h * 0.22)) // top right
            glassPath.closeSubpath()
            
            // If active, fill the layers using original colors or monochrome primary
            if isActive {
                // Milk layer (bottom ~25% of the glass)
                var milkPath = Path()
                milkPath.move(to: CGPoint(x: w * 0.33, y: h * 0.7))
                milkPath.addLine(to: CGPoint(x: w * 0.35, y: h * 0.85))
                milkPath.addLine(to: CGPoint(x: w * 0.65, y: h * 0.85))
                milkPath.addLine(to: CGPoint(x: w * 0.67, y: h * 0.7))
                milkPath.closeSubpath()
                
                // Coffee layer (middle ~40% of the glass)
                var coffeePath = Path()
                coffeePath.move(to: CGPoint(x: w * 0.29, y: h * 0.45))
                coffeePath.addLine(to: CGPoint(x: w * 0.33, y: h * 0.7))
                coffeePath.addLine(to: CGPoint(x: w * 0.67, y: h * 0.7))
                coffeePath.addLine(to: CGPoint(x: w * 0.71, y: h * 0.45))
                coffeePath.closeSubpath()
                
                // Foam layer (top ~25% of the glass)
                var foamPath = Path()
                foamPath.move(to: CGPoint(x: w * 0.26, y: h * 0.22))
                foamPath.addLine(to: CGPoint(x: w * 0.29, y: h * 0.45))
                foamPath.addLine(to: CGPoint(x: w * 0.71, y: h * 0.45))
                foamPath.addLine(to: CGPoint(x: w * 0.74, y: h * 0.22))
                foamPath.closeSubpath()
                
                if isMonochrome {
                    context.fill(milkPath, with: .color(.primary.opacity(0.85)))
                    context.fill(coffeePath, with: .color(.primary))
                    context.fill(foamPath, with: .color(.primary.opacity(0.4)))
                    
                    context.stroke(
                        spoonPath,
                        with: .color(.primary),
                        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                    )
                    
                    context.stroke(
                        glassPath,
                        with: .color(.primary),
                        style: StrokeStyle(lineWidth: 1.5, lineJoin: .round)
                    )
                } else {
                    // Original colors extracted from nauda.png
                    let milkColor = Color(red: 234.0/255.0, green: 227.0/255.0, blue: 199.0/255.0)
                    let coffeeColor = Color(red: 35.0/255.0, green: 16.0/255.0, blue: 9.0/255.0)
                    let foamColor = Color(red: 237.0/255.0, green: 192.0/255.0, blue: 109.0/255.0)
                    let spoonColor = Color(red: 172.0/255.0, green: 104.0/255.0, blue: 33.0/255.0)
                    let glassColor = colorScheme == .dark ? Color(red: 234.0/255.0, green: 227.0/255.0, blue: 199.0/255.0).opacity(0.8) : Color(red: 35.0/255.0, green: 16.0/255.0, blue: 9.0/255.0)
                    
                    context.fill(milkPath, with: .color(milkColor))
                    context.fill(coffeePath, with: .color(coffeeColor))
                    context.fill(foamPath, with: .color(foamColor))
                    
                    // Draw spoon on top of the liquid fills so it remains visible
                    context.stroke(
                        spoonPath,
                        with: .color(spoonColor),
                        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                    )
                    
                    // Draw the glass outline on top of everything
                    context.stroke(
                        glassPath,
                        with: .color(glassColor),
                        style: StrokeStyle(lineWidth: 1.5, lineJoin: .round)
                    )
                }
            } else {
                // Inactive state
                let spoonColor = isMonochrome ? .primary : (colorScheme == .dark ? Color.primary : Color(red: 172.0/255.0, green: 104.0/255.0, blue: 33.0/255.0))
                let glassColor = isMonochrome ? .primary : (colorScheme == .dark ? Color.primary : Color(red: 35.0/255.0, green: 16.0/255.0, blue: 9.0/255.0))
                
                context.stroke(
                    spoonPath,
                    with: .color(spoonColor),
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                )
                
                context.stroke(
                    glassPath,
                    with: .color(glassColor),
                    style: StrokeStyle(lineWidth: 1.5, lineJoin: .round)
                )
            }
        }
    }
}

extension View {
    // Utility to compile any SwiftUI View into a template-rendered AppKit NSImage
    func toNSImage(size: NSSize) -> NSImage? {
        let hostingView = NSHostingView(rootView: self.frame(width: size.width, height: size.height))
        hostingView.frame = NSRect(origin: .zero, size: size)
        
        // Force layout pass
        hostingView.layoutSubtreeIfNeeded()
        
        // Cache display into standard AppKit bitmap representation
        guard let bitmapRep = hostingView.bitmapImageRepForCachingDisplay(in: hostingView.bounds) else {
            return nil
        }
        
        hostingView.cacheDisplay(in: hostingView.bounds, to: bitmapRep)
        
        // Package as a template image that automatically tints (black/white) matching system menu bar
        let image = NSImage(size: size)
        image.addRepresentation(bitmapRep)
        image.isTemplate = true
        return image
    }
}
