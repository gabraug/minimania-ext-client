import Cocoa

class ToggleButton: NSButton {
    var isOn: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        bezelStyle = .rounded
        controlSize = .regular
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        widthAnchor.constraint(equalToConstant: 90).isActive = true
        updateAppearance()
    }
    
    private func updateAppearance() {
        title = isOn ? "ON" : "OFF"
        contentTintColor = isOn ? .systemGreen : .systemGray
    }
}

