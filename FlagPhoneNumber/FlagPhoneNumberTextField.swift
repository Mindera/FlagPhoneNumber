//
//  FlagPhoneNumberTextField.swift
//  FlagPhoneNumber
//
//  Created by Aurélien Grifasi on 06/08/2017.
//  Copyright (c) 2017 Aurélien Grifasi. All rights reserved.
//

import Foundation
import libPhoneNumber_iOS

open class FPNTextField: UITextField, FPNCountryPickerDelegate, FPNDelegate {

    /// Color of the items on the picker view
    public var pickerViewToolbarTintColor: UIColor?

    /// Title for *Done* button. If *nil* it will use the default one
    public var pickerViewDoneTitle: String?

    private var dropDownButton = UIButton()

    private var phoneCodeTextField: UITextField = UITextField()
    private lazy var countryPicker: FPNCountryPicker = FPNCountryPicker()
    private lazy var phoneUtil: NBPhoneNumberUtil = NBPhoneNumberUtil()
    private var nbPhoneNumber: NBPhoneNumber?
    private var formatter: NBAsYouTypeFormatter?

    public var flagView: UIImageView = UIImageView(image: UIImage(named: "AD"))
    public var dropDownIcon: UIImageView = UIImageView(image: UIImage(named: "dropDownArrow"))

    open override var font: UIFont? {
        didSet {
            phoneCodeTextField.font = font
        }
    }

