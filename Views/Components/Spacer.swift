import Cocoa

class Spacer: NSView {
    convenience init(width: CGFloat? = nil, height: CGFloat? = nil) {
        self.init(frame: .zero)
        setup(width: width, height: height)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setup(width: CGFloat?, height: CGFloat?) {
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
            setContentHuggingPriority(.defaultHigh, for: .horizontal)
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
            setContentHuggingPriority(.defaultHigh, for: .vertical)
        }
    }
}

