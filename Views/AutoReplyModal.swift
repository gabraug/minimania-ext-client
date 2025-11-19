import Cocoa

class AutoReplyModal {
    var modal: Modal!
    var keywordField: TextInput!
    var messageField: TextInput!
    var toggle: Toggle!
    weak var parentWindow: NSWindow?
    var onSave: ((String, String, Bool) -> Void)?
    
    func create(parentWindow: NSWindow) {
        self.parentWindow = parentWindow
        
        modal = Modal(title: "Automatic Reply Configuration", width: 560, height: 400, parent: parentWindow)
        
        keywordField = TextInput(placeholder: "Enter the trigger keyword...")
        let keywordFieldWrapper = FormField(
            label: "Trigger Keyword",
            control: keywordField,
            helperText: "The keyword that will trigger an automatic reply when detected in chat"
        )
        
        messageField = TextInput(placeholder: "Enter the reply message...", style: .multiline)
        let messageFieldWrapper = FormField(
            label: "Reply Message",
            control: messageField,
            helperText: "The message that will be sent automatically when the keyword is detected"
        )
        
        toggle = Toggle(
            label: "Enable Auto-Reply",
            isOn: false,
            toolTip: "Toggle automatic reply system on or off",
            onChange: nil
        )
        
        modal.addSection([keywordFieldWrapper, messageFieldWrapper], spacing: 20)
        modal.addSeparator(topPadding: 20, bottomPadding: 20)
        modal.addSection([toggle], spacing: 20)
        modal.addSeparator(topPadding: 20, bottomPadding: 20)
        
        let cancelButton = Button(title: "Cancel", style: .secondary) { [weak self] in
            self?.close()
        }
        
        let saveButton = Button(title: "Save", style: .primary) { [weak self] in
            self?.save()
        }
        
        modal.addButtonRow([cancelButton, saveButton], spacing: 16)
    }
    
    func show(keyword: String, message: String, isEnabled: Bool) {
        if modal == nil {
            guard let parent = parentWindow else { return }
            create(parentWindow: parent)
        }
        
        keywordField.stringValue = keyword
        messageField.stringValue = message
        toggle.isOn = isEnabled
        modal.show()
    }
    
    @objc private func save() {
        let keyword = keywordField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let message = messageField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEnabled = toggle.isOn
        onSave?(keyword, message, isEnabled)
        close()
    }
    
    @objc private func close() {
        modal.dismiss()
    }
}

