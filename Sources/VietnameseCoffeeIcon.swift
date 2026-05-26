import SwiftUI
import AppKit

struct VietnameseCoffeeIcon: View {
    let isActive: Bool
    
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            
            // Draw spoon/straw sticking out (diagonal line)
            var spoonPath = Path()
            spoonPath.move(to: CGPoint(x: w * 0.45, y: h * 0.52))
            spoonPath.addLine(to: CGPoint(x: w * 0.72, y: h * 0.12))
            
            context.stroke(
                spoonPath,
                with: .color(.primary),
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
            )
            
            // Draw glass outline (sleek tapering glass shape matching vector illustration)
            var glassPath = Path()
            glassPath.move(to: CGPoint(x: w * 0.26, y: h * 0.22)) // top left
            glassPath.addLine(to: CGPoint(x: w * 0.35, y: h * 0.85)) // bottom left
            glassPath.addLine(to: CGPoint(x: w * 0.65, y: h * 0.85)) // bottom right
            glassPath.addLine(to: CGPoint(x: w * 0.74, y: h * 0.22)) // top right
            glassPath.closeSubpath()
            
            // If active, fill the layers using opacity to tint the template image
            if isActive {
                // Milk layer (bottom ~25% of the glass)
                var milkPath = Path()
                milkPath.move(to: CGPoint(x: w * 0.33, y: h * 0.7))
                milkPath.addLine(to: CGPoint(x: w * 0.35, y: h * 0.85))
                milkPath.addLine(to: CGPoint(x: w * 0.65, y: h * 0.85))
                milkPath.addLine(to: CGPoint(x: w * 0.67, y: h * 0.7))
                milkPath.closeSubpath()
                context.fill(milkPath, with: .color(.primary.opacity(0.85)))
                
                // Coffee layer (middle ~40% of the glass)
                var coffeePath = Path()
                coffeePath.move(to: CGPoint(x: w * 0.29, y: h * 0.45))
                coffeePath.addLine(to: CGPoint(x: w * 0.33, y: h * 0.7))
                coffeePath.addLine(to: CGPoint(x: w * 0.67, y: h * 0.7))
                coffeePath.addLine(to: CGPoint(x: w * 0.71, y: h * 0.45))
                coffeePath.closeSubpath()
                context.fill(coffeePath, with: .color(.primary))
                
                // Foam layer (top ~25% of the glass)
                var foamPath = Path()
                foamPath.move(to: CGPoint(x: w * 0.26, y: h * 0.22))
                foamPath.addLine(to: CGPoint(x: w * 0.29, y: h * 0.45))
                foamPath.addLine(to: CGPoint(x: w * 0.71, y: h * 0.45))
                foamPath.addLine(to: CGPoint(x: w * 0.74, y: h * 0.22))
                foamPath.closeSubpath()
                context.fill(foamPath, with: .color(.primary.opacity(0.4)))
            }
            
            // Stroke the glass outline
            context.stroke(
                glassPath,
                with: .color(.primary),
                style: StrokeStyle(lineWidth: 1.5, lineJoin: .round)
            )
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
