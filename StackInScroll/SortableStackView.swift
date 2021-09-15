//
//  SortableStackView.swift
//  StackInScroll
//
//  Created by Takuto Nakamura on 2021/09/16.
//

import Cocoa

class SortableStackView: NSStackView {
    
    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        views.forEach { view in
            if let thumbnail = (view as? ThumbnailView) {
                thumbnail.selected = (view.hitTest(location) != nil)
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        if let dragged = views.first(where: { (view) -> Bool in
            return view.hitTest(location) != nil
        }) {
            reorder(view: dragged, event: event)
        }
    }
    
    private func update(stack: NSStackView, views: [NSView]) {
        stack.views.forEach { (view) in
            view.removeFromSuperview()
        }
        views.forEach { (view) in
            stack.addView(view, in: .bottom)
            view.leadingAnchor.constraint(equalTo: stack.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: stack.trailingAnchor).isActive = true
        }
    }
    
    private func getReordered(view: NSView, dragged: CachedViewLayer) -> [NSView] {
        return self.views.map({ (view0) -> (view: NSView, position: NSPoint) in
            if view0 !== view {
                return (view0, NSPoint(x: view0.frame.midX, y: view0.frame.midY))
            } else {
                return (view0, NSPoint(x: dragged.frame.midX, y: dragged.frame.midY))
            }
        }).sorted(by: { (a, b) -> Bool in
            return a.position.y > b.position.y
        }).map({ (info) -> NSView in
            return info.view
        })
    }
    
    private func reorder(view: NSView, event: NSEvent) {
        guard let layer = self.layer,
              let cached = try? cacheViews() else { return }
        
        let container = CALayer()
        container.frame = layer.bounds
        container.zPosition = 1
        if let filter = CIFilter(name: "CISourceOutCompositing") {
            let ciimage = CIImage(color: CIColor.blue).cropped(to: layer.bounds)
            filter.setValue(ciimage, forKey: kCIInputBackgroundImageKey)
            container.backgroundFilters = [filter]
        }
        cached.filter({ $0.view !== view })
            .forEach { container.addSublayer($0) }
        
        layer.addSublayer(container)
        defer { container.removeFromSuperlayer() }
        
        let dragged = cached.first(where: { $0.view === view })!
        dragged.zPosition = 2
        layer.addSublayer(dragged)
        defer { dragged.removeFromSuperlayer() }
        
        let d0: CGPoint = view.frame.origin
        let p0: CGPoint = convert(event.locationInWindow, from: nil)
        
        self.window?.trackEvents(
            matching: [.leftMouseDragged, .leftMouseUp],
            timeout: 1000000, mode: RunLoop.Mode.eventTracking
        ) { event, stop in
            guard let e = event, e.type == .leftMouseDragged else {
                view.mouseUp(with: event!)
                stop.pointee = true
                return
            }
            let p1: CGPoint = self.convert(e.locationInWindow, from: nil)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            dragged.frame.origin.x = d0.x
            dragged.frame.origin.y = d0.y + (p1.y - p0.y)
            CATransaction.commit()
            
            let reordered = getReordered(view: view, dragged: dragged)
            let nextIndex = reordered.firstIndex(of: view)!
            let prevIndex = self.views.firstIndex(of: view)!
            
            if nextIndex != prevIndex {
                self.update(stack: self, views: reordered)
                self.layoutSubtreeIfNeeded()
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.15)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
                cached.forEach { layer in
                    layer.position = NSPoint(x: layer.view.frame.midX, y: layer.view.frame.midY)
                }
                CATransaction.commit()
            }
        }
    }
    
    private func cacheViews() throws -> [CachedViewLayer] {
        return try views.map { (view) throws -> CachedViewLayer in
            return try CachedViewLayer(view: view)
        }
    }
    
}

fileprivate class CachedViewLayer: CALayer {
    
    enum CacheError: Error {
        case bitmapCreationFailed
    }
    
    let view: NSView!
    
    override init(layer: Any) {
        self.view = (layer as! CachedViewLayer).view
        super.init(layer: layer)
    }
    
    init(view: NSView) throws {
        self.view = view
        super.init()
        guard let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
            throw CacheError.bitmapCreationFailed
        }
        view.cacheDisplay(in: view.bounds, to: bitmap)
        self.frame = view.frame
        self.contents = bitmap.cgImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
