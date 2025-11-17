import Foundation
import WebKit

class AntiAfkManager {
    private var timer: Timer?
    private let jsService: JavaScriptInjectionService
    var isEnabled: Bool = true
    
    init(jsService: JavaScriptInjectionService) {
        self.jsService = jsService
    }
    
    func start() {
        guard isEnabled else { return }
        scheduleNextActivity()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func scheduleNextActivity() {
        guard isEnabled else { return }
        
        let interval = Double.random(in: 30.0...60.0)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self = self, self.isEnabled else { return }
            self.simulateActivity()
            self.scheduleNextActivity()
        }
        
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func simulateActivity() {
        let script = jsService.injectAntiAfkScript()
        jsService.evaluate(script)
    }
}

