import Cocoa

class FormField: NSStackView {
    var control: NSView!
    
    convenience init(label: String, control: NSView, helperText: String? = nil) {
        self.init(frame: .zero)
        self.control = control
        setup(label: label, helperText: helperText)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup(label: String, helperText: String?) {
        orientation = .vertical
        distribution = .fill
        spacing = 8
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        edgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        alignment = .leading
        
        let labelView = Text(label, style: .heading)
        labelView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        labelView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        labelView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addView(labelView, in: .top)
        
        if let helperText = helperText {
            let helperView = Text(helperText, style: .helper)
            helperView.setContentHuggingPriority(.defaultHigh, for: .vertical)
            helperView.setContentHuggingPriority(.defaultLow, for: .horizontal)
            helperView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            addView(helperView, in: .top)
        }
        
        control.setContentHuggingPriority(.defaultLow, for: .vertical)
        control.setContentHuggingPriority(.defaultLow, for: .horizontal)
        if control.translatesAutoresizingMaskIntoConstraints {
            control.translatesAutoresizingMaskIntoConstraints = false
        }
        addView(control, in: .top)
    }
}