    open override var textColor: UIColor? {
        didSet {
            phoneCodeTextField.textColor = textColor
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

    /// If set, a search button appears in the picker inputAccessoryView to present a country search view controller
    @IBOutlet public var parentViewController: UIViewController?

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

    deinit {
        parentViewController = nil
    }

    private func setup() {
        setupFlagButton()
        setupDropDownIcon()
        setupPhoneCodeTextField()
        setupLeftView()
        setupCountryPicker()

        keyboardType = .phonePad
        autocorrectionType = .no
        addTarget(self, action: #selector(didEditText), for: .editingChanged)
        addTarget(self, action: #selector(displayNumberKeyBoard), for: .touchDown)
    }

    private func setupFlagButton() {
        flagView.contentMode = .scaleAspectFit
        flagView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupPhoneCodeTextField() {
        phoneCodeTextField.isUserInteractionEnabled = false
        phoneCodeTextField.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupDropDownIcon() {
        dropDownButton.addTarget(self, action: #selector(displayCountryKeyboard), for: .touchUpInside)
        dropDownButton.translatesAutoresizingMaskIntoConstraints = false

        dropDownIcon.contentMode = .scaleAspectFit
        dropDownIcon.translatesAutoresizingMaskIntoConstraints = false
    }

    private let flagViewWidth: CGFloat = 32.0
    private let dropDownIconWidth: CGFloat = 10.0
    private let rightPadding: CGFloat = 5.0

    open override func layoutSubviews() {
        super.layoutSubviews()
        var phoneSize: CGFloat = 55
        if phoneCodeTextField.text?.count == 2 { // +1
            phoneSize = 24
        } else if phoneCodeTextField.text?.count == 3 { // +23
            phoneSize = 35
        } else if phoneCodeTextField.text?.count == 4 { // +334
            phoneSize = 45
        }
        leftView?.frame = CGRect(origin: .zero, size: CGSize(width: flagViewWidth + phoneSize + dropDownIconWidth + rightPadding, height: bounds.height))
    }

    private func setupLeftView() {
        leftViewMode = .always
        let view = UIView()
        view.addSubview(flagView)
        view.addSubview(phoneCodeTextField)
        view.addSubview(dropDownIcon)
        view.addSubview(dropDownButton)

        leftView = view

        guard let leftView = leftView else { return }
        if #available(iOS 9.0, *) {
            flagView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor).isActive = true
            flagView.leftAnchor.constraint(equalTo: leftView.leftAnchor).isActive = true
            flagView.widthAnchor.constraint(equalToConstant: flagViewWidth).isActive = true

            phoneCodeTextField.centerYAnchor.constraint(equalTo: leftView.centerYAnchor).isActive = true
            phoneCodeTextField.leftAnchor.constraint(equalTo: flagView.rightAnchor).isActive = true

            dropDownIcon.widthAnchor.constraint(equalToConstant: dropDownIconWidth).isActive = true
            dropDownIcon.leftAnchor.constraint(equalTo: phoneCodeTextField.rightAnchor).isActive = true
            dropDownIcon.centerYAnchor.constraint(equalTo: leftView.centerYAnchor).isActive = true

            dropDownButton.leftAnchor.constraint(equalTo: leftView.leftAnchor).isActive = true
            dropDownButton.rightAnchor.constraint(equalTo: leftView.rightAnchor).isActive = true
            dropDownButton.topAnchor.constraint(equalTo: leftView.topAnchor).isActive = true
            dropDownButton.bottomAnchor.constraint(equalTo: leftView.bottomAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
    }

    private func setupCountryPicker() {
        countryPicker.countryPickerDelegate = self
        countryPicker.showPhoneNumbers = true
        countryPicker.backgroundColor = .white

        if let regionCode = Locale.current.regionCode, let countryCode = FPNCountryCode(rawValue: regionCode) {
            countryPicker.setCountry(countryCode)
        } else if let firstCountry = countryPicker.countries.first {
            countryPicker.setCountry(firstCountry.code)
        }
    }

    @objc private func displayNumberKeyBoard() {
        inputView = nil
        inputAccessoryView = textFieldInputAccessoryView
        tintColor = pickerViewToolbarTintColor ?? .gray
        reloadInputViews()
    }

    @objc private func displayCountryKeyboard() {
        inputView = countryPicker
        inputAccessoryView = getToolBar(with: getCountryListBarButtonItems())
        tintColor = pickerViewToolbarTintColor ?? .clear
        reloadInputViews()
        becomeFirstResponder()
    }

    @objc private func displayAlphabeticKeyBoard() {
        showSearchController()
    }

    @objc private func resetKeyBoard() {
        inputView = nil
        inputAccessoryView = nil
        resignFirstResponder()
    }

    // - Public

    /// Set the country image according to country code. Example "FR"
    public func setFlag(for countryCode: FPNCountryCode) {
        countryPicker.setCountry(countryCode)
    }

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
            setFlag(for: FPNCountryCode(rawValue: phoneUtil.getRegionCode(for: validPhoneNumber))!)
        }
    }

    /// Set the country list excluding the provided countries
    public func setCountries(excluding countries: [FPNCountryCode]) {
        countryPicker.setup(without: countries)
    }

    /// Set the country list including the provided countries
    public func setCountries(including countries: [FPNCountryCode]) {
        countryPicker.setup(with: countries)
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

        flagView.image = selectedCountry?.flag
        setNeedsLayout()
        layoutIfNeeded()

        if let phoneCode = selectedCountry?.phoneCode {
            phoneCodeTextField.text = phoneCode
            layoutSubviews()
        }

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

    private func showSearchController() {
        if let countries = countryPicker.countries {
            let searchCountryViewController = FPNSearchCountryViewController(countries: countries)
            let navigationViewController = UINavigationController(rootViewController: searchCountryViewController)

            searchCountryViewController.delegate = self

            parentViewController?.present(navigationViewController, animated: true, completion: nil)
        }
    }

    private func getToolBar(with items: [UIBarButtonItem]) -> UIToolbar {
        let toolbar: UIToolbar = UIToolbar()

        toolbar.barStyle = UIBarStyle.default
        if let toolbarColor = pickerViewToolbarTintColor {
            toolbar.tintColor = toolbarColor
        }
        toolbar.items = items
        toolbar.sizeToFit()

        return toolbar
    }

    private func getCountryListBarButtonItems() -> [UIBarButtonItem] {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        var doneButton: UIBarButtonItem
        if let doneTitle = pickerViewDoneTitle {
            doneButton = UIBarButtonItem(title: doneTitle, style: .done, target: self, action: #selector(resetKeyBoard))
        } else {
            doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resetKeyBoard))
        }

        doneButton.accessibilityLabel = "doneButton"

        if parentViewController != nil {
            let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(displayAlphabeticKeyBoard))

            searchButton.accessibilityLabel = "searchButton"

            return [searchButton, space, doneButton]
        }
        return [space, doneButton]
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

    // - FPNCountryPickerDelegate

    func countryPhoneCodePicker(_ picker: FPNCountryPicker, didSelectCountry country: FPNCountry) {
        (delegate as? FPNTextFieldDelegate)?.fpnDidSelectCountry(name: country.name, dialCode: country.phoneCode, code: country.code.rawValue)
        selectedCountry = country
    }

    // - FPNDelegate

    internal func fpnDidSelect(country: FPNCountry) {
        setFlag(for: country.code)
    }
}
