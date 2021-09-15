//
//  ViewController.swift
//  StackInScroll
//
//  Created by Takuto Nakamura on 2021/09/15.
//

import Cocoa

typealias File = (image: NSImage, label: String)

class ViewController: NSViewController {

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var stackView: NSStackView!
    
    var files = [File]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.yellow.cgColor

        stackView.wantsLayer = true
        stackView.layer?.backgroundColor = NSColor.green.cgColor
        
        for i in (0 ..< 4) {
            let image = NSImage(imageLiteralResourceName: "Image-\(i + 1)")
            let label = UUID().uuidString + ".png"
            files.append((image, label))
        }
        updateStackView()
    }
    
    func updateStackView() {
        stackView.views.forEach { view in
            view.removeFromSuperview()
        }
        files.forEach { (image, label) in
            guard let thumbnailView = makeThumbnailView() else { return }
            thumbnailView.imageView.image = image
            thumbnailView.aspect = image.aspect
            thumbnailView.label.stringValue = label
            stackView.addView(thumbnailView, in: .bottom)
            thumbnailView.widthAnchor.constraint(equalTo: self.stackView.widthAnchor).isActive = true
        }
    }

    func makeThumbnailView() -> ThumbnailView? {
        let nib = NSNib(nibNamed: "ThumbnailView", bundle: Bundle.main)!
        var topLevelArray: NSArray? = nil
        guard nib.instantiate(withOwner: nil, topLevelObjects: &topLevelArray),
              let results = topLevelArray as? [Any],
              let item = results.last(where: { $0 is ThumbnailView }),
              let view = item as? ThumbnailView
        else { return nil }
        return view
    }

}

