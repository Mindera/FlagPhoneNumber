// swift-tools-version: 5.6

 import PackageDescription

 let package = Package(
     name: "FlagPhoneNumber",
     platforms: [.macOS(.v12), .iOS(.v15)],
     products: [
         .library(name: "FlagPhoneNumber", targets: ["FlagPhoneNumber"]),
     ],
     dependencies: [
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: Version(4, 0, 0))
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
