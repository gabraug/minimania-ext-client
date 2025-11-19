import Cocoa

class HelperLabel: NSTextField {
    init(text: String) {
        super.init(frame: .zero)
        stringValue = text
        font = NSFont.systemFont(ofSize: 11)
        textColor = .secondaryLabelColor
        alignment = .left
        isEditable = false
        isSelectable = false
        isBordered = false
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

