//
//  ThumbnailView.swift
//  StackInScroll
//
//  Created by Takuto Nakamura on 2021/09/15.
//

import Cocoa

class ThumbnailView: NSView {

    @IBOutlet weak var selectedAreaView: NSView!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var label: NSTextField!
    
    var selected: Bool = false {
        didSet {
            let color = selected ? NSColor.systemGray.withAlphaComponent(0.3).cgColor : nil
            selectedAreaView.layer?.backgroundColor = color
            label.drawsBackground = selected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedAreaView.wantsLayer = true
        selectedAreaView.layer?.cornerRadius = 4
        
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.imageAlignment = .alignCenter
        
        label.drawsBackground = false
        label.backgroundColor = NSColor.controlAccentColor.usingColorSpace(.deviceRGB)
        label.wantsLayer = true
        label.layer?.cornerRadius = 4
    }
    
    private var aspectLayoutConstraint: NSLayoutConstraint? {
        didSet {
            if let oldLayoutConstraint = oldValue {
                self.imageView.removeConstraint(oldLayoutConstraint)
            }
            if let newLayoutConstraint = self.aspectLayoutConstraint {
                newLayoutConstraint.priority = NSLayoutConstraint.Priority(900)
                self.imageView.addConstraint(newLayoutConstraint)
            }
        }
    }

    var aspect: CGFloat? {
        didSet {
            if let aspect = self.aspect {
                self.aspectLayoutConstraint = NSLayoutConstraint(
                    item: self.imageView!,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: self.imageView,
                    attribute: .height,
                    multiplier: aspect,
                    constant: 0
                )
            } else {
                self.aspectLayoutConstraint = nil
            }
        }
    }
    
}

extension NSImage {
    var aspect: CGFloat {
        let size = self.alignmentRect.size
        return size.width / size.height
    }
}
