import Foundation

public protocol FPNCountryPickerDelegate: AnyObject {
	func countryPhoneCodePicker(_ picker: FPNCountryPicker, didSelectCountry country: FPNCountry)
}
