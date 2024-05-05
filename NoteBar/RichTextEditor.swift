import SwiftUI
import AppKit

struct RichTextEditor: NSViewRepresentable {
    @Binding var text: String
    @Binding var richText: Data
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
            textView.textColor = NSColor.white
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
            if let textStorage = textView.textStorage { // Set rich text
                do {
                    self.parent.richText = try textStorage.rtf()
                } catch {
                    print("Error generating RTF data: \(error)")
                }
            }
        }
        
        func toggleFontTrait(textView: NSTextView, trait: NSFontTraitMask, shouldApply: Bool) {
            let fontManager = NSFontManager.shared
            let selectedRange = textView.selectedRange()
            
            if selectedRange.length > 0 {
                if let font = textView.textStorage?.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? NSFont {
                    let newFont = shouldApply ? fontManager.convert(font, toHaveTrait: trait) : fontManager.convert(font, toNotHaveTrait: trait)
                    textView.textStorage?.addAttribute(.font, value: newFont, range: selectedRange)
                }
            } else {
                let currentFont = textView.typingAttributes[.font] as? NSFont ?? NSFont.systemFont(ofSize: 14)
                let newFont = shouldApply ? fontManager.convert(currentFont, toHaveTrait: trait) : fontManager.convert(currentFont, toNotHaveTrait: trait)
                textView.typingAttributes[.font] = newFont
            }
        }
        
        func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            guard let replacementString = replacementString else { return true }
            
            // Handle automatic bullet point insertion when Enter key is pressed
            if parent.isList && replacementString == "\n" {
                let newText = "\u{2022} "
                let newString = "\n" + newText
                textView.textStorage?.replaceCharacters(in: affectedCharRange, with: newString)
                let newPos = affectedCharRange.location + newString.count
                textView.setSelectedRange(NSRange(location: newPos, length: 0))
                return false
            }
            
            return true
        }
        
        func toggleListMode(textView: NSTextView) {
            guard let textStorage = textView.textStorage else { return }
            
            let fullText = textStorage.string as NSString
            let cursorPosition = textView.selectedRange().location
            
            // Get the range for the current line from the cursor position
            let currentLineRange = fullText.lineRange(for: NSRange(location: cursorPosition, length: 0))
            let currentLineText = fullText.substring(with: currentLineRange) // Get the whole line text
            
            print(currentLineText)
            
            if parent.isList {
                if !currentLineText.starts(with: "\u{2022} ") {
                    // Add bullet point at the start of the current line if it doesn't have one
                    print("Adding bullet point to start")
                    let newLineText = "\u{2022} " + currentLineText
                    let replacementRange = NSRange(location: currentLineRange.location, length: currentLineText.count)
                    textStorage.replaceCharacters(in: replacementRange, with: newLineText)
                }
            } else {
                if currentLineText.starts(with: "\u{2022} ") {
                    // Remove the bullet point if the line starts with it
                    print("Removing bullet point")
                    let newLineText = String(currentLineText.dropFirst(2))
                    let replacementRange = NSRange(location: currentLineRange.location, length: currentLineText.count)
                    textStorage.replaceCharacters(in: replacementRange, with: newLineText)
                }
            }
            
            // Correct the cursor position after modifying the text
            let newPosition = cursorPosition + (parent.isList ? 2 : -2)
            textView.setSelectedRange(NSRange(location: newPosition, length: 0))
            textView.needsDisplay = true
        }
        
    }
    
}

extension NSAttributedString {
    func rtf() throws -> Data {
        try data(from: .init(location: 0, length: length),
                 documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf,
                                      .characterEncoding: String.Encoding.utf8])
    }
}



