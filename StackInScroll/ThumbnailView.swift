//
//  ThumbnailView.swift
//  StackInScroll
//
//  Created by Takuto Nakamura on 2021/09/15.
//

import Cocoa

class ThumbnailView: NSView {

    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var label: NSTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.imageAlignment = .alignCenter
        imageView.wantsLayer = true
        imageView.layer?.backgroundColor = NSColor.blue.cgColor
        
        label.drawsBackground = true
        label.backgroundColor = NSColor.magenta
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.lightGray.cgColor
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
