//
//  Models.swift
//  CreditCardPayment
//
//  Created by Bhalodiya, Keyur | ECMPD on 2025/11/01.
//

import Foundation

// MARK: - PaymentRequestInfo
public struct PaymentRequestInfo: Codable, Sendable {

    public let amount: Int
    public let currency: String
    public let paymentDetails: PaymentDetails?
    public let fraudDetails: FraudDetails?
    public let returnURL: String?
    public let capture: Bool?
    public let tax: Int?
    public let externalOrderNum: String?
    public let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case amount, currency, capture, tax, metadata
        case paymentDetails = "payment_details"
        case fraudDetails = "fraud_details"
        case returnURL = "return_url"
        case externalOrderNum = "external_order_num"
    }
    
    public init(amount: Int, currency: String, paymentDetails: PaymentDetails, fraudDetails: FraudDetails, returnURL: String? = nil, capture: Bool? = nil, tax: Int? = nil, externalOrderNum: String? = nil, metadata: [String: AnyCodable]? = nil) {
        self.amount = amount
        self.currency = currency
        self.paymentDetails = paymentDetails
        self.fraudDetails = fraudDetails
        self.returnURL = returnURL
        self.capture = capture
        self.tax = tax
        self.externalOrderNum = externalOrderNum
        self.metadata = metadata
    }
}

// MARK: - PaymentDetails
public struct PaymentDetails: Codable, Sendable {
    public let type: String
    public let number: String
    public let month: String
    public let year: String
    public let verificationValue: String
    public let name: String?
    
    public init(type: String, number: String, month: String, year: String, verificationValue: String, name: String? = nil) {
        self.type = type
        self.number = number
        self.month = month
        self.year = year
        self.verificationValue = verificationValue
        self.name = name
    }
}

// MARK: - FraudDetails
public struct FraudDetails: Codable, Sendable {
    public let customerIP: String
    public let customerEmail: String
    public let customerID: String?
    public let browserLanguage: String?
    public let browserUserAgent: String?
    public let browserSessionID: String?
    public let phone: String?
    
    enum CodingKeys: String, CodingKey {
        case customerIP = "customer_ip"
        case customerEmail = "customer_email"
        case customerID = "customer_id"
        case browserLanguage = "browser_language"
        case browserUserAgent = "browser_user_agent"
        case browserSessionID = "browser_session_id"
        case phone
    }
    
    public init(customerIP: String, customerEmail: String, customerID: String? = nil, browserLanguage: String? = nil, browserUserAgent: String? = nil, browserSessionID: String? = nil, phone: String? = nil) {
        self.customerIP = customerIP
        self.customerEmail = customerEmail
        self.customerID = customerID
        self.browserLanguage = browserLanguage
        self.browserUserAgent = browserUserAgent
        self.browserSessionID = browserSessionID
        self.phone = phone
    }
}

// MARK: - Helper to allow arbitrary JSON values
public struct AnyCodable: Codable, @unchecked Sendable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          if let intVal = try? container.decode(Int.self) {
              value = intVal
          } else if let doubleVal = try? container.decode(Double.self) {
              value = doubleVal
          } else if let boolVal = try? container.decode(Bool.self) {
              value = boolVal
          } else if let stringVal = try? container.decode(String.self) {
              value = stringVal
          } else if let dictVal = try? container.decode([String: AnyCodable].self) {
              value = dictVal
          } else if let arrayVal = try? container.decode([AnyCodable].self) {
              value = arrayVal
          } else {
              throw DecodingError.dataCorruptedError(in: container,
                                                     debugDescription: "Unsupported JSON value")
          }
      }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let intVal as Int: try container.encode(intVal)
        case let doubleVal as Double: try container.encode(doubleVal)
        case let boolVal as Bool: try container.encode(boolVal)
        case let stringVal as String: try container.encode(stringVal)
        case let dictVal as [String: AnyCodable]: try container.encode(dictVal)
        case let arrayVal as [AnyCodable]: try container.encode(arrayVal)
        default:
            throw EncodingError.invalidValue(value, .init(codingPath: encoder.codingPath, debugDescription: "Invalid JSON value"))
        }
    }
}
