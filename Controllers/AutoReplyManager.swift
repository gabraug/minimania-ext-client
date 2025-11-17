import Foundation
import WebKit

class AutoReplyManager {
    private let jsService: JavaScriptInjectionService
    var config: AutoReplyConfig
    
    weak var button: NSButton?
    
    init(jsService: JavaScriptInjectionService, config: AutoReplyConfig = AutoReplyConfig()) {
        self.jsService = jsService
        self.config = config
    }
    
    func toggle() {
        config.isEnabled.toggle()
        
        if config.isEnabled {
            if config.keyword.isEmpty || config.message.isEmpty {
                config.isEnabled = false
                updateButtonState()
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
        if config.isEnabled {
            button?.title = "Reply [ON]"
            button?.contentTintColor = .systemGreen
        } else {
            button?.title = "Reply [OFF]"
            button?.contentTintColor = .systemGray
        }
    }
}

