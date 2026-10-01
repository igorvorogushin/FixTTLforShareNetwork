import Foundation

struct TTLValues {
    let ipv4: Int?
    let ipv6: Int?
    func matches(_ value: Int) -> Bool { ipv4 == value && ipv6 == value }
}

enum ChangeResult { case succeeded, cancelled, failed }

enum TTLService {
    nonisolated static func read() -> TTLValues {
        TTLValues(ipv4: read("net.inet.ip.ttl"), ipv6: read("net.inet6.ip6.hlim"))
    }

    nonisolated private static func read(_ key: String) -> Int? {
        let result = run("/usr/sbin/sysctl", ["-n", key])
        return result.status == 0 ? Int(result.output.trimmingCharacters(in: .whitespacesAndNewlines)) : nil
    }

    nonisolated static func set(_ value: Int) -> ChangeResult {
        let command = "/usr/sbin/sysctl -w net.inet.ip.ttl=\(value) && /usr/sbin/sysctl -w net.inet6.ip6.hlim=\(value)"
        let result = run("/usr/bin/osascript", ["-e", "do shell script \"\(command)\" with administrator privileges"])
        if result.status == 0 { return .succeeded }
        return result.output.contains("-128") || result.output.contains("User canceled") ? .cancelled : .failed
    }

    nonisolated private static func run(_ executable: String, _ arguments: [String]) -> (status: Int32, output: String) {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
            process.waitUntilExit()
            return (process.terminationStatus,
                    String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "")
        } catch { return (1, error.localizedDescription) }
    }
}
