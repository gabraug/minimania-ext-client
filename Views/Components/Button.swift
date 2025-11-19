import Cocoa

enum ButtonStyle {
    case primary
    case secondary
    case minimal
    case toggle
}

class Button: NSButton {
    private var buttonStyle: ButtonStyle = .primary
    private var customAction: (() -> Void)?
    
    convenience init(title: String, style: ButtonStyle = .primary, action: (() -> Void)? = nil) {
        self.init(frame: .zero)
        self.title = title
        self.buttonStyle = style
        self.customAction = action
        setup()
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
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        
        switch buttonStyle {
        case .primary:
            bezelStyle = .rounded
            controlSize = .regular
            contentTintColor = .controlAccentColor
            keyEquivalent = "\r"
        case .secondary:
            bezelStyle = .rounded
            controlSize = .regular
            contentTintColor = .secondaryLabelColor
            keyEquivalent = "\u{1b}"
        case .minimal:
            bezelStyle = .texturedRounded
            controlSize = .small
            isBordered = false
        case .toggle:
            bezelStyle = .rounded
            controlSize = .regular
            widthAnchor.constraint(equalToConstant: 100).isActive = true
            heightAnchor.constraint(greaterThanOrEqualToConstant: 28).isActive = true
        }
        
        if customAction != nil {
            target = self
            action = #selector(buttonTapped)
        }
    }
    
    @objc private func buttonTapped() {
        customAction?()
    }
    
    func setStyle(_ style: ButtonStyle) {
        buttonStyle = style
        setup()
    }
}

