import Foundation
import WebKit

class AutoMessageManager {
    private var timer: Timer?
    private let jsService: JavaScriptInjectionService
    var config: AutoMessageConfig
    var onMissingMessage: (() -> Void)?
    
    weak var button: NSButton?
    
    init(jsService: JavaScriptInjectionService, config: AutoMessageConfig = AutoMessageConfig()) {
        self.jsService = jsService
        self.config = config
    }
    
    func toggle() {
        config.isEnabled.toggle()
        
        if config.isEnabled {
            if config.text.isEmpty {
                config.isEnabled = false
                updateButtonState()
                onMissingMessage?()
                return
            }
            
            let interval = max(config.interval, 5.0)
            config.interval = interval
            startTimer()
        } else {
            stopTimer()
        }
        
        updateButtonState()
    }
    
    func startTimer() {
        stopTimer()
        
        let interval = max(config.interval, 5.0)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self, self.config.isEnabled else {
                timer.invalidate()
                return
            }
            
            let message = self.config.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if message.isEmpty {
                self.config.isEnabled = false
                self.updateButtonState()
                timer.invalidate()
                return
            }
            
            self.sendMessage(message)
        }
        
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateButtonState() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let iconName = self.config.isEnabled ? "message.fill" : "message"
            guard let icon = NSImage(systemSymbolName: iconName, accessibilityDescription: "Auto Message") else { return }
            let whiteIcon = icon.tinted(with: .white)
            whiteIcon.isTemplate = false
            self.button?.image = whiteIcon
            if self.config.isEnabled {
                self.button?.contentTintColor = .systemGreen
            } else {
                self.button?.contentTintColor = .white
            }
        }
    }
    
    private func sendMessage(_ message: String) {
        let characters = Array(message)
        var charArrayString = "["
        for (index, char) in characters.enumerated() {
            if index > 0 {
                charArrayString += ", "
            }
            let escaped = String(char)
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "'", with: "\\'")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\r", with: "\\r")
            charArrayString += "'\(escaped)'"
        }
        charArrayString += "]"
        
        let script = """
        (function() {
            const chatInput = document.querySelector('input[name="chatInput"]') || 
                             document.querySelector('.ChatPanel_textInput__HK2XH') ||
                             document.querySelector('input[type="text"][placeholder*="message" i]') ||
                             document.querySelector('input[type="text"][placeholder*="mensagem" i]');
            
            if (!chatInput) {
                console.log('Campo de chat não encontrado');
                return false;
            }
            
            chatInput.focus();
            chatInput.value = '';
            
            const messageChars = \(charArrayString);
            
            function typeCharacter(index) {
                if (index >= messageChars.length) {
                    setTimeout(function() {
                        const enterKeyDown = new KeyboardEvent('keydown', {
                            key: 'Enter',
                            code: 'Enter',
                            keyCode: 13,
                            which: 13,
                            bubbles: true,
                            cancelable: true
                        });
                        chatInput.dispatchEvent(enterKeyDown);
                        
                        const enterKeyPress = new KeyboardEvent('keypress', {
                            key: 'Enter',
                            code: 'Enter',
                            keyCode: 13,
                            which: 13,
                            bubbles: true,
                            cancelable: true
                        });
                        chatInput.dispatchEvent(enterKeyPress);
                        
                        const enterKeyUp = new KeyboardEvent('keyup', {
                            key: 'Enter',
                            code: 'Enter',
                            keyCode: 13,
                            which: 13,
                            bubbles: true,
                            cancelable: true
                        });
                        chatInput.dispatchEvent(enterKeyUp);
                    }, 50);
                    return;
                }
                
                const char = messageChars[index];
                chatInput.value += char;
                
                const inputEvent = new Event('input', { bubbles: true, cancelable: true });
                chatInput.dispatchEvent(inputEvent);
                
                const keyDownEvent = new KeyboardEvent('keydown', {
                    key: char,
                    code: char.length === 1 ? 'Key' + char.toUpperCase() : undefined,
                    keyCode: char.charCodeAt(0),
                    which: char.charCodeAt(0),
                    bubbles: true,
                    cancelable: true
                });
                chatInput.dispatchEvent(keyDownEvent);
                
                const keyPressEvent = new KeyboardEvent('keypress', {
                    key: char,
                    code: char.length === 1 ? 'Key' + char.toUpperCase() : undefined,
                    keyCode: char.charCodeAt(0),
                    which: char.charCodeAt(0),
                    bubbles: true,
                    cancelable: true
                });
                chatInput.dispatchEvent(keyPressEvent);
                
                const keyUpEvent = new KeyboardEvent('keyup', {
                    key: char,
                    code: char.length === 1 ? 'Key' + char.toUpperCase() : undefined,
                    keyCode: char.charCodeAt(0),
                    which: char.charCodeAt(0),
                    bubbles: true,
                    cancelable: true
                });
                chatInput.dispatchEvent(keyUpEvent);
                
                const delay = 30 + Math.random() * 20;
                setTimeout(function() {
                    typeCharacter(index + 1);
                }, delay);
            }
            
            setTimeout(function() {
                typeCharacter(0);
            }, 100);
            
            return true;
        })();
        """
        
        jsService.evaluate(script) { result, error in
            if let error = error {
                print("Error sending automatic message: \(error)")
            }
        }
    }
}

