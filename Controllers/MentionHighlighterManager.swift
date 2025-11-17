import Foundation
import WebKit

class MentionHighlighterManager {
    private let jsService: JavaScriptInjectionService
    var config: UserConfig
    
    init(jsService: JavaScriptInjectionService, config: UserConfig) {
        self.jsService = jsService
        self.config = config
    }
    
    func inject() {
        guard config.isMentionHighlightEnabled && !config.firstName.isEmpty && !config.lastName.isEmpty else { return }
        
        let script = JavaScriptScripts.mentionHighlighterScript(firstName: config.firstName, lastName: config.lastName)
        jsService.evaluate(script) { result, error in
            if let error = error {
                print("Error injecting mention highlight system: \(error)")
            }
        }
    }
}

