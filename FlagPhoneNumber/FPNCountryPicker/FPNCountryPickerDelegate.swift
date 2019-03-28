import Foundation

public protocol FPNCountryPickerDelegate: class {
	func countryPhoneCodePicker(_ picker: FPNCountryPicker, didSelectCountry country: FPNCountry)
}
