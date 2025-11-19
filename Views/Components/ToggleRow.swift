import Cocoa

class ToggleRow: NSStackView {
    var toggleButton: ToggleButton!
    
    init(label: String, isOn: Bool = false, toolTip: String? = nil) {
        super.init(frame: .zero)
        orientation = .horizontal
        distribution = .fill
        spacing = 12
        alignment = .centerY
        
        let header = SectionHeader(title: label)
        header.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        header.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        toggleButton = ToggleButton()
        toggleButton.isOn = isOn
        if let toolTip = toolTip {
            toggleButton.toolTip = toolTip
        }
        
        addView(header, in: .leading)
        addView(toggleButton, in: .leading)
        addView(NSView(), in: .leading)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

