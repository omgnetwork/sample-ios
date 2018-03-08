# OmiseGO iOS sample

The OmiseGO iOS sample app is a simple example app not a “real-world” application.
It was only created to show how the [iOS SDK](https://github.com/omisego/ios-sdk) can be integrated by using all the available features.

It is a simple clothing shop where people can buy t-shirts and get loyalty points. Since it’s just a sample app, there is no checkout flow or actual payments.

The currency used is the Thai Baht (฿). The loyalty points received are OMGs (because we created that sample minted token on the demo eWallet, they are not actual OMG tokens and could be anything else defined on the server ;))

---
# Requirements

- iOS 10.0+
- Xcode 9+
- Swift 4.0

---

# Installation

The OmiseGO iOS SDK is added as a dependency using [CocoaPods](http://cocoapods.org).
Setup the workspace using:

```bash
$ pod install
```

---

# Tests

Run the tests using `CMD+U`

__DISCLAIMER: This sample app is not fully tested because our resources are better spent on core projects. At this point the app only has simple tests on view models.__

Feel free to submit PR's including more tests!!

---

# Contributing

See [how you can help](.github/CONTRIBUTING.md).

---

# License

The OmiseGO iOS sample is released under the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).
