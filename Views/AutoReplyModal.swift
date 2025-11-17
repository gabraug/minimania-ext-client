import Cocoa

class AutoReplyModal {
    var window: NSWindow!
    var keywordField: NSTextField!
    var messageField: NSTextField!
    var saveButton: NSButton!
    weak var parentWindow: NSWindow?
    var onSave: ((String, String) -> Void)?
    
    func create(parentWindow: NSWindow) {
        self.parentWindow = parentWindow
        
        let modalRect = NSRect(x: 0, y: 0, width: 500, height: 250)
        window = NSWindow(
            contentRect: modalRect,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Configure Auto-Reply"
        window.isReleasedWhenClosed = false
        
        let containerView = NSView(frame: window.contentView!.bounds)
        containerView.autoresizingMask = [.width, .height]
        
        let stackView = NSStackView(frame: containerView.bounds)
        stackView.orientation = .vertical
        stackView.distribution = .fill
        stackView.spacing = 15
        stackView.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.autoresizingMask = [.width, .height]
        
        let keywordLabel = NSTextField(labelWithString: "Keyword (will be detected in chat):")
        keywordLabel.font = NSFont.systemFont(ofSize: 13)
        keywordLabel.alignment = .left
        
        keywordField = NSTextField()
        keywordField.placeholderString = "Enter the keyword..."
        keywordField.font = NSFont.systemFont(ofSize: 13)
        keywordField.isBordered = true
        keywordField.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        let messageLabel = NSTextField(labelWithString: "Reply message:")
        messageLabel.font = NSFont.systemFont(ofSize: 13)
        messageLabel.alignment = .left
        
        messageField = NSTextField()
        messageField.placeholderString = "Enter the reply message..."
        messageField.font = NSFont.systemFont(ofSize: 13)
        messageField.isBordered = true
        messageField.maximumNumberOfLines = 0
        messageField.cell?.wraps = true
        messageField.cell?.isScrollable = true
        messageField.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        let buttonStackView = NSStackView()
        buttonStackView.orientation = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 10
        
        let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(close))
        cancelButton.bezelStyle = .rounded
        cancelButton.keyEquivalent = "\u{1b}"
        
        saveButton = NSButton(title: "Save", target: self, action: #selector(save))
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r"
        
        buttonStackView.addView(cancelButton, in: .leading)
        buttonStackView.addView(saveButton, in: .leading)
        
        stackView.addView(keywordLabel, in: .top)
        stackView.addView(keywordField, in: .top)
        stackView.addView(messageLabel, in: .top)
        stackView.addView(messageField, in: .top)
        stackView.addView(buttonStackView, in: .top)
        
        containerView.addSubview(stackView)
        window.contentView = containerView
        
        centerModal()
    }
    
    func show(keyword: String, message: String) {
        if window == nil {
            guard let parent = parentWindow else { return }
            create(parentWindow: parent)
        }
        
        keywordField.stringValue = keyword
        messageField.stringValue = message
        parentWindow?.beginSheet(window) { _ in }
    }
    
    @objc private func save() {
        let keyword = keywordField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let message = messageField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave?(keyword, message)
        close()
    }
    
    @objc private func close() {
        parentWindow?.endSheet(window)
    }
    
    private func centerModal() {
        guard let windowFrame = parentWindow?.frame else { return }
        let modalFrame = window.frame
        let x = windowFrame.origin.x + (windowFrame.width - modalFrame.width) / 2
        let y = windowFrame.origin.y + (windowFrame.height - modalFrame.height) / 2
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}

