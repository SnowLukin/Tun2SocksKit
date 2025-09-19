# Tun2SocksKit


This repository is a wrapper and a build workflow for [hev-socks5-tunnel](https://github.com/heiher/hev-socks5-tunnel)

## Original Developer ([arror](https://github.com/arror/))
This code originally belonged to [arror](https://github.com/arror/). I'm just maintaining and updating it.

If you appreciate this repo, give him a thanks.

## Usage
You only need to import `Tun2SocksKit`
```swift
import Tun2SocksKit
```

### Running Tun2SocksKit

```swift
override func startTunnel(options: [String : NSObject]?) async throws {
    let tunnel = Socks5TunnelProvider.shared

    let configString = "... YAML ..."
    tunnel.start(with: .string(content: configString))
}

override func stopTunnel(with reason: NEProviderStopReason) async {
    Socks5TunnelProvider.shared.stop()
}
```

### Stats
To get stats you need to call
```swift
let stats = tunnel.statistics()
print("↑\(stats.up.packets) pkts / \(stats.up.bytes) bytes")
print("↓\(stats.down.packets) pkts / \(stats.down.bytes) bytes")
```

## Config
```yml
tunnel:
  mtu: 9000

socks5:
  port: 7890
  address: ::1
  udp: 'udp'

misc:
  task-stack-size: 24576 # 20480 + 4096
  tcp-buffer-size: 4096
  connect-timeout: 5000
  read-write-timeout: 60000
  log-file: stderr
  log-level: debug
  limit-nofile: 65535
```






