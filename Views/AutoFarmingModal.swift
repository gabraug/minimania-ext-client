import Cocoa

class AutoFarmingModal {
    var modal: Modal!
    var seedNameField: TextInput!
    var sourceSegmentedControl: NSSegmentedControl!
    var harvestToggle: Toggle!
    var plantToggle: Toggle!
    weak var parentWindow: NSWindow?
    
    var onToggleHarvest: (() -> Void)?
    var onTogglePlant: (() -> Void)?
    var onSeedNameChanged: ((String) -> Void)?
    var onSourceChanged: ((Bool) -> Void)?
    var onClose: (() -> Void)?
    
    func create(parentWindow: NSWindow) {
        self.parentWindow = parentWindow
        
        modal = Modal(title: "Automatic Farming Configuration", width: 580, height: 480, parent: parentWindow)
        
        harvestToggle = Toggle(
            label: "Automatic Harvesting",
            isOn: false,
            toolTip: "Enable or disable automatic plant harvesting",
            onChange: { [weak self] _ in
                self?.onToggleHarvest?()
            }
        )
        
        sourceSegmentedControl = NSSegmentedControl(labels: ["Buy Plants", "My Stock"], trackingMode: .selectOne, target: self, action: #selector(sourceChanged))
        sourceSegmentedControl.selectedSegment = 0
        sourceSegmentedControl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        sourceSegmentedControl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        sourceSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        sourceSegmentedControl.segmentDistribution = .fillEqually
        
        let seedSourceField = FormField(
            label: "Seed Source",
            control: sourceSegmentedControl,
            helperText: "Choose whether to buy plants or use seeds from your inventory"
        )
        
        seedNameField = TextInput(placeholder: "Example: Alienina Seed", onChange: { [weak self] text in
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.onSeedNameChanged?(trimmedText)
        })
        
        let seedNameFieldWrapper = FormField(
            label: "Seed Name",
            control: seedNameField,
            helperText: "The exact name of the seed to plant automatically"
        )
        
        plantToggle = Toggle(
            label: "Automatic Planting",
            isOn: false,
            toolTip: "Enable or disable automatic seed planting",
            onChange: { [weak self] _ in
                self?.onTogglePlant?()
            }
        )
        
        modal.addSection([seedSourceField, seedNameFieldWrapper], spacing: 20)
        modal.addSeparator(topPadding: 20, bottomPadding: 20)
        modal.addSection([plantToggle], spacing: 20)
        modal.addSeparator(topPadding: 20, bottomPadding: 20)
        modal.addSection([harvestToggle], spacing: 20)
        modal.addSeparator(topPadding: 20, bottomPadding: 20)
        
        let closeButton = Button(title: "Close", style: .primary) { [weak self] in
            self?.close()
        }
        
        modal.addButtonRow([closeButton], spacing: 16, distribution: .fill)
    }
    
    func show(seedName: String, useBuyPlants: Bool) {
        if modal == nil {
            guard let parent = parentWindow else { return }
            create(parentWindow: parent)
        }
        
        seedNameField.stringValue = seedName
        sourceSegmentedControl.selectedSegment = useBuyPlants ? 0 : 1
        modal.show()
    }
    
    
    @objc private func sourceChanged() {
        let useBuyPlants = (sourceSegmentedControl.selectedSegment == 0)
        onSourceChanged?(useBuyPlants)
    }
    
    @objc private func close() {
        onClose?()
        modal.dismiss()
    }
    
    var autoHarvestButton: NSButton! {
        get { harvestToggle?.toggleButton }
        set { }
    }
    
    var autoPlantButton: NSButton! {
        get { plantToggle?.toggleButton }
        set { }
    }
}

