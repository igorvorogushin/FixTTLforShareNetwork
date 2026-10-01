import Foundation

@MainActor
final class TTLViewModel: ObservableObject {
    @Published private(set) var values = TTLValues(ipv4: nil, ipv6: nil)
    @Published private(set) var statusKey = "checking"
    @Published private(set) var isWorking = false

    var isApplied: Bool { values.matches(65) }
    var currentTTL: Int? {
        values.ipv4 == values.ipv6 ? values.ipv4 : nil
    }
    init() { refresh() }

    func refresh() {
        isWorking = true
        statusKey = "reading"
        Task.detached { [weak self] in
            let current = TTLService.read()
            await MainActor.run {
                guard let self else { return }
                self.values = current
                self.statusKey = current.matches(65) ? "already" : "ready"
                self.isWorking = false
            }
        }
    }

    func apply() { change(to: 65, successKey: "success") }
    func restore() { change(to: 64, successKey: "restored") }
    func toggle() {
        isApplied ? restore() : apply()
    }

    private func change(to value: Int, successKey: String) {
        isWorking = true
        statusKey = "auth"
        Task.detached { [weak self] in
            let result = TTLService.set(value)
            let current = result == .succeeded ? TTLService.read() : nil
            await MainActor.run {
                guard let self else { return }
                if let current { self.values = current }
                switch result {
                case .cancelled: self.statusKey = "cancelled"
                case .failed: self.statusKey = "failed"
                case .succeeded: self.statusKey = current?.matches(value) == true ? successKey : "failed"
                }
                self.isWorking = false
            }
        }
    }
}
