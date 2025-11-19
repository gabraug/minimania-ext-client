import Cocoa

class ChatHistoryModal {
    var modal: Modal!
    var messagesStackView: NSStackView!
    var pageLabel: Text!
    var previousButton: Button!
    var nextButton: Button!
    var toggle: Toggle!
    var clearButton: Button!
    weak var parentWindow: NSWindow?
    
    private var currentPage = 0
    private let pageSize = 10
    private var totalPages = 0
    private var totalMessages = 0
    
    var onToggle: ((Bool) -> Void)?
    var onClearHistory: (() -> Void)?
    
    func create(parentWindow: NSWindow) {
        self.parentWindow = parentWindow
        
        modal = Modal(title: "Chat History", width: 640, height: 520, parent: parentWindow)
        
        toggle = Toggle(
            label: "Enable History",
            isOn: false,
            toolTip: "Enable or disable chat history recording",
            onChange: { [weak self] isOn in
                self?.onToggle?(isOn)
            }
        )
        
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .bezelBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.setContentHuggingPriority(.defaultLow, for: .vertical)
        scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300).isActive = true
        
        messagesStackView = NSStackView()
        messagesStackView.orientation = .vertical
        messagesStackView.distribution = .fill
        messagesStackView.spacing = 8
        messagesStackView.edgeInsets = NSEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        messagesStackView.alignment = .leading
        messagesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.documentView = messagesStackView
        messagesStackView.widthAnchor.constraint(equalTo: scrollView.contentView.widthAnchor).isActive = true
        
        previousButton = Button(title: "Previous", style: .secondary) { [weak self] in
            self?.previousPage()
        }
        pageLabel = Text("Page 1 of 1", style: .body)
        nextButton = Button(title: "Next", style: .secondary) { [weak self] in
            self?.nextPage()
        }
        
        let paginationRow = Row([
            previousButton!,
            Spacer(),
            pageLabel!,
            Spacer(),
            nextButton!
        ], spacing: 12, alignment: .centerY)
        
        previousButton.isEnabled = false
        nextButton.isEnabled = false
        
        clearButton = Button(title: "Clear History", style: .secondary) { [weak self] in
            self?.confirmClear()
        }
        
        modal.addSection([toggle], spacing: 20)
        modal.addSeparator(topPadding: 20, bottomPadding: 20)
        modal.addSection([scrollView], spacing: 20)
        modal.addSeparator(topPadding: 20, bottomPadding: 20)
        modal.addSection([paginationRow], spacing: 20)
        modal.addSeparator(topPadding: 20, bottomPadding: 20)
        modal.addSection([clearButton], spacing: 20)
        modal.addSeparator(topPadding: 20, bottomPadding: 20)
        
        let closeButton = Button(title: "Close", style: .primary) { [weak self] in
            self?.close()
        }
        
        modal.addButtonRow([closeButton], spacing: 16, distribution: .fill)
    }
    
    func show(isEnabled: Bool, messages: [ChatMessage], currentPage: Int, totalPages: Int, totalMessages: Int) {
        if modal == nil {
            guard let parent = parentWindow else { return }
            create(parentWindow: parent)
        }
        
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalMessages = totalMessages
        toggle.isOn = isEnabled
        
        updateMessages(messages: messages)
        updatePagination()
        modal.show()
    }
    
    func updateMessages(messages: [ChatMessage]) {
        messagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if messages.isEmpty {
            let emptyLabel = Text("No messages recorded yet", style: .body)
            emptyLabel.textColor = .secondaryLabelColor
            emptyLabel.alignment = .center
            messagesStackView.addView(emptyLabel, in: .top)
        } else {
            for message in messages {
                let messageView = createMessageView(message: message)
                messagesStackView.addView(messageView, in: .top)
            }
        }
    }
    
    private func createMessageView(message: ChatMessage) -> NSView {
        let container = NSStackView()
        container.orientation = .vertical
        container.distribution = .fill
        container.spacing = 4
        container.alignment = .leading
        container.edgeInsets = NSEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        container.layer?.cornerRadius = 6
        container.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let timestampLabel = Text(dateFormatter.string(from: message.timestamp), style: .caption)
        timestampLabel.textColor = .secondaryLabelColor
        
        let messageLabel = Text(message.text, style: .body)
        messageLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        messageLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        container.addView(timestampLabel, in: .top)
        container.addView(messageLabel, in: .top)
        
        return container
    }
    
    private func updatePagination() {
        pageLabel.stringValue = "Page \(currentPage + 1) of \(max(totalPages, 1)) (\(totalMessages) messages)"
        previousButton.isEnabled = currentPage > 0
        nextButton.isEnabled = currentPage < totalPages - 1
    }
    
    private func previousPage() {
        guard currentPage > 0 else { return }
        currentPage -= 1
        onPageChanged?()
    }
    
    private func nextPage() {
        guard currentPage < totalPages - 1 else { return }
        currentPage += 1
        onPageChanged?()
    }
    
    var onPageChanged: (() -> Void)?
    
    func refreshPage() {
        onPageChanged?()
    }
    
    func getCurrentPage() -> Int {
        return currentPage
    }
    
    private func confirmClear() {
        let alert = NSAlert()
        alert.messageText = "Clear Chat History"
        alert.informativeText = "Are you sure you want to clear all chat history? This action cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Clear")
        
        if alert.runModal() == .alertSecondButtonReturn {
            onClearHistory?()
        }
    }
    
    @objc private func close() {
        modal.dismiss()
    }
}

