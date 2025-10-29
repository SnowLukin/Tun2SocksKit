// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Tun2SocksKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "Tun2SocksKit",
            targets: ["Tun2SocksKit"]
        ),
        .library(
            name: "Tun2SocksKitC",
            targets: ["Tun2SocksKitC"]
        ),
    ],
    targets: [
        .target(
            name: "Tun2SocksKit",
            dependencies: ["HevSocks5Tunnel", "Tun2SocksKitC"]
        ),
        .target(
            name: "Tun2SocksKitC",
            publicHeadersPath: "."
        ),
        .binaryTarget(
            name: "HevSocks5Tunnel",
            url: "https://github.com/SnowLukin/Tun2SocksKit/releases/download/1.1.3/HevSocks5Tunnel.xcframework.zip",
            checksum: "a1459c2f793bd5be1817b6fe905df47f362356ab95720a0cad9ae20b24439ac1"
        ),
    ]
)
