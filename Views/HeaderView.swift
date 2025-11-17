import Cocoa

class HeaderView: NSView {
    var refreshButton: NSButton!
    var zoomInButton: NSButton!
    var zoomOutButton: NSButton!
    var zoomResetButton: NSButton!
    var antiAfkButton: NSButton!
    var autoMessageButton: NSButton!
    var autoReplyButton: NSButton!
    var autoPlantacaoButton: NSButton!
    var autoMessageIntervalField: NSTextField!
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
        
        refreshButton = NSButton(title: "Refresh", target: target, action: #selector((target as? HeaderViewDelegate)?.refreshPage))
        refreshButton.bezelStyle = .rounded
        refreshButton.controlSize = .small
        refreshButton.toolTip = "Reload the current page"
        refreshButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
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
        
        antiAfkButton = NSButton(title: "Anti-AFK", target: target, action: #selector((target as? HeaderViewDelegate)?.toggleAntiAfk))
        antiAfkButton.bezelStyle = .rounded
        antiAfkButton.controlSize = .small
        antiAfkButton.toolTip = "Enable/disable anti-away system"
        antiAfkButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        urlLabel = NSTextField(labelWithString: "https://minimania.app/")
        urlLabel.font = NSFont.systemFont(ofSize: 11)
        urlLabel.textColor = .secondaryLabelColor
        urlLabel.alignment = .left
        urlLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        playersCountLabel = NSTextField(labelWithString: "Players: --")
        playersCountLabel.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        playersCountLabel.textColor = .labelColor
        playersCountLabel.alignment = .right
        playersCountLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let messageConfigButton = NSButton(title: "Message", target: target, action: #selector((target as? HeaderViewDelegate)?.openMessageModal))
        messageConfigButton.bezelStyle = .rounded
        messageConfigButton.controlSize = .small
        messageConfigButton.toolTip = "Configure automatic message settings"
        messageConfigButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let intervalLabel = NSTextField(labelWithString: "Interval:")
        intervalLabel.font = NSFont.systemFont(ofSize: 11)
        intervalLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        autoMessageIntervalField = NSTextField()
        autoMessageIntervalField.placeholderString = "5"
        autoMessageIntervalField.stringValue = "5"
        autoMessageIntervalField.font = NSFont.systemFont(ofSize: 11)
        autoMessageIntervalField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        autoMessageIntervalField.target = target
        autoMessageIntervalField.action = #selector((target as? HeaderViewDelegate)?.intervalFieldChanged)
        
        autoMessageButton = NSButton(title: "Auto Message", target: target, action: #selector((target as? HeaderViewDelegate)?.toggleAutoMessage))
        autoMessageButton.bezelStyle = .rounded
        autoMessageButton.controlSize = .small
        autoMessageButton.toolTip = "Enable/disable automatic message sending"
        autoMessageButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let autoReplyConfigButton = NSButton(title: "Auto-Reply", target: target, action: #selector((target as? HeaderViewDelegate)?.openAutoReplyModal))
        autoReplyConfigButton.bezelStyle = .rounded
        autoReplyConfigButton.controlSize = .small
        autoReplyConfigButton.toolTip = "Configure automatic reply system"
        autoReplyConfigButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        autoReplyButton = NSButton(title: "Reply [OFF]", target: target, action: #selector((target as? HeaderViewDelegate)?.toggleAutoReply))
        autoReplyButton.bezelStyle = .rounded
        autoReplyButton.controlSize = .small
        autoReplyButton.toolTip = "Enable/disable automatic reply"
        autoReplyButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        autoPlantacaoButton = NSButton(title: "Auto Farming", target: target, action: #selector((target as? HeaderViewDelegate)?.openAutoPlantacaoModal))
        autoPlantacaoButton.bezelStyle = .rounded
        autoPlantacaoButton.controlSize = .small
        autoPlantacaoButton.toolTip = "Open automatic farming automation window"
        autoPlantacaoButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        stackView.addView(refreshButton, in: .leading)
        stackView.addView(antiAfkButton, in: .leading)
        stackView.addView(zoomOutButton, in: .leading)
        stackView.addView(zoomResetButton, in: .leading)
        stackView.addView(zoomInButton, in: .leading)
        stackView.addView(messageConfigButton, in: .leading)
        stackView.addView(intervalLabel, in: .leading)
        stackView.addView(autoMessageIntervalField, in: .leading)
        stackView.addView(autoMessageButton, in: .leading)
        stackView.addView(autoReplyConfigButton, in: .leading)
        stackView.addView(autoReplyButton, in: .leading)
        stackView.addView(autoPlantacaoButton, in: .leading)
        stackView.addView(urlLabel, in: .center)
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
    @objc func toggleAutoMessage()
    @objc func toggleAutoReply()
    @objc func intervalFieldChanged()
}

