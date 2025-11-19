import Cocoa

class MessageModal {
    var modal: Modal!
    var textField: TextInput!
    var intervalField: TextInput!
    var toggle: Toggle!
    weak var parentWindow: NSWindow?
    var onSave: ((String, Double, Bool) -> Void)?
    
    func create(parentWindow: NSWindow) {
        self.parentWindow = parentWindow
        
        modal = Modal(title: "Automatic Message Configuration", width: 560, height: 380, parent: parentWindow)
        
        textField = TextInput(placeholder: "Enter the message to send automatically...", style: .multiline)
        let messageFieldWrapper = FormField(
            label: "Message Content",
            control: textField,
            helperText: "This message will be sent periodically to the chat"
        )
        
        intervalField = TextInput(placeholder: "5", style: .numeric)
        let intervalRow = Row([
            intervalField,
            Text("seconds", style: .helper)
        ], spacing: 8, alignment: .centerY)
        
        let intervalFieldWrapper = FormField(
            label: "Sending Interval",
            control: intervalRow,
            helperText: "Minimum interval is 5 seconds"
        )
        
        toggle = Toggle(
            label: "Enable Auto Message",
            isOn: false,
            toolTip: "Toggle automatic message sending on or off",
            onChange: nil
        )
        
        modal.addSection([messageFieldWrapper], spacing: 20)
        modal.addSeparator(topPadding: 20, bottomPadding: 20)
        modal.addSection([intervalFieldWrapper, toggle], spacing: 20)
        modal.addSeparator(topPadding: 20, bottomPadding: 20)
        
        let cancelButton = Button(title: "Cancel", style: .secondary) { [weak self] in
            self?.close()
        }
        
        let saveButton = Button(title: "Save", style: .primary) { [weak self] in
            self?.save()
        }
        
        modal.addButtonRow([cancelButton, saveButton], spacing: 16)
    }
    
    func show(with text: String, interval: Double, isEnabled: Bool) {
        if modal == nil {
            guard let parent = parentWindow else { return }
            create(parentWindow: parent)
        }
        
        textField.stringValue = text
        intervalField.stringValue = String(format: "%.0f", interval)
        toggle.isOn = isEnabled
        modal.show()
    }
    
    @objc private func save() {
        let text = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        var interval = Double(intervalField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 5.0
        
        if interval < 5.0 {
            interval = 5.0
            intervalField.stringValue = "5"
            
            let alert = NSAlert()
            alert.messageText = "Invalid Interval Value"
            alert.informativeText = "The minimum sending interval is 5 seconds. The value has been automatically adjusted to the minimum."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }
        
        let isEnabled = toggle.isOn
        onSave?(text, interval, isEnabled)
        close()
    }
    
    @objc private func close() {
        modal.dismiss()
    }
}

