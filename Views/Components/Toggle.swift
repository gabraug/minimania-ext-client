import Cocoa

class Toggle: NSStackView {
    var toggleButton: Button!
    private var onToggle: ((Bool) -> Void)?
    
    convenience init(label: String, isOn: Bool = false, toolTip: String? = nil, onChange: ((Bool) -> Void)? = nil) {
        self.init(frame: .zero)
        self.onToggle = onChange
        setup(label: label, isOn: isOn, toolTip: toolTip)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup(label: String, isOn: Bool, toolTip: String?) {
        orientation = .horizontal
        distribution = .fill
        spacing = 16
        alignment = .centerY
        translatesAutoresizingMaskIntoConstraints = false
        edgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let labelView = Text(label, style: .heading)
        labelView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        labelView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        toggleButton = Button(title: isOn ? "ON" : "OFF", style: .toggle) { [weak self] in
            guard let self = self else { return }
            let newState = self.toggleButton.title == "OFF"
            self.toggleButton.title = newState ? "ON" : "OFF"
            self.toggleButton.contentTintColor = newState ? .systemGreen : .systemGray
            self.onToggle?(newState)
        }
        toggleButton.contentTintColor = isOn ? .systemGreen : .systemGray
        toggleButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        if let toolTip = toolTip {
            toggleButton.toolTip = toolTip
        }
        
        addView(labelView, in: .leading)
        addView(toggleButton, in: .leading)
        addView(Spacer(), in: .leading)
    }
    
    var isOn: Bool {
        get {
            toggleButton.title == "ON"
        }
        set {
            toggleButton.title = newValue ? "ON" : "OFF"
            toggleButton.contentTintColor = newValue ? .systemGreen : .systemGray
        }
    }
}

