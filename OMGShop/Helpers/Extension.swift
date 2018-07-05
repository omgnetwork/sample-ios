//
//  Extension.swift
//  OMGShop
//
//  Created by Mederic Petit on 20/10/17.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import BigInt
import OmiseGO

func dispatchMain(_ block: @escaping EmptyClosure) {
    DispatchQueue.main.async { block() }
}

extension Token {
    func formattedAmount(forAmount amountString: String?) -> BigInt? {
        guard let amountString = amountString else { return nil }
        return OMGNumberFormatter().number(from: amountString, subunitToUnit: self.subUnitToUnit)
    }
}

extension User {
    var formattedUsername: String {
        return String(self.username.split(separator: "|").first ?? "")
    }
}

extension UIColor {
    static func color(fromHexString: String, alpha: CGFloat? = 1.0) -> UIColor {
        let hexint = Int(colorInteger(fromHexString: fromHexString))
        let red = CGFloat((hexint & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xFF) >> 0) / 255.0
        let alpha = alpha!
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)

        return color
    }

    private static func colorInteger(fromHexString: String) -> UInt32 {
        var hexInt: UInt32 = 0
        let scanner: Scanner = Scanner(string: fromHexString)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt32(&hexInt)

        return hexInt
    }
}

extension String {
    func isValidEmailAddress() -> Bool {
        let regex = try? NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
                                             options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil
    }

    func isValidPassword() -> Bool {
        return self.count >= 8
    }

    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

extension UITableView {
    public func registerNib(tableViewCell: UITableViewCell.Type) {
        self.register(UINib(nibName: String(describing: tableViewCell), bundle: nil),
                      forCellReuseIdentifier: String(describing: tableViewCell))
    }

    public func registerNibs(tableViewCells: [UITableViewCell.Type]) {
        tableViewCells.forEach { tableViewCell in
            self.registerNib(tableViewCell: tableViewCell)
        }
    }
}

extension UITableViewCell {
    class func identifier() -> String {
        return String(describing: self)
    }
}

extension UIImageView {
    func downloaded(from url: URL?) {
        guard let url = url else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}

extension Double {
    func displayablePrice(withSubunitToUnitCount subUnitToUnit: Double = 100) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.currencyCode = "THB"
        formatter.currencySymbol = "฿"
        let displayableAmount: Double = self / subUnitToUnit
        return formatter.string(from: NSNumber(value: displayableAmount)) ?? ""
    }
}

extension UIViewController {
    class func newInstance<T: UIViewController>(fromStoryboard storyboard: Storyboard) -> T? {
        let identifier = String(describing: self)

        return UIStoryboard(name: storyboard.name, bundle: nil).instantiateViewController(withIdentifier:
            identifier) as? T
    }
}

extension Date {
    func toString(withFormat format: String? = "dd MMM yyyy HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}

extension UIView {
    func addDropShadow(withColor color: UIColor, offset: CGSize, opacity: Float, radius: CGFloat) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
}

extension UITextField {
    func addNextInputView(withOnNextSelector selector: Selector, target: Any) {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 44))
        accessoryView.backgroundColor = .white
        let nextButton = UIButton(type: .custom)
        nextButton.setTitle("global.next".localized(), for: .normal)
        nextButton.titleLabel?.font = Font.avenirMedium.withSize(17)
        nextButton.setTitleColor(.black, for: .normal)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(target,
                             action: selector,
                             for: .touchUpInside)
        accessoryView.addSubview(nextButton)
        [.top, .trailing, .bottom].forEach {
            accessoryView.addConstraint(NSLayoutConstraint(item: accessoryView,
                                                           attribute: $0,
                                                           relatedBy: .equal,
                                                           toItem: nextButton,
                                                           attribute: $0,
                                                           multiplier: 1,
                                                           constant: 0))
        }
        nextButton.addConstraints([
            NSLayoutConstraint(item: nextButton,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1,
                               constant: 100),
            NSLayoutConstraint(item: nextButton,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1,
                               constant: 44)
        ])
        self.inputAccessoryView = accessoryView
    }
}
