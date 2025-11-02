# 💳 CreditCardManager SPM Package

`CreditCardManager` is a lightweight Swift Package designed to simplify **credit card payments** in your iOS applications using the [Komoju Payments API](https://doc.komoju.com/docs/creating-payments-directly#method-2-creating-a-payment-directly/).  
Simply integrate the package into your project, configure it with your API key, and start processing payments securely.

---

## 🚀 Features

- ✅ Simple and clean API for creating credit card payments  
- 🔒 Secure basic authentication  
- ⚙️ Configurable `URLSession` for testing or custom networking  
- 🧩 Fully asynchronous using Swift Concurrency (`async/await`)  
- 🧾 Generic decoding for custom response models  
- 📦 Distributed as a Swift Package for easy integration

---

## 📦 Installation

### Using Swift Package Manager

You can add this package directly from Xcode:

1. In Xcode, go to **File > Add Packages...**  
2. Enter the package URL: https://github.com/yourusername/CreditCardManager.git
3. Choose the latest version and add it to your project.

Or, add it manually in your `Package.swift`:

```swift
dependencies: [
 .package(url: "https://github.com/yourusername/CreditCardManager.git", from: "1.0.0")
]
```

## 🧠 Usage

1. Import the Package
```swift
import CreditCardManager
```

2. Configure the Manager
```swift
await CreditCardManager.manager.configure(apiKey: "your_komoju_api_key")
```

3. Make a Payment
Call ```createPayment(_:as:)``` with your request and expected response type


## ⚠️ Error Handling
The package includes a built-in TransactionError enum for common issues:

- `missingAPIKey` – API key not configured
- `invalidResponse` – Response from the server was invalid
- `apiError(statusCode:message:)` – API returned an error
- `decodingError(Error)` – Failed to decode response


## 🔐 Security Note
- Always store your API keys securely (e.g., in Keychain or remote configuration).
- Never hardcode sensitive information in your app or repository.
- Use HTTPS (already handled in the base URL).
