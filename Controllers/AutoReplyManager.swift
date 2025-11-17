import Foundation
import WebKit

class AutoReplyManager {
    private let jsService: JavaScriptInjectionService
    var config: AutoReplyConfig
    var onMissingConfiguration: (() -> Void)?
    
    weak var button: NSButton?
    
    init(jsService: JavaScriptInjectionService, config: AutoReplyConfig = AutoReplyConfig()) {
        self.jsService = jsService
        self.config = config
    }
    
    func toggle() {
        config.isEnabled.toggle()
        
        if config.isEnabled {
            if config.keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                config.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                config.isEnabled = false
                updateButtonState()
                onMissingConfiguration?()
                return
            }
            
            injectObserver()
        }
        
        updateButtonState()
    }
    
    func injectObserver() {
        guard config.isEnabled && !config.keyword.isEmpty && !config.message.isEmpty else { return }
        
        let script = JavaScriptScripts.autoReplyScript(keyword: config.keyword, message: config.message)
        jsService.evaluate(script) { result, error in
            if let error = error {
                print("Error injecting auto-reply observer: \(error)")
            }
        }
    }
    
    func updateButtonState() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.config.isEnabled {
                self.button?.title = "Reply [ON]"
                self.button?.contentTintColor = .systemGreen
            } else {
                self.button?.title = "Reply [OFF]"
                self.button?.contentTintColor = .systemGray
            }
        }
    }
}

