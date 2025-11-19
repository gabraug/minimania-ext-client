import Cocoa

enum TextStyle {
    case title
    case heading
    case body
    case caption
    case helper
}

class Text: NSTextField {
    private var textStyle: TextStyle = .body
    
    convenience init(_ text: String, style: TextStyle = .body) {
        self.init(frame: .zero)
        self.stringValue = text
        self.textStyle = style
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
        isEditable = false
        isSelectable = false
        isBordered = false
        backgroundColor = .clear
        alignment = .left
        
        if let cell = cell as? NSTextFieldCell {
            cell.lineBreakMode = .byWordWrapping
            cell.alignment = .left
        }
        
        switch textStyle {
        case .title:
            font = NSFont.systemFont(ofSize: 18, weight: .semibold)
            textColor = .labelColor
            setContentHuggingPriority(.defaultHigh, for: .vertical)
            setContentHuggingPriority(.defaultLow, for: .horizontal)
            setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        case .heading:
            font = NSFont.systemFont(ofSize: 13, weight: .medium)
            textColor = .labelColor
            setContentHuggingPriority(.defaultHigh, for: .vertical)
            setContentHuggingPriority(.defaultLow, for: .horizontal)
            setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        case .body:
            font = NSFont.systemFont(ofSize: 13)
            textColor = .labelColor
            setContentHuggingPriority(.defaultLow, for: .vertical)
            setContentHuggingPriority(.defaultLow, for: .horizontal)
            setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        case .caption:
            font = NSFont.systemFont(ofSize: 11)
            textColor = .secondaryLabelColor
            setContentHuggingPriority(.defaultHigh, for: .vertical)
            setContentHuggingPriority(.defaultLow, for: .horizontal)
            setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        case .helper:
            font = NSFont.systemFont(ofSize: 11)
            textColor = .secondaryLabelColor
            setContentHuggingPriority(.defaultHigh, for: .vertical)
            setContentHuggingPriority(.defaultLow, for: .horizontal)
            setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
    }
    
    func setStyle(_ style: TextStyle) {
        textStyle = style
        setup()
    }
}

