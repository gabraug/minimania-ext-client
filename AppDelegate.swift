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
    var chatHistoryManager: ChatHistoryManager!
    
    var userConfig = UserConfig()
    
    var messageModal: MessageModal!
    var autoReplyModal: AutoReplyModal!
    var autoFarmingModal: AutoFarmingModal!
    var chatHistoryModal: ChatHistoryModal!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupWindow()
        setupWebView()
        setupApplicationIcon()
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
        contentController.add(self, name: "chatMessage")
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
        chatHistoryManager = ChatHistoryManager(jsService: jsInjectionService)
        chatHistoryManager.onMessageAdded = { [weak self] message in
            if let modal = self?.chatHistoryModal, modal.modal?.isVisible == true {
                let currentPage = modal.getCurrentPage()
                let messages = self?.chatHistoryManager.getMessages(page: currentPage, pageSize: 10) ?? []
                modal.updateMessages(messages: messages)
                let totalPages = self?.chatHistoryManager.getTotalPages(pageSize: 10) ?? 0
                let totalMessages = self?.chatHistoryManager.getTotalMessages() ?? 0
                modal.show(
                    isEnabled: self?.chatHistoryManager.isEnabled ?? false,
                    messages: messages,
                    currentPage: currentPage,
                    totalPages: totalPages,
                    totalMessages: totalMessages
                )
            }
        }
        
        antiAfkManager = AntiAfkManager(jsService: jsInjectionService)
        zoomManager = ZoomManager(jsService: jsInjectionService)
        autoMessageManager = AutoMessageManager(jsService: jsInjectionService)
        autoMessageManager.onMissingMessage = { [weak self] in
            self?.presentMissingAutoMessageAlert()
        }
        autoReplyManager = AutoReplyManager(jsService: jsInjectionService)
        autoReplyManager.onMissingConfiguration = { [weak self] in
            self?.presentMissingAutoReplyAlert()
        }
        autoFarmingManager = AutoFarmingManager(jsService: jsInjectionService)
        autoFarmingManager.onHarvestStateChanged = { isEnabled in
            let alert = NSAlert()
            if isEnabled {
                alert.messageText = "Auto Harvest Enabled"
                alert.informativeText = "Automatic plant harvesting has been enabled successfully."
            } else {
                alert.messageText = "Auto Harvest Disabled"
                alert.informativeText = "Automatic plant harvesting has been disabled."
            }
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        autoFarmingManager.onPlantStateChanged = { isEnabled in
            let alert = NSAlert()
            if isEnabled {
                alert.messageText = "Auto Plant Enabled"
                alert.informativeText = "Automatic planting has been enabled successfully."
            } else {
                alert.messageText = "Auto Plant Disabled"
                alert.informativeText = "Automatic planting has been disabled."
            }
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        mentionHighlighterManager = MentionHighlighterManager(jsService: jsInjectionService, config: userConfig)
    }
    
    private func setupModals() {
        messageModal = MessageModal()
        messageModal.parentWindow = window
        messageModal.create(parentWindow: window)
        messageModal.onSave = { [weak self] text, interval, isEnabled in
            guard let self = self else { return }
            self.autoMessageManager.config.text = text
            self.autoMessageManager.config.interval = interval
            let wasEnabled = self.autoMessageManager.config.isEnabled
            self.autoMessageManager.config.isEnabled = isEnabled
            
            if isEnabled && !wasEnabled {
                self.autoMessageManager.toggle()
            } else if !isEnabled && wasEnabled {
                self.autoMessageManager.toggle()
            } else if isEnabled {
                self.autoMessageManager.startTimer()
            }
            
            self.autoMessageManager.updateButtonState()
            
            if isEnabled != wasEnabled {
                let alert = NSAlert()
                if isEnabled {
                    alert.messageText = "Auto Message Enabled"
                    alert.informativeText = "Automatic message sending has been enabled successfully."
                } else {
                    alert.messageText = "Auto Message Disabled"
                    alert.informativeText = "Automatic message sending has been disabled."
                }
                alert.alertStyle = .informational
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
        
        autoReplyModal = AutoReplyModal()
        autoReplyModal.parentWindow = window
        autoReplyModal.create(parentWindow: window)
        autoReplyModal.onSave = { [weak self] keyword, message, isEnabled in
            guard let self = self else { return }
            self.autoReplyManager.config.keyword = keyword
            self.autoReplyManager.config.message = message
            let wasEnabled = self.autoReplyManager.config.isEnabled
            self.autoReplyManager.config.isEnabled = isEnabled
            
            if isEnabled && !wasEnabled {
                self.autoReplyManager.toggle()
            } else if !isEnabled && wasEnabled {
                self.autoReplyManager.toggle()
            } else if isEnabled {
                self.autoReplyManager.injectObserver()
            }
            
            self.autoReplyManager.updateButtonState()
            
            if isEnabled != wasEnabled {
                let alert = NSAlert()
                if isEnabled {
                    alert.messageText = "Auto-Reply Enabled"
                    alert.informativeText = "Automatic reply system has been enabled successfully."
                } else {
                    alert.messageText = "Auto-Reply Disabled"
                    alert.informativeText = "Automatic reply system has been disabled."
                }
                alert.alertStyle = .informational
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
        }
        
        autoFarmingModal = AutoFarmingModal()
        autoFarmingModal.parentWindow = window
        autoFarmingModal.create(parentWindow: window)
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
        
        chatHistoryModal = ChatHistoryModal()
        chatHistoryModal.parentWindow = window
        chatHistoryModal.create(parentWindow: window)
        chatHistoryModal.onToggle = { [weak self] isEnabled in
            guard let self = self else { return }
            self.chatHistoryManager.isEnabled = isEnabled
            if isEnabled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.chatHistoryManager.injectObserver()
                }
            }
            let alert = NSAlert()
            if isEnabled {
                alert.messageText = "Chat History Enabled"
                alert.informativeText = "Chat history recording has been enabled."
            } else {
                alert.messageText = "Chat History Disabled"
                alert.informativeText = "Chat history recording has been disabled."
            }
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        chatHistoryModal.onClearHistory = { [weak self] in
            self?.chatHistoryManager.clearHistory()
            let currentPage = 0
            let messages = self?.chatHistoryManager.getMessages(page: currentPage, pageSize: 10) ?? []
            let totalPages = self?.chatHistoryManager.getTotalPages(pageSize: 10) ?? 0
            let totalMessages = self?.chatHistoryManager.getTotalMessages() ?? 0
            self?.chatHistoryModal.show(
                isEnabled: self?.chatHistoryManager.isEnabled ?? false,
                messages: messages,
                currentPage: currentPage,
                totalPages: totalPages,
                totalMessages: totalMessages
            )
        }
        chatHistoryModal.onPageChanged = { [weak self] in
            guard let self = self else { return }
            let currentPage = self.chatHistoryModal.getCurrentPage()
            let messages = self.chatHistoryManager.getMessages(page: currentPage, pageSize: 10)
            let totalPages = self.chatHistoryManager.getTotalPages(pageSize: 10)
            let totalMessages = self.chatHistoryManager.getTotalMessages()
            self.chatHistoryModal.show(
                isEnabled: self.chatHistoryManager.isEnabled,
                messages: messages,
                currentPage: currentPage,
                totalPages: totalPages,
                totalMessages: totalMessages
            )
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
    
    private func setupApplicationIcon() {
        if let iconPath = Bundle.main.path(forResource: "AppIcon", ofType: "icns"),
           let iconImage = NSImage(contentsOfFile: iconPath) {
            NSApp.applicationIconImage = iconImage
        } else {
            print("Warning: AppIcon.icns not found in bundle resources.")
        }
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
        messageModal.show(with: autoMessageManager.config.text, interval: autoMessageManager.config.interval, isEnabled: autoMessageManager.config.isEnabled)
    }
    
    private func presentMissingAutoMessageAlert() {
        let alert = NSAlert()
        alert.messageText = "Message not configured"
        alert.informativeText = "Please configure a message before enabling Auto Message."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Configure")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            openMessageModal()
        }
    }
    
    @objc func openAutoReplyModal() {
        autoReplyModal.show(keyword: autoReplyManager.config.keyword, message: autoReplyManager.config.message, isEnabled: autoReplyManager.config.isEnabled)
    }
    
    @objc func openAutoPlantacaoModal() {
        autoFarmingModal.show(seedName: autoFarmingManager.config.seedName, useBuyPlants: autoFarmingManager.config.useBuyPlants)
    }
    
    @objc func toggleAutoMessage() {
        autoMessageManager.toggle()
    }
    
    @objc func toggleAutoReply() {
        autoReplyManager.toggle()
    }
    
    @objc func openChatHistoryModal() {
        let currentPage = 0
        let messages = chatHistoryManager.getMessages(page: currentPage, pageSize: 10)
        let totalPages = chatHistoryManager.getTotalPages(pageSize: 10)
        let totalMessages = chatHistoryManager.getTotalMessages()
        chatHistoryModal.show(
            isEnabled: chatHistoryManager.isEnabled,
            messages: messages,
            currentPage: currentPage,
            totalPages: totalPages,
            totalMessages: totalMessages
        )
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
    
    private func presentMissingAutoReplyAlert() {
        let alert = NSAlert()
        alert.messageText = "Auto Reply not configured"
        alert.informativeText = "Please configure a keyword and reply message before enabling Auto Reply."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Configure")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            openAutoReplyModal()
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
