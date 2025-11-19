import Cocoa

class SectionHeader: NSTextField {
    init(title: String) {
        super.init(frame: .zero)
        stringValue = title
        font = NSFont.systemFont(ofSize: 13, weight: .medium)
        textColor = .labelColor
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

