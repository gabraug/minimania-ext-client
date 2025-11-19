import Cocoa

class Modal: NSWindow {
    private var contentStackView: NSStackView!
    private var modalParentWindow: NSWindow?
    private var onClose: (() -> Void)?
    
    convenience init(title: String, width: CGFloat = 540, height: CGFloat = 400, parent: NSWindow? = nil) {
        let rect = NSRect(x: 0, y: 0, width: width, height: height)
        self.init(contentRect: rect, styleMask: [.titled, .closable], backing: .buffered, defer: false)
        self.title = title
        self.modalParentWindow = parent
        self.isReleasedWhenClosed = false
        setup()
    }
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        setup()
    }
    
    private func setup() {
        let containerView = NSView(frame: contentView!.bounds)
        containerView.autoresizingMask = [.width, .height]
        
        contentStackView = NSStackView(frame: containerView.bounds)
        contentStackView.orientation = .vertical
        contentStackView.distribution = .fill
        contentStackView.spacing = 0
        contentStackView.edgeInsets = NSEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
        contentStackView.autoresizingMask = [.width, .height]
        
        containerView.addSubview(contentStackView)
        contentView = containerView
    }
    
    func addSection(_ views: [NSView], spacing: CGFloat = 20, topPadding: CGFloat = 0, bottomPadding: CGFloat = 0) {
        let sectionStack = NSStackView()
        sectionStack.orientation = .vertical
        sectionStack.distribution = .fill
        sectionStack.spacing = spacing
        sectionStack.edgeInsets = NSEdgeInsets(top: topPadding, left: 0, bottom: bottomPadding, right: 0)
        
        for view in views {
            sectionStack.addView(view, in: .top)
        }
        
        contentStackView.addView(sectionStack, in: .top)
    }
    
    func addSeparator(topPadding: CGFloat = 20, bottomPadding: CGFloat = 20) {
        let separatorContainer = NSStackView()
        separatorContainer.orientation = .vertical
        separatorContainer.distribution = .fill
        separatorContainer.spacing = 0
        separatorContainer.edgeInsets = NSEdgeInsets(top: topPadding, left: 0, bottom: bottomPadding, right: 0)
        
        let separator = NSBox()
        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        separatorContainer.addView(separator, in: .top)
        contentStackView.addView(separatorContainer, in: .top)
    }
    
    func addButtonRow(_ buttons: [NSButton], spacing: CGFloat = 16, distribution: NSStackView.Distribution = .fillEqually) {
        let buttonStack = NSStackView()
        buttonStack.orientation = .horizontal
        buttonStack.distribution = distribution
        buttonStack.spacing = spacing
        buttonStack.edgeInsets = NSEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        
        for button in buttons {
            buttonStack.addView(button, in: .leading)
        }
        
        contentStackView.addView(buttonStack, in: .top)
    }
    
    func show() {
        guard let parent = modalParentWindow else {
            makeKeyAndOrderFront(nil)
            centerModal()
            return
        }
        
        centerRelativeToParent(parent)
        parent.beginSheet(self) { [weak self] _ in
            self?.onClose?()
        }
    }
    
    func dismiss() {
        if let parent = modalParentWindow {
            parent.endSheet(self)
        } else {
            performClose(nil)
        }
    }
    
    func setOnClose(_ handler: @escaping () -> Void) {
        onClose = handler
    }
    
    private func centerRelativeToParent(_ parent: NSWindow) {
        let parentFrame = parent.frame
        let modalFrame = self.frame
        let x = parentFrame.origin.x + (parentFrame.width - modalFrame.width) / 2
        let y = parentFrame.origin.y + (parentFrame.height - modalFrame.height) / 2
        setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    private func centerModal() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let windowFrame = self.frame
        let x = screenFrame.origin.x + (screenFrame.width - windowFrame.width) / 2
        let y = screenFrame.origin.y + (screenFrame.height - windowFrame.height) / 2
        setFrameOrigin(NSPoint(x: x, y: y))
    }
}

