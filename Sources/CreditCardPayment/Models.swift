//
//  Models.swift
//  CreditCardPayment
//
//  Created by Bhalodiya, Keyur | ECMPD on 2025/11/01.
//

import Foundation

// MARK: - PaymentRequestInfo
public struct PaymentRequestInfo: Codable {

    public let amount: Int
    public let currency: String
    public let paymentDetails: PaymentDetails?
    public let fraudDetails: FraudDetails?
    
    enum CodingKeys: String, CodingKey {
        case amount, currency
        case paymentDetails = "payment_details"
        case fraudDetails = "fraud_details"
    }
    
    public init(amount: Int, currency: String, paymentDetails: PaymentDetails, fraudDetails: FraudDetails) {
        self.amount = amount
        self.currency = currency
        self.paymentDetails = paymentDetails
        self.fraudDetails = fraudDetails
    }
}

// MARK: - PaymentDetails
public struct PaymentDetails: Codable {
    public let type: String
    public let number: String
    public let month: String
    public let year: String
    public let verificationValue: String
    
    public init(type: String, number: String, month: String, year: String, verificationValue: String) {
        self.type = type
        self.number = number
        self.month = month
        self.year = year
        self.verificationValue = verificationValue
    }
}

// MARK: - FraudDetails
public struct FraudDetails: Codable {
    public let customerIP: String
    public let customerEmail: String
    
    enum CodingKeys: String, CodingKey {
        case customerIP = "customer_ip"
        case customerEmail = "customer_email"
    }
    
    public init(customerIP: String, customerEmail: String) {
        self.customerIP = customerIP
        self.customerEmail = customerEmail
    }
}
