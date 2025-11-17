import Foundation
import WebKit

class JavaScriptInjectionService {
    weak var webView: WKWebView?
    
    init(webView: WKWebView) {
        self.webView = webView
    }
    
    func injectAntiAfkScript() -> String {
        return """
        (function() {
            const width = window.innerWidth || document.documentElement.clientWidth;
            const height = window.innerHeight || document.documentElement.clientHeight;
            
            const x = Math.floor(Math.random() * (width - 200)) + 100;
            const y = Math.floor(Math.random() * (height - 200)) + 100;
            
            const mouseMoveEvent = new MouseEvent('mousemove', {
                view: window,
                bubbles: true,
                cancelable: true,
                clientX: x,
                clientY: y,
                screenX: x,
                screenY: y,
                buttons: 0,
                relatedTarget: null
            });
            
            document.dispatchEvent(mouseMoveEvent);
            if (document.body) {
                document.body.dispatchEvent(mouseMoveEvent);
            }
            
            const canvas = document.querySelector('canvas');
            const target = canvas || document.body || document.documentElement;
            
            setTimeout(function() {
                if (canvas) {
                    const mouseEnterEvent = new MouseEvent('mouseenter', {
                        view: window,
                        bubbles: true,
                        cancelable: true,
                        clientX: x,
                        clientY: y
                    });
                    canvas.dispatchEvent(mouseEnterEvent);
                }
                
                const mouseOverEvent = new MouseEvent('mouseover', {
                    view: window,
                    bubbles: true,
                    cancelable: true,
                    clientX: x,
                    clientY: y
                });
                target.dispatchEvent(mouseOverEvent);
                
                const mouseDownEvent = new MouseEvent('mousedown', {
                    view: window,
                    bubbles: true,
                    cancelable: true,
                    clientX: x,
                    clientY: y,
                    button: 0,
                    buttons: 1,
                    detail: 1
                });
                target.dispatchEvent(mouseDownEvent);
                
                setTimeout(function() {
                    const mouseUpEvent = new MouseEvent('mouseup', {
                        view: window,
                        bubbles: true,
                        cancelable: true,
                        clientX: x,
                        clientY: y,
                        button: 0,
                        buttons: 0,
                        detail: 1
                    });
                    target.dispatchEvent(mouseUpEvent);
                }, 5);
            }, 50);
            
            window.dispatchEvent(new Event('focus'));
            window.dispatchEvent(new Event('blur'));
            window.dispatchEvent(new Event('focus'));
            
            const visibilityEvent = new Event('visibilitychange');
            document.dispatchEvent(visibilityEvent);
            
            if (typeof document.lastModified !== 'undefined') {
                try {
                    const _ = document.activeElement;
                    const __ = window.focus;
                } catch(e) {}
            }
            
            if (typeof navigator !== 'undefined' && navigator.userActivation) {
                try {
                    window.dispatchEvent(new Event('userinteraction'));
                } catch(e) {}
            }
        })();
        """
    }
    
    func injectZoomScript(level: Double) -> String {
        return """
        (function() {
            document.body.style.zoom = \(level);
        })();
        """
    }
    
    func injectPageLoadScript() -> String {
        return """
        (function() {
            function notifyURLChange() {
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.urlChange) {
                    window.webkit.messageHandlers.urlChange.postMessage(window.location.href);
                }
            }
            
            const originalPushState = history.pushState;
            const originalReplaceState = history.replaceState;
            
            history.pushState = function() {
                originalPushState.apply(history, arguments);
                setTimeout(notifyURLChange, 0);
            };
            
            history.replaceState = function() {
                originalReplaceState.apply(history, arguments);
                setTimeout(notifyURLChange, 0);
            };
            
            window.addEventListener('popstate', function() {
                setTimeout(notifyURLChange, 0);
            });
            
            window.addEventListener('hashchange', function() {
                setTimeout(notifyURLChange, 0);
            });
            
            const originalAssign = window.location.assign.bind(window.location);
            const originalReplace = window.location.replace.bind(window.location);
            
            window.location.assign = function(url) {
                if (typeof url === 'string' && (url.startsWith('minimaniaapp://') || url.startsWith('minimaniaapp:'))) {
                    return;
                }
                const result = originalAssign(url);
                setTimeout(notifyURLChange, 0);
                return result;
            };
            
            window.location.replace = function(url) {
                if (typeof url === 'string' && (url.startsWith('minimaniaapp://') || url.startsWith('minimaniaapp:'))) {
                    return;
                }
                const result = originalReplace(url);
                setTimeout(notifyURLChange, 0);
                return result;
            };
            
            const originalLog = console.log;
            console.log = function(...args) {
                const message = args.join(' ');
                if (message.includes('Trying to redirect to minimaniaapp://')) {
                    return;
                }
                return originalLog.apply(console, args);
            };
            
            function initCanvas() {
                const canvases = document.querySelectorAll('canvas');
                canvases.forEach(canvas => {
                    canvas.style.display = 'block';
                    canvas.style.visibility = 'visible';
                    canvas.style.opacity = '1';
                    
                    try {
                        const ctx = canvas.getContext('webgl2') || canvas.getContext('webgl');
                        if (ctx) {
                            ctx.clearColor(0.0, 0.0, 0.0, 1.0);
                            ctx.clear(ctx.COLOR_BUFFER_BIT);
                        }
                    } catch(e) {}
                });
                
                window.dispatchEvent(new Event('resize'));
            }
            
            [50, 150, 300, 500, 1000, 2000, 3000].forEach(delay => {
                setTimeout(initCanvas, delay);
            });
            
            const observer = new MutationObserver(function(mutations) {
                mutations.forEach(function(mutation) {
                    mutation.addedNodes.forEach(function(node) {
                        if (node.nodeType === 1 && node.tagName === 'CANVAS') {
                            setTimeout(function() {
                                const canvas = node;
                                canvas.style.display = 'block';
                                canvas.style.visibility = 'visible';
                                canvas.style.opacity = '1';
                            }, 100);
                        }
                    });
                });
            });
            
            observer.observe(document.body || document.documentElement, {
                childList: true,
                subtree: true
            });
        })();
        """
    }
    
    func evaluate(_ script: String, completionHandler: ((Any?, Error?) -> Void)? = nil) {
        webView?.evaluateJavaScript(script, completionHandler: completionHandler)
    }
}

