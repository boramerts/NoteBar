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

        // Load the richText data
        if let attrString = NSAttributedString(rtf: richText, documentAttributes: nil) {
            textView.textStorage?.setAttributedString(attrString)
        }

        // Embed the textView in the scrollView
        scrollView.documentView = textView

        return scrollView // Return the scrollView containing the textView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }

        DispatchQueue.main.async {
            context.coordinator.updateTypingAttributes(textView: textView)

            if self.isList {
                context.coordinator.applyListFormatting(textView: textView)
            } else {
                context.coordinator.removeListFormatting(textView: textView)
            }

            context.coordinator.applyFontTraits(textView: textView, isBold: self.isBold, isItalic: self.isItalic)
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
            if let textStorage = textView.textStorage {
                do {
                    self.parent.richText = try textStorage.rtf()
                } catch {
                    print("Error generating RTF data: \(error)")
                }
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

            // Allow backspace to delete bullet points as normal text
            return true
        }

        func updateTypingAttributes(textView: NSTextView) {
            var attributes = textView.typingAttributes
            attributes[.font] = textView.font
            attributes[.foregroundColor] = textView.textColor
            textView.typingAttributes = attributes
        }

        func applyFontTraits(textView: NSTextView, isBold: Bool, isItalic: Bool) {
            let fontManager = NSFontManager.shared
            var font = textView.font ?? NSFont.systemFont(ofSize: 14)

            if isBold {
                font = fontManager.convert(font, toHaveTrait: .boldFontMask)
            } else {
                font = fontManager.convert(font, toNotHaveTrait: .boldFontMask)
            }

            if isItalic {
                font = fontManager.convert(font, toHaveTrait: .italicFontMask)
            } else {
                font = fontManager.convert(font, toNotHaveTrait: .italicFontMask)
            }

            textView.typingAttributes[.font] = font
        }

        func applyListFormatting(textView: NSTextView) {
            guard let textStorage = textView.textStorage else { return }
            let selectedRange = textView.selectedRange()
            let fullText = textStorage.string as NSString

            // Apply bullet points to each line in the selected range
            textStorage.beginEditing()
            fullText.enumerateSubstrings(in: selectedRange, options: .byLines) { (substring, substringRange, _, _) in
                if let substring = substring, !substring.starts(with: "\u{2022} ") {
                    let newSubstring = "\u{2022} " + substring
                    textStorage.replaceCharacters(in: substringRange, with: newSubstring)
                }
            }
            textStorage.endEditing()

            // Adjust the cursor position
            textView.setSelectedRange(NSRange(location: selectedRange.location, length: 0))
        }

        func removeListFormatting(textView: NSTextView) {
            guard let textStorage = textView.textStorage else { return }
            let selectedRange = textView.selectedRange()
            let fullText = textStorage.string as NSString

            // Remove bullet points from each line in the selected range
            textStorage.beginEditing()
            fullText.enumerateSubstrings(in: selectedRange, options: .byLines) { (substring, substringRange, _, _) in
                if let substring = substring, substring.starts(with: "\u{2022} ") {
                    let newSubstring = substring.dropFirst(2)
                    textStorage.replaceCharacters(in: substringRange, with: String(newSubstring))
                }
            }
            textStorage.endEditing()

            // Adjust the cursor position
            textView.setSelectedRange(NSRange(location: selectedRange.location, length: 0))
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
