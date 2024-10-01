//
//  FlagPhoneNumberDelegate.swift
//  FlagPhoneNumber
//
//  Created by Aurélien Grifasi on 06/08/2017.
//  Copyright (c) 2017 Aurélien Grifasi. All rights reserved.
//

import Foundation

public protocol FPNDelegate: AnyObject {
	func fpnDidSelect(country: FPNCountry)
}
