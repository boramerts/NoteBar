import SwiftUI
import AppKit

struct RichTextEditor: NSViewRepresentable {
    @Binding var text: String
    @Binding var isList: Bool
    @Binding var isBold: Bool
    @Binding var isItalic: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        // Configure scrollView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.backgroundColor = NSColor.clear
        scrollView.scrollerStyle = .overlay
        scrollView.drawsBackground = false
        
        
        // Configure textView
        textView.maxSize = NSSize(width: CGFloat.infinity, height: CGFloat.infinity)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.containerSize = NSSize(width: scrollView.contentSize.width, height: CGFloat.infinity)
        textView.textContainer?.widthTracksTextView = true
        textView.backgroundColor = NSColor.clear // Making the background transparent
        textView.delegate = context.coordinator
        textView.isRichText = true
        textView.allowsUndo = true
        textView.textColor = .white
        textView.font = NSFont.systemFont(ofSize: 14)
        
        // Embed the textView in the scrollView
        scrollView.documentView = textView
        
        return scrollView // Return the scrollView containing the textView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        DispatchQueue.main.async {
            if self.isBold {
                context.coordinator.setBold(textView: textView)
            } else {
                context.coordinator.removeBold(textView: textView)
            }
            
            if self.isItalic {
                context.coordinator.setItalic(textView: textView)
            } else {
                context.coordinator.removeItalic(textView: textView)
            }
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor
        var isBold = false
        var isItalic = false
        
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            self.parent.text = textView.string
        }
        
        func applyFontTraits(style: NSFontTraitMask, to textView: NSTextView) {
            guard let textStorage = textView.textStorage, textStorage.length > 0 else { return }
            
            let fontManager = NSFontManager.shared
            let selectedRange = textView.selectedRange()
            
            textView.undoManager?.beginUndoGrouping()
            
            // Apply or remove style based on current trait
            textStorage.enumerateAttribute(.font, in: selectedRange, options: []) { (value, range, stop) in
                if let font = value as? NSFont {
                    var newFont = font
                    newFont = fontManager.convert(font, toHaveTrait: style)
                    textStorage.addAttribute(.font, value: newFont, range: range)
                }
            }
            
            textView.undoManager?.setActionName(style == .boldFontMask ? "Toggle Bold" : "Toggle Italic")
            textView.undoManager?.endUndoGrouping()
        }
        
        func setBold(textView: NSTextView) {
            print("Bold enabled")
            applyFontTraits(style: .boldFontMask, to: textView)
        }
        
        func removeBold(textView: NSTextView) {
            print("Bold disabled")
            applyFontTraits(style: .unboldFontMask, to: textView)
        }
        
        func setItalic(textView: NSTextView) {
            print("Italic enabled")
            applyFontTraits(style: .italicFontMask, to: textView)
        }
        
        func removeItalic(textView: NSTextView) {
            print("Italic disabled")
            applyFontTraits(style: .unitalicFontMask, to: textView)
        }
        
        //TODO: Figure out how to add bullet point when button is pressed!
        func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            guard let replacementString = replacementString else { return true }
            
            if parent.isList && replacementString == "\n" {
                // Check the affectedCharRange is valid
                guard NSMaxRange(affectedCharRange) <= (textView.string as NSString).length else {
                    return false
                }
                
                // Begin an undo grouping
                textView.undoManager?.beginUndoGrouping()
                
                // Register the undo action
                let undoManager = textView.undoManager
                undoManager?.registerUndo(withTarget: self, handler: { [oldString = textView.string] selfTarget in
                    guard NSMaxRange(affectedCharRange) <= (oldString as NSString).length else {
                        return
                    }
                    
                    textView.string = oldString
                    textView.setSelectedRange(affectedCharRange)
                })
                undoManager?.setActionName("Insert Bullet Point")
                
                // Apply the bullet and update text storage
                let bulletPointString = NSAttributedString(string: "\n\u{2022} ", attributes: [.font: textView.font ?? NSFont.systemFont(ofSize: 14)])
                textView.textStorage?.replaceCharacters(in: affectedCharRange, with: bulletPointString)
                let newCursorPos = affectedCharRange.location + bulletPointString.length
                textView.setSelectedRange(NSRange(location: newCursorPos, length: 0))
                
                // End the undo grouping
                textView.undoManager?.endUndoGrouping()
                
                parent.text = textView.string
                return false
            }
            
            return true
        }
        
        
        
    }
}

