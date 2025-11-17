import Cocoa
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate, HeaderViewDelegate {
    
    var window: NSWindow!
    var webView: WKWebView!
    var headerView: HeaderView!
    
    var jsInjectionService: JavaScriptInjectionService!
    var playersCountService: PlayersCountService!
    
    var antiAfkManager: AntiAfkManager!
    var zoomManager: ZoomManager!
    var autoMessageManager: AutoMessageManager!
    var autoReplyManager: AutoReplyManager!
    var autoFarmingManager: AutoFarmingManager!
    var mentionHighlighterManager: MentionHighlighterManager!
    
    var userConfig = UserConfig()
    
    var messageModal: MessageModal!
    var autoReplyModal: AutoReplyModal!
    var autoFarmingModal: AutoFarmingModal!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupWindow()
        setupWebView()
        setupServices()
        setupManagers()
        setupModals()
        setupHeader()
        loadInitialPage()
        initializeFeatures()
        
        window.makeKeyAndOrderFront(nil)
    }
    
    private func setupWindow() {
        let windowRect = NSRect(x: 0, y: 0, width: 1280, height: 720)
        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "MiniMania"
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.minSize = NSSize(width: 800, height: 600)
    }
    
    private func setupWebView() {
        let containerView = NSView(frame: window.contentView!.bounds)
        containerView.autoresizingMask = [.width, .height]
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = false
        webConfiguration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "urlChange")
        webConfiguration.userContentController = contentController
        
        let headerHeight: CGFloat = 40
        let webViewFrame = NSRect(
            x: 0,
            y: 0,
            width: containerView.bounds.width,
            height: containerView.bounds.height - headerHeight
        )
        
        webView = WKWebView(frame: webViewFrame, configuration: webConfiguration)
        webView.autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        webView.addObserver(self, forKeyPath: "URL", options: [.new], context: nil)
        
        containerView.addSubview(webView)
        window.contentView = containerView
    }
    
    private func setupServices() {
        jsInjectionService = JavaScriptInjectionService(webView: webView)
        playersCountService = PlayersCountService()
    }
    
    private func setupManagers() {
        antiAfkManager = AntiAfkManager(jsService: jsInjectionService)
        zoomManager = ZoomManager(jsService: jsInjectionService)
        autoMessageManager = AutoMessageManager(jsService: jsInjectionService)
        autoReplyManager = AutoReplyManager(jsService: jsInjectionService)
        autoFarmingManager = AutoFarmingManager(jsService: jsInjectionService)
        mentionHighlighterManager = MentionHighlighterManager(jsService: jsInjectionService, config: userConfig)
    }
    
    private func setupModals() {
        messageModal = MessageModal()
        messageModal.parentWindow = window
        messageModal.onSave = { [weak self] text in
            self?.autoMessageManager.config.text = text
        }
        
        autoReplyModal = AutoReplyModal()
        autoReplyModal.parentWindow = window
        autoReplyModal.onSave = { [weak self] keyword, message in
            self?.autoReplyManager.config.keyword = keyword
            self?.autoReplyManager.config.message = message
            if self?.autoReplyManager.config.isEnabled == true {
                self?.autoReplyManager.injectObserver()
            }
        }
        
        autoFarmingModal = AutoFarmingModal()
        autoFarmingModal.parentWindow = window
        autoFarmingModal.onToggleHarvest = { [weak self] in
            self?.autoFarmingManager.toggleAutoHarvest()
        }
        autoFarmingModal.onTogglePlant = { [weak self] in
            self?.autoFarmingManager.toggleAutoPlant()
        }
        autoFarmingModal.onSeedNameChanged = { [weak self] seedName in
            guard let self else { return }
            self.autoFarmingManager.config.seedName = seedName
            if self.autoFarmingManager.config.isAutoPlantEnabled {
                self.autoFarmingManager.injectAutoPlantObserver()
            }
        }
        autoFarmingModal.onSourceChanged = { [weak self] useBuyPlants in
            guard let self else { return }
            self.autoFarmingManager.config.useBuyPlants = useBuyPlants
            if self.autoFarmingManager.config.isAutoPlantEnabled {
                self.autoFarmingManager.injectAutoPlantObserver()
            }
        }
    }
    
    private func setupHeader() {
        headerView = HeaderView()
        headerView.setup(in: window.contentView!, target: self)
        
        zoomManager.resetButton = headerView.zoomResetButton
        autoMessageManager.button = headerView.autoMessageButton
        autoReplyManager.button = headerView.autoReplyButton
        autoFarmingManager.harvestButton = autoFarmingModal.autoHarvestButton
        autoFarmingManager.plantButton = autoFarmingModal.autoPlantButton
    }
    
    private func loadInitialPage() {
        if let url = URL(string: "https://minimania.app/") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    private func initializeFeatures() {
        playersCountService.startUpdating(label: headerView.playersCountLabel)
        
        antiAfkManager.isEnabled = true
        antiAfkManager.start()
        updateAntiAfkButtonState()
        
        autoMessageManager.updateButtonState()
        autoReplyManager.updateButtonState()
        
        zoomManager.applyZoom()
    }
    
    @objc func refreshPage() {
        webView.reload()
        playersCountService.updatePlayersCount()
    }
    
    @objc func zoomIn() {
        zoomManager.zoomIn()
    }
    
    @objc func zoomOut() {
        zoomManager.zoomOut()
    }
    
    @objc func zoomReset() {
        zoomManager.reset()
    }
    
    @objc func toggleAntiAfk() {
        antiAfkManager.isEnabled.toggle()
        if antiAfkManager.isEnabled {
            antiAfkManager.start()
        } else {
            antiAfkManager.stop()
        }
        updateAntiAfkButtonState()
    }
    
    @objc func openMessageModal() {
        messageModal.show(with: autoMessageManager.config.text)
    }
    
    @objc func openAutoReplyModal() {
        autoReplyModal.show(keyword: autoReplyManager.config.keyword, message: autoReplyManager.config.message)
    }
    
    @objc func openAutoPlantacaoModal() {
        autoFarmingModal.show(seedName: autoFarmingManager.config.seedName, useBuyPlants: autoFarmingManager.config.useBuyPlants)
    }
    
    @objc func toggleAutoMessage() {
        autoMessageManager.toggle()
    }
    
    @objc func toggleAutoReply() {
        autoReplyManager.toggle()
        if autoReplyManager.config.isEnabled && (autoReplyManager.config.keyword.isEmpty || autoReplyManager.config.message.isEmpty) {
            openAutoReplyModal()
        }
    }
    
    @objc func intervalFieldChanged() {
        if let interval = Double(headerView.autoMessageIntervalField.stringValue), interval >= 5.0 {
            autoMessageManager.config.interval = interval
        } else {
            autoMessageManager.config.interval = 5.0
            headerView.autoMessageIntervalField.stringValue = "5"
        }
        
        if autoMessageManager.config.isEnabled {
            autoMessageManager.startTimer()
        }
    }
    
    private func updateAntiAfkButtonState() {
        if antiAfkManager.isEnabled {
            headerView.antiAfkButton.title = "Anti-AFK [ON]"
            headerView.antiAfkButton.contentTintColor = .systemGreen
        } else {
            headerView.antiAfkButton.title = "Anti-AFK [OFF]"
            headerView.antiAfkButton.contentTintColor = .systemGray
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "URL" {
            if let url = webView.url, url.absoluteString != "about:blank" {
                headerView.urlLabel.stringValue = url.absoluteString
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        playersCountService.stopUpdating()
        antiAfkManager.stop()
        autoMessageManager.stopTimer()
        if autoFarmingManager.config.isAutoHarvestEnabled {
            autoFarmingManager.toggleAutoHarvest()
        }
        webView.removeObserver(self, forKeyPath: "URL")
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
