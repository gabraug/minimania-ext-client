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
        }
    }
}

