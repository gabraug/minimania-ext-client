import Cocoa

class MessageModal {
    var window: NSWindow!
    var textField: NSTextField!
    var saveButton: NSButton!
    weak var parentWindow: NSWindow?
    var onSave: ((String) -> Void)?
    
    func create(parentWindow: NSWindow) {
        self.parentWindow = parentWindow
        
        let modalRect = NSRect(x: 0, y: 0, width: 500, height: 200)
        window = NSWindow(
            contentRect: modalRect,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Configure Automatic Message"
        window.isReleasedWhenClosed = false
        
        let containerView = NSView(frame: window.contentView!.bounds)
        containerView.autoresizingMask = [.width, .height]
        
        let stackView = NSStackView(frame: containerView.bounds)
        stackView.orientation = .vertical
        stackView.distribution = .fill
        stackView.spacing = 15
        stackView.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.autoresizingMask = [.width, .height]
        
        let label = NSTextField(labelWithString: "Enter the message that will be sent automatically:")
        label.font = NSFont.systemFont(ofSize: 13)
        label.alignment = .left
        
        textField = NSTextField()
        textField.placeholderString = "Type your message here..."
        textField.font = NSFont.systemFont(ofSize: 13)
        textField.isBordered = true
        textField.maximumNumberOfLines = 0
        textField.cell?.wraps = true
        textField.cell?.isScrollable = true
        textField.setContentHuggingPriority(.defaultLow, for: .vertical)
        
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
        
        stackView.addView(label, in: .top)
        stackView.addView(textField, in: .top)
        stackView.addView(buttonStackView, in: .top)
        
        containerView.addSubview(stackView)
        window.contentView = containerView
        
        centerModal()
    }
    
    func show(with text: String) {
        if window == nil {
            guard let parent = parentWindow else { return }
            create(parentWindow: parent)
        }
        
        textField.stringValue = text
        parentWindow?.beginSheet(window) { _ in }
    }
    
    @objc private func save() {
        let text = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave?(text)
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

