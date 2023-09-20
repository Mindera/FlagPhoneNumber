// swift-tools-version: 5.6

 import PackageDescription

 let package = Package(
     name: "FlagPhoneNumber",
     platforms: [.macOS(.v12), .iOS(.v14)],
     products: [
         .library(name: "FlagPhoneNumber", targets: ["FlagPhoneNumber"]),
     ],
     dependencies: [
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", from: Version(3, 7, 0))
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
