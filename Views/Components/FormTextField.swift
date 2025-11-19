import Cocoa

class FormTextField: NSTextField {
    init(placeholder: String) {
        super.init(frame: .zero)
        self.placeholderString = placeholder
        font = NSFont.systemFont(ofSize: 13)
        isBordered = true
        isBezeled = true
        bezelStyle = .roundedBezel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

