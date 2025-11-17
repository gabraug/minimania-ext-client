import Foundation
import Cocoa

class PlayersCountService {
    private var updateTimer: Timer?
    weak var label: NSTextField?
    
    func startUpdating(label: NSTextField) {
        self.label = label
        updatePlayersCount()
        startTimer()
    }
    
    func stopUpdating() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func startTimer() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updatePlayersCount()
        }
        RunLoop.current.add(updateTimer!, forMode: .common)
    }
    
    func updatePlayersCount() {
        guard let url = URL(string: "https://rest.minimania.app/avatars/getOnlineAvatarsCount") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("https://minimania.app", forHTTPHeaderField: "Origin")
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0.1 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.setValue("same-site", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.setValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.label?.stringValue = "Players: Error"
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let success = json["success"] as? Bool,
                      success == true else {
                    self?.label?.stringValue = "Players: --"
                    return
                }
                
                if let countString = json["onlineCount"] as? String,
                   let count = Int(countString) {
                    self?.label?.stringValue = "Players: \(count)"
                } else if let count = json["onlineCount"] as? Int {
                    self?.label?.stringValue = "Players: \(count)"
                } else if let count = json["count"] as? Int {
                    self?.label?.stringValue = "Players: \(count)"
                } else if let countString = json["count"] as? String,
                          let count = Int(countString) {
                    self?.label?.stringValue = "Players: \(count)"
                } else {
                    self?.label?.stringValue = "Players: --"
                }
            }
        }
        task.resume()
    }
}

