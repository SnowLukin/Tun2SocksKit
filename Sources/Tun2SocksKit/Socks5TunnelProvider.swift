import Foundation
import Tun2SocksKitC
import HevSocks5Tunnel

public enum Socks5Config {
    case file(path: URL)
    case string(content: String)
}

public struct SocksTunStats {
    public struct Stat {
        public let packets: Int
        public let bytes: Int
    }

    public let up: Stat
    public let down: Stat
}

public enum SocksTunState: Equatable {
    case stopped
    case running
    case error(Int32)
}

public protocol Socks5TunnelProviding: Actor {
    var currentState: SocksTunState { get }

    func start(with config: Socks5Config)
    func stop()
    func statistics() -> SocksTunStats
}

public actor Socks5TunnelProvider: Socks5TunnelProviding {

    public static let shared = Socks5TunnelProvider()
    private init() {}

    public var currentState: SocksTunState { state }
    private var state: SocksTunState = .stopped

    private var workerTask: Task<Void, Never>?

    public func start(with config: Socks5Config) {
        guard case .stopped = state else { return }

        guard let fd = resolveTunnelFileDescriptor() else {
            state = .error(-1)
            return
        }

        workerTask = Task.detached(priority: .userInitiated) { [weak self] in
            let exitCode: Int32
            switch config {
            case .file(let url):
                exitCode = url.path.withCString { ptr in
                    hev_socks5_tunnel_main(ptr, fd)
                }
            case .string(let content):
                let utf8Bytes = [UInt8](content.utf8)
                exitCode = utf8Bytes.withUnsafeBufferPointer { buffer in
                    hev_socks5_tunnel_main_from_str(buffer.baseAddress, UInt32(buffer.count), fd)
                }
            }

            await self?.updateStateAfterExit(exitCode)
        }

        state = .running
    }

    public func stop() {
        guard case .running = state else { return }
        hev_socks5_tunnel_quit()
        workerTask?.cancel()
        workerTask = nil
        state = .stopped
    }

    public func statistics() -> SocksTunStats {
        var tPackets: Int = 0
        var tBytes: Int = 0
        var rPackets: Int = 0
        var rBytes: Int = 0
        hev_socks5_tunnel_stats(&tPackets, &tBytes, &rPackets, &rBytes)
        return SocksTunStats(
            up: SocksTunStats.Stat(packets: tPackets, bytes: tBytes),
            down: SocksTunStats.Stat(packets: rPackets, bytes: rBytes)
        )
    }

    private func updateStateAfterExit(_ code: Int32) {
        state = (code == 0) ? .stopped : .error(code)
    }

    private func resolveTunnelFileDescriptor() -> Int32? {
        var ctlInfo = ctl_info()
        withUnsafeMutablePointer(to: &ctlInfo.ctl_name) {
            $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: $0.pointee)) {
                _ = strcpy($0, "com.apple.net.utun_control")
            }
        }
        for fd: Int32 in 0...1024 {
            var addr = sockaddr_ctl()
            var ret: Int32 = -1
            var len = socklen_t(MemoryLayout.size(ofValue: addr))
            withUnsafeMutablePointer(to: &addr) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    ret = getpeername(fd, $0, &len)
                }
            }
            if ret != 0 || addr.sc_family != AF_SYSTEM {
                continue
            }
            if ctlInfo.ctl_id == 0 {
                ret = ioctl(fd, CTLIOCGINFO, &ctlInfo)
                if ret != 0 {
                    continue
                }
            }
            if addr.sc_id == ctlInfo.ctl_id {
                return fd
            }
        }
        return nil
    }
}
