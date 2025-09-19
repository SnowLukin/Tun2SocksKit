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
            url: "https://github.com/SnowLukin/Tun2SocksKit/releases/download/1.0.3/HevSocks5Tunnel.xcframework.zip",
            checksum: "c0cb9ff3874bac679a5032055e345a2d345c75954bbc2e559886019246fe0d3e"
        ),
    ]
)
