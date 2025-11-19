import Cocoa
import WebKit

struct ChatMessage: Codable {
    let id: String
    let text: String
    let timestamp: Date
    
    init(text: String) {
        self.id = UUID().uuidString
        self.text = text
        self.timestamp = Date()
    }
}

class ChatHistoryManager {
    private var messages: [ChatMessage] = []
    private let maxMessages = 1000
    private let userDefaultsKey = "chatHistory"
    var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                injectObserver()
            } else {
                cleanupObserver()
            }
        }
    }
    
    private var jsService: JavaScriptInjectionService?
    
    var onMessageAdded: ((ChatMessage) -> Void)?
    
    init(jsService: JavaScriptInjectionService? = nil) {
        self.jsService = jsService
        loadMessages()
    }
    
    func setJavaScriptService(_ service: JavaScriptInjectionService) {
        self.jsService = service
        if isEnabled {
            injectObserver()
        }
    }
    
    func addMessage(_ text: String) {
        guard isEnabled else { 
            print("Chat history is disabled, message not saved: \(text)")
            return 
        }
        
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        print("Saving chat message: \(trimmedText)")
        
        let message = ChatMessage(text: trimmedText)
        messages.insert(message, at: 0)
        
        if messages.count > maxMessages {
            messages = Array(messages.prefix(maxMessages))
        }
        
        saveMessages()
        onMessageAdded?(message)
    }
    
    func getMessages(page: Int, pageSize: Int = 10) -> [ChatMessage] {
        let startIndex = page * pageSize
        let endIndex = min(startIndex + pageSize, messages.count)
        
        guard startIndex < messages.count else {
            return []
        }
        
        return Array(messages[startIndex..<endIndex])
    }
    
    func getTotalPages(pageSize: Int = 10) -> Int {
        return Int(ceil(Double(messages.count) / Double(pageSize)))
    }
    
    func clearHistory() {
        messages.removeAll()
        saveMessages()
    }
    
    func getTotalMessages() -> Int {
        return messages.count
    }
    
    func injectObserver() {
        guard let jsService = jsService else { 
            print("Chat history: Cannot inject observer - jsService is nil")
            return 
        }
        guard isEnabled else {
            print("Chat history: Cannot inject observer - history is disabled")
            return
        }
        print("Chat history: Injecting observer script...")
        let script = JavaScriptScripts.chatHistoryObserverScript()
        jsService.evaluate(script) { result, error in
            if let error = error {
                print("Error injecting chat history observer: \(error)")
            } else {
                print("Chat history: Observer script injected successfully")
            }
        }
    }
    
    func cleanupObserver() {
        guard let jsService = jsService else { return }
        let cleanupScript = """
        (function() {
            if (window.__chatHistoryObserver) {
                window.__chatHistoryObserver.disconnect();
                window.__chatHistoryObserver = null;
            }
            if (window.__chatHistoryInputObserver) {
                window.__chatHistoryInputObserver.disconnect();
                window.__chatHistoryInputObserver = null;
            }
            if (window.__chatHistoryProcessedMessages) {
                window.__chatHistoryProcessedMessages.clear();
            }
        })();
        """
        jsService.evaluate(cleanupScript, completionHandler: nil)
    }
    
    private func saveMessages() {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            messages = decoded
        }
    }
}

