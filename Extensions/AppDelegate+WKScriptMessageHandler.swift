import Cocoa
import WebKit

extension AppDelegate: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "urlChange", let urlString = message.body as? String {
            DispatchQueue.main.async {
                if urlString != "about:blank" && !urlString.isEmpty {
                    self.headerView?.urlLabel.stringValue = urlString
                }
            }
        } else if message.name == "chatMessage" {
            print("Received chat message from JavaScript: \(message.body)")
            if let messageData = message.body as? [String: Any], let text = messageData["text"] as? String {
                DispatchQueue.main.async {
                    print("Adding message to history: \(text)")
                    self.chatHistoryManager.addMessage(text)
                }
            } else if let text = message.body as? String {
                DispatchQueue.main.async {
                    print("Adding message to history (string): \(text)")
                    self.chatHistoryManager.addMessage(text)
                }
            }
        }
    }
}

