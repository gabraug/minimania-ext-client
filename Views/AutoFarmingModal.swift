import Cocoa

class AutoFarmingModal {
    var window: NSWindow!
    var seedNameField: NSTextField!
    var sourceSegmentedControl: NSSegmentedControl!
    var autoHarvestButton: NSButton!
    var autoPlantButton: NSButton!
    weak var parentWindow: NSWindow?
    
    var onToggleHarvest: (() -> Void)?
    var onTogglePlant: (() -> Void)?
    var onSeedNameChanged: ((String) -> Void)?
    var onSourceChanged: ((Bool) -> Void)?
    var onClose: (() -> Void)?
    
    func create(parentWindow: NSWindow) {
        self.parentWindow = parentWindow
        
        let modalRect = NSRect(x: 0, y: 0, width: 400, height: 340)
        window = NSWindow(
            contentRect: modalRect,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Automatic Farming"
        window.isReleasedWhenClosed = false
        
        let containerView = NSView(frame: window.contentView!.bounds)
        containerView.autoresizingMask = [.width, .height]
        
        let stackView = NSStackView(frame: containerView.bounds)
        stackView.orientation = .vertical
        stackView.distribution = .fill
        stackView.spacing = 15
        stackView.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.autoresizingMask = [.width, .height]
        
        let titleLabel = NSTextField(labelWithString: "Automatic Farming")
        titleLabel.font = NSFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.alignment = .center
        
        autoHarvestButton = NSButton(title: "Auto Harvest [OFF]", target: self, action: #selector(toggleHarvest))
        autoHarvestButton.bezelStyle = .rounded
        autoHarvestButton.controlSize = .regular
        autoHarvestButton.toolTip = "Enable/disable automatic plant harvesting"
        
        let separator = NSBox()
        separator.boxType = .separator
        separator.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        let seedSourceLabel = NSTextField(labelWithString: "Seed Source:")
        seedSourceLabel.font = NSFont.systemFont(ofSize: 13)
        seedSourceLabel.alignment = .left
        
        sourceSegmentedControl = NSSegmentedControl(labels: ["Buy Plants", "My Stock"], trackingMode: .selectOne, target: self, action: #selector(sourceChanged))
        sourceSegmentedControl.selectedSegment = 0
        sourceSegmentedControl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let seedNameLabel = NSTextField(labelWithString: "Seed Name:")
        seedNameLabel.font = NSFont.systemFont(ofSize: 13)
        seedNameLabel.alignment = .left
        
        seedNameField = NSTextField()
        seedNameField.placeholderString = "Example: Alienina Seed"
        seedNameField.font = NSFont.systemFont(ofSize: 13)
        seedNameField.isBordered = true
        seedNameField.target = self
        seedNameField.action = #selector(seedNameChanged)
        
        autoPlantButton = NSButton(title: "Auto Plant [OFF]", target: self, action: #selector(togglePlant))
        autoPlantButton.bezelStyle = .rounded
        autoPlantButton.controlSize = .regular
        autoPlantButton.toolTip = "Enable/disable automatic planting"
        
        let closeButton = NSButton(title: "Close", target: self, action: #selector(close))
        closeButton.bezelStyle = .rounded
        closeButton.keyEquivalent = "\r"
        
        stackView.addView(titleLabel, in: .top)
        stackView.addView(autoHarvestButton, in: .top)
        stackView.addView(separator, in: .top)
        stackView.addView(seedSourceLabel, in: .top)
        stackView.addView(sourceSegmentedControl, in: .top)
        stackView.addView(seedNameLabel, in: .top)
        stackView.addView(seedNameField, in: .top)
        stackView.addView(autoPlantButton, in: .top)
        stackView.addView(closeButton, in: .top)
        
        containerView.addSubview(stackView)
        window.contentView = containerView
        
        centerModal()
    }
    
    func show(seedName: String, useBuyPlants: Bool) {
        if window == nil {
            guard let parent = parentWindow else { return }
            create(parentWindow: parent)
        }
        
        seedNameField.stringValue = seedName
        sourceSegmentedControl.selectedSegment = useBuyPlants ? 0 : 1
        parentWindow?.beginSheet(window) { _ in }
    }
    
    @objc private func toggleHarvest() {
        onToggleHarvest?()
    }
    
    @objc private func togglePlant() {
        onTogglePlant?()
    }
    
    @objc private func seedNameChanged() {
        let seedName = seedNameField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        onSeedNameChanged?(seedName)
    }
    
    @objc private func sourceChanged() {
        let useBuyPlants = (sourceSegmentedControl.selectedSegment == 0)
        onSourceChanged?(useBuyPlants)
    }
    
    @objc private func close() {
        onClose?()
        parentWindow?.endSheet(window)
    }
    
    private func centerModal() {
        guard let windowFrame = parentWindow?.frame else { return }
        let modalFrame = window.frame
        let x = windowFrame.origin.x + (windowFrame.width - modalFrame.width) / 2
        let y = windowFrame.origin.y + (windowFrame.height - modalFrame.height) / 2
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}

