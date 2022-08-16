// swift-tools-version:5.0

 import PackageDescription

 let package = Package(
     name: "FlagPhoneNumber",
     platforms: [.macOS(.v10_10), .iOS(.v8)],
     products: [
         .library(name: "FlagPhoneNumber", targets: ["FlagPhoneNumber"]),
     ],
     dependencies: [
        .package(url: "https://github.com/iziz/libPhoneNumber-iOS.git", .exactItem("0.9.16")),
     ],
     targets: [
         .target(
            name: "FlagPhoneNumber",
            dependencies: ["libPhoneNumber"],
            path: "FlagPhoneNumber"),
     ]
 )
