// swift-tools-version: 5.6

 import PackageDescription

 let package = Package(
     name: "FlagPhoneNumber",
     platforms: [.macOS(.v10_10), .iOS(.v9)],
     products: [
         .library(name: "FlagPhoneNumber", targets: ["FlagPhoneNumber"]),
     ],
     dependencies: [
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: Version(3, 4, 0))
     ],
     targets: [
         .target(
            name: "FlagPhoneNumber",
            dependencies: [
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit")
            ],
            resources: [
                .process("Resources/countryCodes.json")
            ]
         )
     ]
 )
