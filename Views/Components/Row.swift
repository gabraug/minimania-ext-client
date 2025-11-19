import Cocoa

class Row: NSStackView {
    convenience init(_ views: [NSView], spacing: CGFloat = 16, alignment: NSLayoutConstraint.Attribute = .centerY) {
        self.init(frame: .zero)
        setup(views: views, spacing: spacing, alignment: alignment)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup(views: [NSView], spacing: CGFloat, alignment: NSLayoutConstraint.Attribute) {
        orientation = .horizontal
        distribution = .fill
        self.spacing = spacing
        self.alignment = alignment
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        for view in views {
            addView(view, in: .leading)
        }
        
        addView(NSView(), in: .leading)
    }
}

