import Cocoa

enum TextInputStyle {
    case standard
    case multiline
    case numeric
}

class TextInput: NSTextField {
    private var inputStyle: TextInputStyle = .standard
    private var onTextChanged: ((String) -> Void)?
    
    convenience init(placeholder: String, style: TextInputStyle = .standard, onChange: ((String) -> Void)? = nil) {
        self.init(frame: .zero)
        self.placeholderString = placeholder
        self.inputStyle = style
        self.onTextChanged = onChange
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
        font = NSFont.systemFont(ofSize: 13)
        isBordered = true
        isBezeled = true
        bezelStyle = .roundedBezel
        
        if let cell = cell as? NSTextFieldCell {
            cell.lineBreakMode = .byWordWrapping
        }
        
        switch inputStyle {
        case .standard:
            setContentHuggingPriority(.defaultLow, for: .horizontal)
            setContentHuggingPriority(.defaultHigh, for: .vertical)
            setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            heightAnchor.constraint(greaterThanOrEqualToConstant: 22).isActive = true
        case .multiline:
            maximumNumberOfLines = 0
            cell?.wraps = true
            cell?.isScrollable = true
            setContentHuggingPriority(.defaultLow, for: .horizontal)
            setContentHuggingPriority(.defaultLow, for: .vertical)
            setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        case .numeric:
            alignment = .right
            setContentHuggingPriority(.defaultHigh, for: .horizontal)
            setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            widthAnchor.constraint(equalToConstant: 80).isActive = true
            heightAnchor.constraint(greaterThanOrEqualToConstant: 22).isActive = true
        }
        
        if onTextChanged != nil {
            target = self
            action = #selector(textChanged)
        }
    }
    
    @objc private func textChanged() {
        onTextChanged?(stringValue)
    }
    
    func setStyle(_ style: TextInputStyle) {
        inputStyle = style
        setup()
    }
}

