import Foundation

struct JavaScriptScripts {
    static func autoReplyScript(keyword: String, message: String) -> String {
        let escapedKeyword = keyword
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\"", with: "\\\"")
        
        let escapedMessage = message
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
        
        return """
        (function() {
            if (window.__autoReplyObserver) {
                window.__autoReplyObserver.disconnect();
                window.__autoReplyObserver = null;
            }
            
            const keyword = '\(escapedKeyword)';
            const replyMessage = '\(escapedMessage)';
            const keywordLower = keyword.toLowerCase();
            
            function sendReply() {
                const chatInput = document.querySelector('input[name="chatInput"]') || 
                                 document.querySelector('.ChatPanel_textInput__HK2XH') ||
                                 document.querySelector('input[type="text"][placeholder*="message" i]') ||
                                 document.querySelector('input[type="text"][placeholder*="mensagem" i]');
                
                if (!chatInput) {
                    return false;
                }
                
                chatInput.focus();
                chatInput.value = '';
                
                const messageChars = replyMessage.split('');
                let index = 0;
                
                function typeChar() {
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
                    
                    index++;
                    setTimeout(typeChar, 30 + Math.random() * 20);
                }
                
                setTimeout(typeChar, 100);
                return true;
            }
            
            function checkForKeyword() {
                const messageContainers = document.querySelectorAll('.ChatPanel_messageContainer__vcNLb, .ChatPanel_text__gPmys');
                const messages = Array.from(messageContainers);
                
                if (messages.length > 0) {
                    const lastMessage = messages[messages.length - 1];
                    const messageText = lastMessage.textContent || lastMessage.innerText || '';
                    const messageTextLower = messageText.toLowerCase();
                    
                    if (messageTextLower.includes(keywordLower)) {
                        if (!window.__lastReplyTime || Date.now() - window.__lastReplyTime > 2000) {
                            window.__lastReplyTime = Date.now();
                            setTimeout(sendReply, 500);
                        }
                    }
                }
            }
            
            const observer = new MutationObserver(function(mutations) {
                mutations.forEach(function(mutation) {
                    mutation.addedNodes.forEach(function(node) {
                        if (node.nodeType === 1) {
                            if (node.classList && (
                                node.classList.contains('ChatPanel_messageContainer__vcNLb') ||
                                node.classList.contains('ChatPanel_text__gPmys') ||
                                node.querySelector('.ChatPanel_text__gPmys')
                            )) {
                                setTimeout(checkForKeyword, 100);
                            }
                        }
                    });
                });
            });
            
            const messagesContainer = document.querySelector('.ChatPanel_messages__8u6bQ') ||
                                     document.querySelector('.ChatPanel_messagesContainer__TK6HF') ||
                                     document.body;
            
            if (messagesContainer) {
                observer.observe(messagesContainer, {
                    childList: true,
                    subtree: true
                });
                
                window.__autoReplyObserver = observer;
                setTimeout(checkForKeyword, 1000);
            }
        })();
        """
    }
    
    static func mentionHighlighterScript(firstName: String, lastName: String) -> String {
        let escapedFirstName = firstName
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\"", with: "\\\"")
        
        let escapedLastName = lastName
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\"", with: "\\\"")
        
        return """
        (function() {
            if (window.__mentionObserver) {
                window.__mentionObserver.disconnect();
                window.__mentionObserver = null;
            }
            
            const firstName = '\(escapedFirstName)';
            const lastName = '\(escapedLastName)';
            const fullName = firstName + ' ' + lastName;
            const firstNameLower = firstName.toLowerCase();
            const lastNameLower = lastName.toLowerCase();
            const fullNameLower = fullName.toLowerCase();
            
            const patterns = [
                '@' + firstName + ' ' + lastName,
                '@' + firstNameLower + ' ' + lastNameLower,
                '@' + firstName + ' ' + lastNameLower,
                '@' + firstNameLower + ' ' + lastName,
                '@' + fullName,
                '@' + fullNameLower
            ];
            
            function containsMention(text) {
                if (!text) return false;
                const textLower = text.toLowerCase();
                return patterns.some(pattern => {
                    const patternLower = pattern.toLowerCase();
                    return textLower.includes(patternLower);
                });
            }
            
            function highlightMention(container) {
                if (container.dataset.mentionProcessed === 'true') {
                    return;
                }
                
                container.dataset.mentionProcessed = 'true';
                container.classList.add('mention-highlighted');
                
                const style = container.style || {};
                style.border = '2px solid #FFD700';
                style.borderRadius = '8px';
                style.padding = '4px';
                style.backgroundColor = 'rgba(255, 215, 0, 0.1)';
                style.boxShadow = '0 0 8px rgba(255, 215, 0, 0.5)';
                
                requestAnimationFrame(function() {
                    style.transition = 'all 5s ease-out';
                    
                    setTimeout(function() {
                        style.border = '2px solid rgba(255, 215, 0, 0)';
                        style.backgroundColor = 'rgba(255, 215, 0, 0)';
                        style.boxShadow = '0 0 8px rgba(255, 215, 0, 0)';
                        
                        setTimeout(function() {
                            container.classList.remove('mention-highlighted');
                            style.border = '';
                            style.borderRadius = '';
                            style.padding = '';
                            style.backgroundColor = '';
                            style.boxShadow = '';
                            style.transition = '';
                        }, 5000);
                    }, 10);
                });
            }
            
            function checkAndHighlightMessages() {
                const messageContainers = document.querySelectorAll('.ChatPanel_messageContainer__vcNLb');
                
                messageContainers.forEach(container => {
                    if (container.dataset.mentionProcessed === 'true') {
                        return;
                    }
                    
                    const textElement = container.querySelector('.ChatPanel_text__gPmys');
                    if (textElement) {
                        const messageText = textElement.textContent || textElement.innerText || '';
                        if (containsMention(messageText)) {
                            highlightMention(container);
                        }
                    }
                });
            }
            
            const observer = new MutationObserver(function(mutations) {
                mutations.forEach(function(mutation) {
                    mutation.addedNodes.forEach(function(node) {
                        if (node.nodeType === 1) {
                            if (node.classList && (
                                node.classList.contains('ChatPanel_messageContainer__vcNLb') ||
                                node.classList.contains('ChatPanel_text__gPmys') ||
                                node.querySelector('.ChatPanel_messageContainer__vcNLb') ||
                                node.querySelector('.ChatPanel_text__gPmys')
                            )) {
                                setTimeout(checkAndHighlightMessages, 100);
                            }
                        }
                    });
                });
            });
            
            const messagesContainer = document.querySelector('.ChatPanel_messages__8u6bQ') ||
                                     document.querySelector('.ChatPanel_messagesContainer__TK6HF') ||
                                     document.body;
            
            if (messagesContainer) {
                observer.observe(messagesContainer, {
                    childList: true,
                    subtree: true
                });
                
                window.__mentionObserver = observer;
                setTimeout(checkAndHighlightMessages, 1000);
                setInterval(checkAndHighlightMessages, 2000);
            }
        })();
        """
    }
    
    static func autoHarvestScript() -> String {
        return """
        (function() {
            if (window.__autoHarvestObserver) {
                window.__autoHarvestObserver.disconnect();
                window.__autoHarvestObserver = null;
            }
            
            function clickHarvestOnMenu() {
                const contextualMenu = document.querySelector('.ContextualMenu_container__piX5c');
                if (!contextualMenu) {
                    return false;
                }
                
                const menuItems = contextualMenu.querySelectorAll('.ContextualMenu_item__milvQ');
                for (let item of menuItems) {
                    const textElement = item.querySelector('.ContextualMenu_text__GVy-f');
                    if (textElement && textElement.textContent.trim() === 'Harvest') {
                        const menuId = contextualMenu.getAttribute('data-menu-id') || Date.now().toString();
                        if (item.dataset.lastHarvestClick !== menuId) {
                            item.dataset.lastHarvestClick = menuId;
                            contextualMenu.setAttribute('data-menu-id', menuId);
                            
                            try {
                                item.click();
                            } catch(e) {
                                requestAnimationFrame(function() {
                                    item.click();
                                });
                            }
                            return true;
                        }
                    }
                }
                return false;
            }
            
            const observer = new MutationObserver(function(mutations) {
                mutations.forEach(function(mutation) {
                    mutation.addedNodes.forEach(function(node) {
                        if (node.nodeType === 1) {
                            let menuFound = false;
                            
                            if (node.classList && node.classList.contains('ContextualMenu_container__piX5c')) {
                                menuFound = true;
                            }
                            
                            if (!menuFound) {
                                const menu = node.querySelector && node.querySelector('.ContextualMenu_container__piX5c');
                                if (menu) {
                                    menuFound = true;
                                }
                            }
                            
                            if (menuFound) {
                                if (!clickHarvestOnMenu()) {
                                    requestAnimationFrame(clickHarvestOnMenu);
                                }
                            }
                        }
                    });
                });
            });
            
            observer.observe(document.body, {
                childList: true,
                subtree: true
            });
            
            window.__autoHarvestObserver = observer;
            requestAnimationFrame(clickHarvestOnMenu);
        })();
        """
    }
    
    static func autoPlantScript(seedName: String, useBuyPlants: Bool) -> String {
        let escapedSeedName = seedName
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\"", with: "\\\"")
        
        let useBuyPlantsStr = useBuyPlants ? "true" : "false"
        
        return """
        (function() {
            if (window.__autoPlantObserver) {
                window.__autoPlantObserver.disconnect();
                window.__autoPlantObserver = null;
            }
            
            if (window.__autoPlantTendInterval) {
                clearInterval(window.__autoPlantTendInterval);
                window.__autoPlantTendInterval = null;
            }
            
            const seedName = '\(escapedSeedName)';
            const seedNameLower = seedName.toLowerCase();
            const useBuyPlants = \(useBuyPlantsStr);
            
            function clickTendOnMenu() {
                const contextualMenu = document.querySelector('.ContextualMenu_container__piX5c');
                if (!contextualMenu) {
                    return false;
                }
                
                const menuItems = contextualMenu.querySelectorAll('.ContextualMenu_item__milvQ');
                for (let item of menuItems) {
                    const textElement = item.querySelector('.ContextualMenu_text__GVy-f');
                    if (textElement) {
                        const text = textElement.textContent || textElement.innerText || '';
                        if (text.trim() === 'Tend') {
                            const menuId = contextualMenu.getAttribute('data-menu-id') || Date.now().toString();
                            if (item.dataset.lastTendClick !== menuId) {
                                item.dataset.lastTendClick = menuId;
                                contextualMenu.setAttribute('data-menu-id', menuId);
                                
                                try {
                                    item.click();
                                    return true;
                                } catch(e) {
                                    requestAnimationFrame(function() {
                                        try {
                                            item.click();
                                        } catch(e2) {
                                            const mouseDownEvent = new MouseEvent('mousedown', {
                                                bubbles: true,
                                                cancelable: true,
                                                view: window,
                                                button: 0
                                            });
                                            const mouseUpEvent = new MouseEvent('mouseup', {
                                                bubbles: true,
                                                cancelable: true,
                                                view: window,
                                                button: 0
                                            });
                                            const clickEvent = new MouseEvent('click', {
                                                bubbles: true,
                                                cancelable: true,
                                                view: window,
                                                button: 0
                                            });
                                            item.dispatchEvent(mouseDownEvent);
                                            item.dispatchEvent(mouseUpEvent);
                                            item.dispatchEvent(clickEvent);
                                        }
                                    });
                                    return true;
                                }
                            }
                        }
                    }
                }
                return false;
            }
            
            function clickCorrectTab() {
                const tabs = document.querySelectorAll('.widget_planter_buyMenuTab__5Qwv3');
                if (!tabs || tabs.length < 2) {
                    return false;
                }
                
                const targetTab = useBuyPlants ? tabs[0] : tabs[1];
                if (!targetTab) {
                    return false;
                }
                
                if (!targetTab.classList.contains('undefined')) {
                    try {
                        targetTab.click();
                        return true;
                    } catch(e) {
                        requestAnimationFrame(function() {
                            targetTab.click();
                        });
                        return true;
                    }
                }
                
                return true;
            }
            
            function clickBuySeedButton() {
                const buySeedButton = document.querySelector('.widget_planter_tab__0-QHR');
                if (!buySeedButton) {
                    return false;
                }
                
                if (buySeedButton.dataset.autoPlantBuyClicked !== 'true') {
                    buySeedButton.dataset.autoPlantBuyClicked = 'true';
                    
                    try {
                        buySeedButton.click();
                        setTimeout(function() {
                            clickCorrectTab();
                        }, 150);
                    } catch(e) {
                        requestAnimationFrame(function() {
                            buySeedButton.click();
                            setTimeout(function() {
                                clickCorrectTab();
                            }, 150);
                        });
                    }
                    return true;
                }
                return false;
            }
            
            function checkAndClickBuySeed() {
                const buySeedButton = document.querySelector('.widget_planter_tab__0-QHR');
                if (buySeedButton) {
                    if (buySeedButton.dataset.autoPlantBuyClicked !== 'true') {
                        setTimeout(function() {
                            clickBuySeedButton();
                        }, 100);
                    } else {
                        setTimeout(function() {
                            clickCorrectTab();
                        }, 100);
                    }
                }
            }
            
            function clickCloseButton() {
                const closeButton = document.querySelector('.Hud_close__NATrf');
                if (closeButton) {
                    if (closeButton.dataset.autoPlantCloseClicked !== 'true') {
                        closeButton.dataset.autoPlantCloseClicked = 'true';
                        
                        try {
                            closeButton.click();
                        } catch(e) {
                            requestAnimationFrame(function() {
                                closeButton.click();
                            });
                        }
                        return true;
                    }
                }
                return false;
            }
            
            function selectSeedAndPlant() {
                const seedMenu = document.querySelector('[class*="widget_planter_buyMenuBodySeeds"]');
                if (!seedMenu) {
                    return false;
                }
                
                const seedItems = seedMenu.querySelectorAll('.widget_planter_buyMenuSeed__8Py1r');
                
                let seedFound = false;
                
                for (let seedItem of seedItems) {
                    const seedNameElement = seedItem.querySelector('.widget_planter_buyMenuSeedName__GUu0O');
                    if (seedNameElement) {
                        const itemName = seedNameElement.textContent || seedNameElement.innerText || '';
                        const itemNameLower = itemName.toLowerCase();
                        
                        if (itemNameLower.includes(seedNameLower) || seedNameLower.includes(itemNameLower)) {
                            if (!seedItem.classList.contains('widget_planter_buyMenuSeedSelected__151vR')) {
                                try {
                                    seedItem.click();
                                } catch(e) {
                                    requestAnimationFrame(function() {
                                        seedItem.click();
                                    });
                                }
                            }
                            
                            seedFound = true;
                            
                            setTimeout(function() {
                                const sowButton = document.querySelector('.widget_planter_buyMenuFooterSow__Ww8sO');
                                if (sowButton && !sowButton.disabled) {
                                    try {
                                        sowButton.click();
                                        
                                        setTimeout(function() {
                                            const closeBtn = document.querySelector('.Hud_close__NATrf');
                                            if (closeBtn) {
                                                closeBtn.dataset.autoPlantCloseClicked = 'false';
                                            }
                                            clickCloseButton();
                                        }, 300);
                                    } catch(e) {
                                        requestAnimationFrame(function() {
                                            sowButton.click();
                                            
                                            setTimeout(function() {
                                                const closeBtn = document.querySelector('.Hud_close__NATrf');
                                                if (closeBtn) {
                                                    closeBtn.dataset.autoPlantCloseClicked = 'false';
                                                }
                                                clickCloseButton();
                                            }, 300);
                                        });
                                    }
                                }
                            }, 100);
                            
                            return true;
                        }
                    }
                }
                
                if (!seedFound) {
                    const nextButton = document.querySelector('.PageControl_next__md7oq');
                    if (nextButton && !nextButton.disabled) {
                        nextButton.click();
                        setTimeout(selectSeedAndPlant, 300);
                    }
                }
                
                return seedFound;
            }
            
            function checkAndProcessSeedMenu() {
                const seedMenu = document.querySelector('[class*="widget_planter_buyMenuBodySeeds"]');
                if (seedMenu) {
                    clickCorrectTab();
                    
                    setTimeout(function() {
                        if (seedMenu.dataset.autoPlantProcessed !== 'true') {
                            seedMenu.dataset.autoPlantProcessed = 'true';
                            selectSeedAndPlant();
                        }
                    }, 200);
                }
            }
            
            const observer = new MutationObserver(function(mutations) {
                mutations.forEach(function(mutation) {
                    mutation.addedNodes.forEach(function(node) {
                        if (node.nodeType === 1) {
                            let menuFound = false;
                            
                            if (node.classList && node.classList.contains('ContextualMenu_container__piX5c')) {
                                menuFound = true;
                            }
                            
                            if (!menuFound) {
                                const menu = node.querySelector && node.querySelector('.ContextualMenu_container__piX5c');
                                if (menu) {
                                    menuFound = true;
                                }
                            }
                            
                            if (menuFound) {
                                if (!clickTendOnMenu()) {
                                    requestAnimationFrame(function() {
                                        if (!clickTendOnMenu()) {
                                            setTimeout(function() {
                                                clickTendOnMenu();
                                            }, 50);
                                        }
                                    });
                                }
                            }
                            
                            let buySeedButtonFound = false;
                            if (node.classList && node.classList.contains('widget_planter_tab__0-QHR')) {
                                buySeedButtonFound = true;
                            }
                            
                            if (!buySeedButtonFound) {
                                const buySeedButton = node.querySelector && node.querySelector('.widget_planter_tab__0-QHR');
                                if (buySeedButton) {
                                    buySeedButtonFound = true;
                                }
                            }
                            
                            if (buySeedButtonFound) {
                                requestAnimationFrame(checkAndClickBuySeed);
                            }
                            
                            let tabsFound = false;
                            if (node.classList && node.classList.contains('widget_planter_buyMenuTab__5Qwv3')) {
                                tabsFound = true;
                            }
                            
                            if (!tabsFound) {
                                const tabs = node.querySelectorAll && node.querySelectorAll('.widget_planter_buyMenuTab__5Qwv3');
                                if (tabs && tabs.length >= 2) {
                                    tabsFound = true;
                                }
                            }
                            
                            if (tabsFound) {
                                setTimeout(function() {
                                    clickCorrectTab();
                                }, 100);
                            }
                            
                            if (node.classList) {
                                const classList = Array.from(node.classList);
                                if (classList.some(cls => cls.includes('widget_planter_buyMenuBodySeeds'))) {
                                    requestAnimationFrame(checkAndProcessSeedMenu);
                                }
                            }
                            
                            const seedMenu = node.querySelector && node.querySelector('[class*="widget_planter_buyMenuBodySeeds"]');
                            if (seedMenu) {
                                requestAnimationFrame(checkAndProcessSeedMenu);
                            }
                            
                            if (node.classList && node.classList.contains('widget_planter_buyMenuSeed__8Py1r')) {
                                requestAnimationFrame(checkAndProcessSeedMenu);
                            }
                        }
                    });
                });
            });
            
            observer.observe(document.body, {
                childList: true,
                subtree: true
            });
            
            window.__autoPlantObserver = observer;
            
            let tendCheckInterval = setInterval(function() {
                clickTendOnMenu();
            }, 100);
            
            window.__autoPlantTendInterval = tendCheckInterval;
            
            requestAnimationFrame(function() {
                if (!clickTendOnMenu()) {
                    setTimeout(function() {
                        clickTendOnMenu();
                    }, 50);
                }
            });
            
            requestAnimationFrame(function() {
                checkAndClickBuySeed();
                setTimeout(function() {
                    clickCorrectTab();
                }, 200);
            });
            
            requestAnimationFrame(function() {
                clickCorrectTab();
                setTimeout(function() {
                    checkAndProcessSeedMenu();
                }, 200);
            });
        })();
        """
    }
    
    static func chatHistoryObserverScript() -> String {
        return """
        (function() {
            if (window.__chatHistoryObserver) {
                window.__chatHistoryObserver.disconnect();
                window.__chatHistoryObserver = null;
            }
            
            if (window.__chatHistoryInputObserver) {
                window.__chatHistoryInputObserver.disconnect();
                window.__chatHistoryInputObserver = null;
            }
            
            if (window.__chatHistoryProcessedMessages) {
                window.__chatHistoryProcessedMessages.clear();
            } else {
                window.__chatHistoryProcessedMessages = new Set();
            }
            
            let pendingMessage = null;
            let lastInputValue = '';
            
            function extractMessageText(container) {
                const textElement = container.querySelector('.ChatPanel_text__gPmys');
                if (textElement) {
                    return textElement.textContent || textElement.innerText || '';
                }
                const nameElement = container.querySelector('.ChatPanel_name__SoYeq');
                if (nameElement) {
                    const textSpan = nameElement.querySelector('.ChatPanel_text__gPmys');
                    if (textSpan) {
                        return textSpan.textContent || textSpan.innerText || '';
                    }
                }
                return container.textContent || container.innerText || '';
            }
            
            function getMessageId(container) {
                const existingId = container.getAttribute('data-chat-history-id');
                if (existingId) {
                    return existingId;
                }
                
                const messageText = extractMessageText(container);
                const timestamp = container.getAttribute('data-timestamp') || Date.now().toString();
                const id = timestamp + '_' + (messageText.substring(0, 20) || '').replace(/[^a-zA-Z0-9]/g, '');
                container.setAttribute('data-chat-history-id', id);
                return id;
            }
            
            function captureMessage(text) {
                if (!text || text.trim().length === 0) {
                    console.log('Chat history: Empty message, skipping');
                    return;
                }
                
                const trimmedText = text.trim();
                const messageId = 'msg_' + Date.now() + '_' + trimmedText.substring(0, 10).replace(/[^a-zA-Z0-9]/g, '');
                
                if (window.__chatHistoryProcessedMessages.has(messageId)) {
                    console.log('Chat history: Message already processed:', trimmedText);
                    return;
                }
                
                window.__chatHistoryProcessedMessages.add(messageId);
                
                console.log('Chat history: Sending message to Swift:', trimmedText);
                
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.chatMessage) {
                    try {
                        window.webkit.messageHandlers.chatMessage.postMessage({
                            text: trimmedText,
                            timestamp: new Date().toISOString()
                        });
                        console.log('Chat history: Message sent successfully');
                    } catch(e) {
                        console.error('Chat history: Error sending message:', e);
                    }
                } else {
                    console.error('Chat history: Message handler not available');
                }
            }
            
            function setupInputObserver() {
                const chatInput = document.querySelector('input[name="chatInput"]') || 
                                 document.querySelector('.ChatPanel_textInput__HK2XH') ||
                                 document.querySelector('input[type="text"][placeholder*="message" i]') ||
                                 document.querySelector('input[type="text"][placeholder*="mensagem" i]');
                
                if (!chatInput) {
                    return;
                }
                
                if (chatInput.dataset.chatHistoryListener === 'true') {
                    return;
                }
                
                chatInput.dataset.chatHistoryListener = 'true';
                
                const handleKeyDown = function(e) {
                    if (e.key === 'Enter' && !e.shiftKey && chatInput.value && chatInput.value.trim().length > 0) {
                        const messageToSend = chatInput.value.trim();
                        pendingMessage = messageToSend;
                        lastInputValue = chatInput.value;
                        console.log('Chat history: Message pending (Enter pressed):', pendingMessage);
                        
                        setTimeout(function() {
                            checkForSentMessage();
                        }, 300);
                    }
                };
                
                chatInput.addEventListener('keydown', handleKeyDown, true);
                
                chatInput.addEventListener('input', function(e) {
                    lastInputValue = chatInput.value;
                });
                
                console.log('Chat history: Input observer attached to chat input');
            }
            
            function checkForSentMessage() {
                if (!pendingMessage) {
                    return;
                }
                
                const trimmedPending = pendingMessage.trim();
                if (!trimmedPending) {
                    pendingMessage = null;
                    return;
                }
                
                const messageContainers = document.querySelectorAll('.ChatPanel_messageContainer__vcNLb');
                const recentContainers = Array.from(messageContainers).slice(-10);
                
                for (let container of recentContainers) {
                    const messageText = extractMessageText(container);
                    const messageId = getMessageId(container);
                    
                    if (window.__chatHistoryProcessedMessages.has(messageId)) {
                        continue;
                    }
                    
                    const trimmedMessage = messageText ? messageText.trim() : '';
                    
                    if (trimmedMessage === trimmedPending) {
                        window.__chatHistoryProcessedMessages.add(messageId);
                        console.log('Chat history: Found exact matching message, capturing:', trimmedPending);
                        captureMessage(trimmedPending);
                        pendingMessage = null;
                        return;
                    }
                }
                
                setTimeout(function() {
                    if (!pendingMessage) {
                        return;
                    }
                    
                    const trimmedPending = pendingMessage.trim();
                    const messageContainers = document.querySelectorAll('.ChatPanel_messageContainer__vcNLb');
                    const lastContainers = Array.from(messageContainers).slice(-5);
                    
                    let found = false;
                    for (let container of lastContainers) {
                        const messageText = extractMessageText(container);
                        const trimmedMessage = messageText ? messageText.trim() : '';
                        
                        if (trimmedMessage === trimmedPending) {
                            const messageId = getMessageId(container);
                            if (!window.__chatHistoryProcessedMessages.has(messageId)) {
                                window.__chatHistoryProcessedMessages.add(messageId);
                                console.log('Chat history: Found exact matching message (delayed), capturing:', trimmedPending);
                                captureMessage(trimmedPending);
                                found = true;
                                break;
                            }
                        }
                    }
                    
                    if (!found && trimmedPending) {
                        console.log('Chat history: Message not found in chat after delay, capturing anyway:', trimmedPending);
                        captureMessage(trimmedPending);
                    }
                    pendingMessage = null;
                }, 1200);
            }
            
            const observer = new MutationObserver(function(mutations) {
                mutations.forEach(function(mutation) {
                    mutation.addedNodes.forEach(function(node) {
                        if (node.nodeType === 1) {
                            const isMessageContainer = node.classList && node.classList.contains('ChatPanel_messageContainer__vcNLb');
                            const hasMessageContainer = node.querySelector && node.querySelector('.ChatPanel_messageContainer__vcNLb');
                            const hasMessageText = node.querySelector && node.querySelector('.ChatPanel_text__gPmys');
                            
                            if (isMessageContainer || hasMessageContainer || hasMessageText) {
                                if (pendingMessage) {
                                    setTimeout(checkForSentMessage, 150);
                                }
                            }
                        }
                    });
                });
            });
            
            const messagesContainer = document.querySelector('.ChatPanel_messages__8u6bQ') ||
                                     document.querySelector('.ChatPanel_messagesContainer__TK6HF') ||
                                     document.body;
            
            if (messagesContainer) {
                observer.observe(messagesContainer, {
                    childList: true,
                    subtree: true
                });
                
                window.__chatHistoryObserver = observer;
                console.log('Chat history: Observer attached to messages container');
            } else {
                console.error('Chat history: Messages container not found');
            }
            
            const inputObserver = new MutationObserver(function() {
                setupInputObserver();
            });
            
            inputObserver.observe(document.body, {
                childList: true,
                subtree: true
            });
            
            window.__chatHistoryInputObserver = inputObserver;
            
            setTimeout(setupInputObserver, 500);
            setTimeout(setupInputObserver, 1500);
            setTimeout(setupInputObserver, 3000);
            setInterval(setupInputObserver, 5000);
        })();
        """
    }
}

