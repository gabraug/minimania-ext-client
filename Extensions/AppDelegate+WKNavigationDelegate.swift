import Cocoa
import WebKit

extension AppDelegate: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            let urlString = url.absoluteString
            if urlString.hasPrefix("minimaniaapp://") || urlString.hasPrefix("minimaniaapp:") {
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url, url.absoluteString != "about:blank" {
            headerView?.urlLabel.stringValue = url.absoluteString
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let url = webView.url, url.absoluteString != "about:blank" {
            headerView?.urlLabel.stringValue = url.absoluteString
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url {
            let urlString = url.absoluteString
            if urlString != "about:blank" && !urlString.isEmpty {
                headerView?.urlLabel.stringValue = urlString
            } else {
                if let title = webView.title, !title.isEmpty {
                    headerView?.urlLabel.stringValue = "https://minimania.app/"
                }
            }
        }
        
        let script = jsInjectionService.injectPageLoadScript()
        jsInjectionService.evaluate(script)
        
        zoomManager.applyZoom()
        
        if autoReplyManager.config.isEnabled {
            autoReplyManager.injectObserver()
        }
        
        if userConfig.isMentionHighlightEnabled {
            mentionHighlighterManager.inject()
        }
        
        if autoFarmingManager.config.isAutoHarvestEnabled {
            autoFarmingManager.injectAutoHarvestObserver()
        }
        
        if autoFarmingManager.config.isAutoPlantEnabled {
            autoFarmingManager.injectAutoPlantObserver()
        }
        
        if chatHistoryManager.isEnabled {
            chatHistoryManager.injectObserver()
        }
    }
}

