// swift-tools-version: 5.6

 import PackageDescription

 let package = Package(
     name: "FlagPhoneNumber",
     platforms: [.macOS(.v10_10), .iOS(.v9)],
     products: [
         .library(name: "FlagPhoneNumber", targets: ["FlagPhoneNumber"]),
     ],
     dependencies: [
        .package(url: "https://github.com/Mindera/libPhoneNumber-iOS.git", exact: Version(1, 0, 3))
     ],
     targets: [
         .target(
            name: "FlagPhoneNumber",
            dependencies: [
                .product(name: "libPhoneNumber", package: "libPhoneNumber-iOS")
            ],
            resources: [
                .process("Resources/countryCodes.json")
            ]
         )
     ]
 )
