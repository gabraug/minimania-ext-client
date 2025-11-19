import Cocoa

extension NSImage {
    func tinted(with color: NSColor) -> NSImage {
        let size = self.size
        return NSImage(size: size, flipped: false) { rect in
            guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                return false
            }
            
            let context = NSGraphicsContext.current!.cgContext
            context.saveGState()
            
            context.draw(cgImage, in: rect)
            
            context.setFillColor(color.cgColor)
            context.setBlendMode(.sourceAtop)
            context.fill(rect)
            
            context.restoreGState()
            return true
        }
    }
}

class HeaderView: NSView {
    var refreshButton: NSButton!
    var zoomInButton: NSButton!
    var zoomOutButton: NSButton!
    var zoomResetButton: NSButton!
    var antiAfkButton: NSButton!
    var autoMessageButton: NSButton!
    var autoReplyButton: NSButton!
    var autoPlantacaoButton: NSButton!
    var chatHistoryButton: NSButton!
    var urlLabel: NSTextField!
    var playersCountLabel: NSTextField!
    
    func setup(in containerView: NSView, target: AnyObject) {
        let headerHeight: CGFloat = 40
        frame = NSRect(x: 0, y: containerView.bounds.height - headerHeight, width: containerView.bounds.width, height: headerHeight)
        autoresizingMask = [.width, .minYMargin]
        wantsLayer = true
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        
        let stackView = NSStackView(frame: bounds)
        stackView.orientation = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.edgeInsets = NSEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        stackView.autoresizingMask = [.width, .height]
        
        let refreshIcon = NSImage(systemSymbolName: "arrow.clockwise", accessibilityDescription: "Refresh")!
        let whiteRefreshIcon = refreshIcon.tinted(with: .white)
        whiteRefreshIcon.isTemplate = false
        
        refreshButton = NSButton(image: whiteRefreshIcon, target: target, action: #selector((target as? HeaderViewDelegate)?.refreshPage))
        refreshButton.bezelStyle = .texturedRounded
        refreshButton.controlSize = .small
        refreshButton.toolTip = "Reload the current page"
        refreshButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        refreshButton.imagePosition = .imageOnly
        refreshButton.isBordered = false
        
        zoomOutButton = NSButton(title: "−", target: target, action: #selector((target as? HeaderViewDelegate)?.zoomOut))
        zoomOutButton.bezelStyle = .rounded
        zoomOutButton.controlSize = .small
        zoomOutButton.toolTip = "Zoom out"
        zoomOutButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        zoomResetButton = NSButton(title: "100%", target: target, action: #selector((target as? HeaderViewDelegate)?.zoomReset))
        zoomResetButton.bezelStyle = .rounded
        zoomResetButton.controlSize = .small
        zoomResetButton.toolTip = "Reset zoom to 100%"
        zoomResetButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        zoomInButton = NSButton(title: "+", target: target, action: #selector((target as? HeaderViewDelegate)?.zoomIn))
        zoomInButton.bezelStyle = .rounded
        zoomInButton.controlSize = .small
        zoomInButton.toolTip = "Zoom in"
        zoomInButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let antiAfkIcon = NSImage(systemSymbolName: "hand.raised", accessibilityDescription: "Anti-AFK")!
        let whiteAntiAfkIcon = antiAfkIcon.tinted(with: .white)
        whiteAntiAfkIcon.isTemplate = false
        
        antiAfkButton = NSButton(image: whiteAntiAfkIcon, target: target, action: #selector((target as? HeaderViewDelegate)?.toggleAntiAfk))
        antiAfkButton.bezelStyle = .texturedRounded
        antiAfkButton.controlSize = .small
        antiAfkButton.toolTip = "Enable/disable anti-away system"
        antiAfkButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        antiAfkButton.imagePosition = .imageOnly
        antiAfkButton.isBordered = false
        
        urlLabel = NSTextField(string: "https://minimania.app/")
        urlLabel.font = NSFont.systemFont(ofSize: 11)
        urlLabel.textColor = .secondaryLabelColor
        urlLabel.alignment = .left
        urlLabel.isEditable = false
        urlLabel.isSelectable = true
        urlLabel.isBordered = true
        urlLabel.isBezeled = false
        urlLabel.backgroundColor = .controlBackgroundColor
        urlLabel.wantsLayer = true
        urlLabel.layer?.borderWidth = 1.0
        urlLabel.layer?.borderColor = NSColor.separatorColor.cgColor
        urlLabel.layer?.cornerRadius = 4.0
        urlLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        urlLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        playersCountLabel = NSTextField(labelWithString: "Players: --")
        playersCountLabel.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        playersCountLabel.textColor = .labelColor
        playersCountLabel.alignment = .right
        playersCountLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let autoMessageIcon = NSImage(systemSymbolName: "message", accessibilityDescription: "Auto Message")!
        let whiteAutoMessageIcon = autoMessageIcon.tinted(with: .white)
        whiteAutoMessageIcon.isTemplate = false
        
        autoMessageButton = NSButton(image: whiteAutoMessageIcon, target: target, action: #selector((target as? HeaderViewDelegate)?.openMessageModal))
        autoMessageButton.bezelStyle = .texturedRounded
        autoMessageButton.controlSize = .small
        autoMessageButton.toolTip = "Configure automatic message settings"
        autoMessageButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        autoMessageButton.imagePosition = .imageOnly
        autoMessageButton.isBordered = false
        
        let autoReplyIcon = NSImage(systemSymbolName: "arrowshape.turn.up.left", accessibilityDescription: "Auto-Reply")!
        let whiteAutoReplyIcon = autoReplyIcon.tinted(with: .white)
        whiteAutoReplyIcon.isTemplate = false
        
        autoReplyButton = NSButton(image: whiteAutoReplyIcon, target: target, action: #selector((target as? HeaderViewDelegate)?.openAutoReplyModal))
        autoReplyButton.bezelStyle = .texturedRounded
        autoReplyButton.controlSize = .small
        autoReplyButton.toolTip = "Configure automatic reply system"
        autoReplyButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        autoReplyButton.imagePosition = .imageOnly
        autoReplyButton.isBordered = false
        
        let autoFarmingIcon = NSImage(systemSymbolName: "leaf", accessibilityDescription: "Auto Farming")!
        let whiteAutoFarmingIcon = autoFarmingIcon.tinted(with: .white)
        whiteAutoFarmingIcon.isTemplate = false
        
        autoPlantacaoButton = NSButton(image: whiteAutoFarmingIcon, target: target, action: #selector((target as? HeaderViewDelegate)?.openAutoPlantacaoModal))
        autoPlantacaoButton.bezelStyle = .texturedRounded
        autoPlantacaoButton.controlSize = .small
        autoPlantacaoButton.toolTip = "Configure automatic farming"
        autoPlantacaoButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        autoPlantacaoButton.imagePosition = .imageOnly
        autoPlantacaoButton.isBordered = false
        
        let chatHistoryIcon = NSImage(systemSymbolName: "clock.arrow.circlepath", accessibilityDescription: "Chat History")!
        let whiteChatHistoryIcon = chatHistoryIcon.tinted(with: .white)
        whiteChatHistoryIcon.isTemplate = false
        
        chatHistoryButton = NSButton(image: whiteChatHistoryIcon, target: target, action: #selector((target as? HeaderViewDelegate)?.openChatHistoryModal))
        chatHistoryButton.bezelStyle = .texturedRounded
        chatHistoryButton.controlSize = .small
        chatHistoryButton.toolTip = "View chat history"
        chatHistoryButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        chatHistoryButton.imagePosition = .imageOnly
        chatHistoryButton.isBordered = false
        
        stackView.addView(urlLabel, in: .leading)
        stackView.addView(refreshButton, in: .leading)
        stackView.addView(antiAfkButton, in: .leading)
        stackView.addView(autoMessageButton, in: .leading)
        stackView.addView(zoomOutButton, in: .leading)
        stackView.addView(zoomResetButton, in: .leading)
        stackView.addView(zoomInButton, in: .leading)
        stackView.addView(autoReplyButton, in: .leading)
        stackView.addView(autoPlantacaoButton, in: .leading)
        stackView.addView(chatHistoryButton, in: .leading)
        stackView.addView(playersCountLabel, in: .trailing)
        
        addSubview(stackView)
        containerView.addSubview(self)
    }
}

@objc protocol HeaderViewDelegate {
    @objc func refreshPage()
    @objc func zoomIn()
    @objc func zoomOut()
    @objc func zoomReset()
    @objc func toggleAntiAfk()
    @objc func openMessageModal()
    @objc func openAutoReplyModal()
    @objc func openAutoPlantacaoModal()
    @objc func openChatHistoryModal()
    @objc func toggleAutoMessage()
}

