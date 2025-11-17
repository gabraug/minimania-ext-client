import Foundation
import WebKit

class AutoFarmingManager {
    private var harvestTimer: Timer?
    private let jsService: JavaScriptInjectionService
    var config: AutoFarmingConfig
    
    weak var harvestButton: NSButton?
    weak var plantButton: NSButton?
    
    init(jsService: JavaScriptInjectionService, config: AutoFarmingConfig = AutoFarmingConfig()) {
        self.jsService = jsService
        self.config = config
    }
    
    func toggleAutoHarvest() {
        config.isAutoHarvestEnabled.toggle()
        
        if config.isAutoHarvestEnabled {
            startAutoHarvest()
        } else {
            stopAutoHarvest()
        }
        
        updateHarvestButtonState()
    }
    
    func toggleAutoPlant() {
        config.isAutoPlantEnabled.toggle()
        
        if config.isAutoPlantEnabled {
            if config.seedName.isEmpty {
                config.isAutoPlantEnabled = false
                updatePlantButtonState()
                return
            }
            
            injectAutoPlantObserver()
        } else {
            cleanupAutoPlant()
        }
        
        updatePlantButtonState()
    }
    
    private func startAutoHarvest() {
        harvestTimer?.invalidate()
        injectAutoHarvestObserver()
        
        harvestTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let self = self, self.config.isAutoHarvestEnabled else {
                timer.invalidate()
                return
            }
            
            self.performAutoHarvest()
        }
        
        RunLoop.current.add(harvestTimer!, forMode: .common)
        performAutoHarvest()
    }
    
    private func stopAutoHarvest() {
        harvestTimer?.invalidate()
        harvestTimer = nil
    }
    
    private func performAutoHarvest() {
        let script = """
        (function() {
            function clickHarvest() {
                const contextualMenu = document.querySelector('.ContextualMenu_container__piX5c');
                if (!contextualMenu) {
                    return false;
                }
                
                const menuItems = contextualMenu.querySelectorAll('.ContextualMenu_item__milvQ');
                for (let item of menuItems) {
                    const textElement = item.querySelector('.ContextualMenu_text__GVy-f');
                    if (textElement && textElement.textContent.trim() === 'Harvest') {
                        if (!item.dataset.harvestClicked) {
                            item.dataset.harvestClicked = 'true';
                            item.click();
                            return true;
                        }
                    }
                }
                return false;
            }
            
            if (clickHarvest()) {
                return true;
            }
            
            return false;
        })();
        """
        
        jsService.evaluate(script) { result, error in
            if let error = error {
                print("Error executing automatic harvest: \(error)")
            }
        }
    }
    
    func injectAutoHarvestObserver() {
        guard config.isAutoHarvestEnabled else { return }
        
        let script = JavaScriptScripts.autoHarvestScript()
        jsService.evaluate(script) { result, error in
            if let error = error {
                print("Error injecting automatic harvest observer: \(error)")
            }
        }
    }
    
    func injectAutoPlantObserver() {
        guard config.isAutoPlantEnabled && !config.seedName.isEmpty else { return }
        
        let script = JavaScriptScripts.autoPlantScript(seedName: config.seedName, useBuyPlants: config.useBuyPlants)
        jsService.evaluate(script) { result, error in
            if let error = error {
                print("Error injecting automatic planting observer: \(error)")
            }
        }
    }
    
    private func cleanupAutoPlant() {
        let cleanupScript = """
        (function() {
            if (window.__autoPlantObserver) {
                window.__autoPlantObserver.disconnect();
                window.__autoPlantObserver = null;
            }
            if (window.__autoPlantTendInterval) {
                clearInterval(window.__autoPlantTendInterval);
                window.__autoPlantTendInterval = null;
            }
        })();
        """
        jsService.evaluate(cleanupScript, completionHandler: nil)
    }
    
    func updateHarvestButtonState() {
        if config.isAutoHarvestEnabled {
            harvestButton?.title = "Auto Harvest [ON]"
            harvestButton?.contentTintColor = .systemGreen
        } else {
            harvestButton?.title = "Auto Harvest [OFF]"
            harvestButton?.contentTintColor = .systemGray
        }
    }
    
    func updatePlantButtonState() {
        if config.isAutoPlantEnabled {
            plantButton?.title = "Auto Plant [ON]"
            plantButton?.contentTintColor = .systemGreen
        } else {
            plantButton?.title = "Auto Plant [OFF]"
            plantButton?.contentTintColor = .systemGray
        }
    }
}

