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
            print("Updating view, isBold: \(self.isBold), isItalic: \(self.isItalic)")
            if self.isList {
                context.coordinator.toggleListMode(textView: textView)
            }
            
            // Apply text styles after handling list mode to ensure they are not overwritten
            context.coordinator.toggleFontTrait(textView: textView, trait: .boldFontMask, shouldApply: self.isBold)
            context.coordinator.toggleFontTrait(textView: textView, trait: .italicFontMask, shouldApply: self.isItalic)
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            self.parent.text = textView.string
        }
        
        // TODO: Removes all formatting when new line is added
        func toggleFontTrait(textView: NSTextView, trait: NSFontTraitMask, shouldApply: Bool) {
            let fontManager = NSFontManager.shared
            let selectedRange = textView.selectedRange()
            
            if selectedRange.length > 0 {
                // If there's a selection, apply the style to the selected text.
                if let font = textView.textStorage?.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? NSFont {
                    let newFont = shouldApply ? fontManager.convert(font, toHaveTrait: trait) : fontManager.convert(font, toNotHaveTrait: trait)
                    textView.textStorage?.addAttribute(.font, value: newFont, range: selectedRange)
                }
            } else {
                // Set the style as the default for new text.
                let currentFont = textView.typingAttributes[.font] as? NSFont ?? NSFont.systemFont(ofSize: 14)
                let newFont = shouldApply ? fontManager.convert(currentFont, toHaveTrait: trait) : fontManager.convert(currentFont, toNotHaveTrait: trait)
                textView.typingAttributes[.font] = newFont
            }

            // This triggers the text view to refresh and apply new attributes.
            textView.needsDisplay = true
        }
        
        func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            guard let replacementString = replacementString else { return true }
            
            // Handle automatic bullet point insertion
            if parent.isList && replacementString == "\n" {
                let newText = "\u{2022} "  // Bullet character followed by a space
                let currentText = textView.string as NSString
                let newString = currentText.replacingCharacters(in: affectedCharRange, with: "\n" + newText)
                textView.string = newString
                let newPos = affectedCharRange.location + newText.count + 1  // Move the cursor after the bullet point
                textView.setSelectedRange(NSRange(location: newPos, length: 0))
                return false
            }
            
            return true
        }
        
        func toggleListMode(textView: NSTextView) {
            guard let textStorage = textView.textStorage else { return }
            
            let cursorPosition = textView.selectedRange().location
            
            // Determine if we're adding or removing bullet points
            if parent.isList {
                // Add a bullet point at the current line if not present
                let currentLineRange = (textView.string as NSString).lineRange(for: NSRange(location: cursorPosition, length: 0))
                let currentLineText = (textView.string as NSString).substring(with: currentLineRange)
                
                if !currentLineText.trimmingCharacters(in: .whitespaces).starts(with: "\u{2022} ") {
                    let newLineText = "\u{2022} " + currentLineText
                    let newAttributedLine = NSAttributedString(string: newLineText, attributes: textView.typingAttributes)
                    textStorage.replaceCharacters(in: currentLineRange, with: newAttributedLine)
                }
            } else {
                // Remove bullet points from each line where they are present
                let fullRange = NSRange(location: 0, length: textStorage.length)
                textStorage.enumerateAttribute(.paragraphStyle, in: fullRange, options: []) { _, range, _ in
                    let line = (textStorage.string as NSString).substring(with: range)
                    if line.trimmingCharacters(in: .whitespaces).starts(with: "\u{2022} ") {
                        let newLine = String(line.dropFirst(2))
                        let newAttributedLine = NSAttributedString(string: newLine, attributes: textView.typingAttributes)
                        textStorage.replaceCharacters(in: range, with: newAttributedLine)
                    }
                }
            }
            
            textView.setSelectedRange(NSRange(location: cursorPosition, length: 0))  // Maintain cursor position
            textView.needsDisplay = true  // Trigger view update
        }


    }
}

