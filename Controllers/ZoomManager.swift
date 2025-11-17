import Foundation
import WebKit

class ZoomManager {
    private let jsService: JavaScriptInjectionService
    var config: ZoomConfig
    
    weak var resetButton: NSButton?
    
    init(jsService: JavaScriptInjectionService, config: ZoomConfig = ZoomConfig()) {
        self.jsService = jsService
        self.config = config
    }
    
    func zoomIn() {
        config.currentLevel = min(config.currentLevel + config.step, config.maxLevel)
        applyZoom()
    }
    
    func zoomOut() {
        config.currentLevel = max(config.currentLevel - config.step, config.minLevel)
        applyZoom()
    }
    
    func reset() {
        config.currentLevel = 1.0
        applyZoom()
    }
    
    func applyZoom() {
        let zoomPercent = Int(config.currentLevel * 100)
        resetButton?.title = "\(zoomPercent)%"
        
        let script = jsService.injectZoomScript(level: config.currentLevel)
        jsService.evaluate(script)
    }
}

