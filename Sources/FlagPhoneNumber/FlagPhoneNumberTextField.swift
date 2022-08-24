//
//  FlagPhoneNumberTextField.swift
//  FlagPhoneNumber
//
//  Created by Aurélien Grifasi on 06/08/2017.
//  Copyright (c) 2017 Aurélien Grifasi. All rights reserved.
//

import PhoneNumberKit
import UIKit

open class FPNTextField: UITextField {

    private lazy var phoneNumberKit = PhoneNumberKit()
    private lazy var partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit)

    private var phoneNumber: PhoneNumber?

    open override var text: String? {
        set {
            if let newValue = newValue {
                let formattedNumber = partialFormatter.formatPartial(newValue)
                super.text = formattedNumber
            } else {
                super.text = newValue
            }
        }
        get {
            return super.text
        }
    }

    /// Present in the placeholder an example of a phone number according to the selected country code.
    /// If false, you can set your own placeholder. Set to true by default.
    public var hasPhoneNumberExample: Bool = true {
        didSet {
            if hasPhoneNumberExample == false {
                placeholder = nil
            }
            updatePlaceholder()
        }
    }

    public var selectedCountry: FPNCountry? {
        didSet {
            updateUI()
        }
    }

    /// Input Accessory View for the texfield
    public var textFieldInputAccessoryView: UIView?

    init() {
        super.init(frame: .zero)

        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        keyboardType = .phonePad
        autocorrectionType = .no
        addTarget(self, action: #selector(didEditText), for: .editingChanged)
    }

    // - Public

    /// Get the current formatted phone number
    public func getFormattedPhoneNumber(format: PhoneNumberFormat) -> String? {
        guard let phoneNumber = phoneNumber else {
            return nil
        }

        return phoneNumberKit.format(phoneNumber, toType: format)
    }

    /// Get the current raw phone number
    public func getRawPhoneNumber() -> String? {
        phoneNumber?.adjustedNationalNumber()
    }

    /// Set directly the phone number. e.g "+33612345678"
    public func set(phoneNumber: String) {
        let cleanedPhoneNumber: String = clean(string: phoneNumber)

        if let validPhoneNumber = getValidNumber(phoneNumber: cleanedPhoneNumber) {
            if validPhoneNumber.leadingZero {
                text = "0\(validPhoneNumber.nationalNumber)"
            } else {
                text = "\(validPhoneNumber.nationalNumber)"
            }
        }
    }

    public func getPhoneCountryCode(fromPhoneNumber phoneNumber: String) -> String? {
        let cleanedPhoneNumber: String = clean(string: phoneNumber)

        if let validPhoneNumber = getValidNumber(phoneNumber: cleanedPhoneNumber) {
            return "\(validPhoneNumber.countryCode)"
        }

        return nil
    }

    // Private

    @objc private func didEditText() {
        if let phoneCode = selectedCountry?.phoneCode, let number = text {
            let cleanedPhoneNumber = clean(string: "\(phoneCode) \(number)")

            if let validPhoneNumber = getValidNumber(phoneNumber: cleanedPhoneNumber) {
                phoneNumber = validPhoneNumber

                (delegate as? FPNTextFieldDelegate)?.fpnDidValidatePhoneNumber(textField: self, isValid: true)
            } else {
                phoneNumber = nil

                (delegate as? FPNTextFieldDelegate)?.fpnDidValidatePhoneNumber(textField: self, isValid: false)
            }
        }
    }

    private func updateUI() {
        setNeedsLayout()
        layoutIfNeeded()

        if hasPhoneNumberExample == true {
            updatePlaceholder()
        }
        didEditText()
    }

    private func clean(string: String) -> String {
        var allowedCharactersSet = CharacterSet.decimalDigits

        allowedCharactersSet.insert("+")

        return string.components(separatedBy: allowedCharactersSet.inverted).joined(separator: "")
    }

    private func getValidNumber(phoneNumber: String) -> PhoneNumber? {
        guard let countryCode = selectedCountry?.code else { return nil }

        do {
            let parsedPhoneNumber: PhoneNumber = try phoneNumberKit.parse(phoneNumber, withRegion: countryCode.rawValue)
            let isValid = phoneNumberKit.isValidPhoneNumber(parsedPhoneNumber.numberString)

            return isValid ? parsedPhoneNumber : nil
        } catch _ {
            return nil
        }
    }

    private func updatePlaceholder() {
        if let countryCode = selectedCountry?.code,
        let example = phoneNumberKit.getExampleNumber(forCountry: countryCode.rawValue) {
            placeholder = phoneNumberKit.format(example, toType: .national)
        } else {
            placeholder = nil
        }
    }
}
