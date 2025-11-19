import Cocoa

class FormRow: NSStackView {
    init(label: String, control: NSView, helperText: String? = nil) {
        super.init(frame: .zero)
        orientation = .vertical
        distribution = .fill
        spacing = 8
        
        let header = SectionHeader(title: label)
        addView(header, in: .top)
        
        if let helperText = helperText {
            let helper = HelperLabel(text: helperText)
            addView(helper, in: .top)
        }
        
        addView(control, in: .top)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

