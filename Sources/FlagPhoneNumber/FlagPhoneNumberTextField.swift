//
//  FlagPhoneNumberTextField.swift
//  FlagPhoneNumber
//
//  Created by Aurélien Grifasi on 06/08/2017.
//  Copyright (c) 2017 Aurélien Grifasi. All rights reserved.
//

#if canImport(libPhoneNumber)
import libPhoneNumber
#elseif canImport(libPhoneNumber_iOS)
import libPhoneNumber_iOS
#endif

import UIKit

open class FPNTextField: UITextField {

    private lazy var phoneUtil: NBPhoneNumberUtil = NBPhoneNumberUtil()
    private var nbPhoneNumber: NBPhoneNumber?
    private var formatter: NBAsYouTypeFormatter?

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
    public func getFormattedPhoneNumber(format: FPNFormat) -> String? {
        return try? phoneUtil.format(nbPhoneNumber, numberFormat: convert(format: format))
    }

    /// Get the current raw phone number
    public func getRawPhoneNumber() -> String? {
        let phoneNumber = getFormattedPhoneNumber(format: .E164)
        var nationalNumber: NSString?

        phoneUtil.extractCountryCode(phoneNumber, nationalNumber: &nationalNumber)

        return nationalNumber as String?
    }

    /// Set directly the phone number. e.g "+33612345678"
    public func set(phoneNumber: String) {
        let cleanedPhoneNumber: String = clean(string: phoneNumber)

        if let validPhoneNumber = getValidNumber(phoneNumber: cleanedPhoneNumber) {
            if validPhoneNumber.italianLeadingZero {
                text = "0\(validPhoneNumber.nationalNumber.stringValue)"
            } else {
                text = validPhoneNumber.nationalNumber.stringValue
            }
        }
    }

    public func getPhoneCountryCode(fromPhoneNumber phoneNumber: String) -> String? {
        let cleanedPhoneNumber: String = clean(string: phoneNumber)

        if let validPhoneNumber = getValidNumber(phoneNumber: cleanedPhoneNumber) {
            return validPhoneNumber.countryCode.stringValue
        }

        return nil
    }

    // Private

    @objc private func didEditText() {
        if let phoneCode = selectedCountry?.phoneCode, let number = text {
            var cleanedPhoneNumber = clean(string: "\(phoneCode) \(number)")

            if let validPhoneNumber = getValidNumber(phoneNumber: cleanedPhoneNumber) {
                nbPhoneNumber = validPhoneNumber

                cleanedPhoneNumber = "+\(validPhoneNumber.countryCode.stringValue)\(validPhoneNumber.nationalNumber.stringValue)"

                if let inputString = formatter?.inputString(cleanedPhoneNumber) {
                    text = remove(dialCode: phoneCode, in: inputString)
                }
                (delegate as? FPNTextFieldDelegate)?.fpnDidValidatePhoneNumber(textField: self, isValid: true)
            } else {
                nbPhoneNumber = nil

                if let dialCode = selectedCountry?.phoneCode {
                    if let inputString = formatter?.inputString(cleanedPhoneNumber) {
                        text = remove(dialCode: dialCode, in: inputString)
                    }
                }
                (delegate as? FPNTextFieldDelegate)?.fpnDidValidatePhoneNumber(textField: self, isValid: false)
            }
        }
    }

    private func convert(format: FPNFormat) -> NBEPhoneNumberFormat {
        switch format {
        case .E164:
            return NBEPhoneNumberFormat.E164
        case .International:
            return NBEPhoneNumberFormat.INTERNATIONAL
        case .National:
            return NBEPhoneNumberFormat.NATIONAL
        case .RFC3966:
            return NBEPhoneNumberFormat.RFC3966
        }
    }

    private func updateUI() {
        if let countryCode = selectedCountry?.code {
            formatter = NBAsYouTypeFormatter(regionCode: countryCode.rawValue)
        }

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

    private func getValidNumber(phoneNumber: String) -> NBPhoneNumber? {
        guard let countryCode = selectedCountry?.code else { return nil }

        do {
            let parsedPhoneNumber: NBPhoneNumber = try phoneUtil.parse(phoneNumber, defaultRegion: countryCode.rawValue)
            let isValid = phoneUtil.isValidNumber(parsedPhoneNumber)

            return isValid ? parsedPhoneNumber : nil
        } catch _ {
            return nil
        }
    }

    private func remove(dialCode: String, in phoneNumber: String) -> String {
        return phoneNumber.replacingOccurrences(of: "\(dialCode) ", with: "").replacingOccurrences(of: "\(dialCode)", with: "")
    }

    private func updatePlaceholder() {
        if let countryCode = selectedCountry?.code {
            do {
                let example = try phoneUtil.getExampleNumber(countryCode.rawValue)
                let phoneNumber = "+\(example.countryCode.stringValue)\(example.nationalNumber.stringValue)"

                if let inputString = formatter?.inputString(phoneNumber) {
                    placeholder = remove(dialCode: "+\(example.countryCode.stringValue)", in: inputString)
                } else {
                    placeholder = nil
                }
            } catch _ {
                placeholder = nil
            }
        } else {
            placeholder = nil
        }
    }
}
