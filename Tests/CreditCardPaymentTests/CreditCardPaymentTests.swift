import XCTest
@testable import CreditCardPayment

@available(iOS 13.0, *)
final class CreditCardManagerTests: XCTestCase {

    private enum Constants {
        static let urlString = "https://komoju.com/api/v1/payments"
    }
    
    private struct DummyResponse: Codable {
        let status: String
    }

    var manager: CreditCardManager!
    var requestInfo: PaymentRequestInfo!
    
    override func setUp() {
        super.setUp()
        manager = CreditCardManager.manager
        requestInfo = PaymentRequestInfo(amount: 1000,
                                             currency: "JPY",
                                             paymentDetails: PaymentDetails(type: "credit_card", number: "3530111333300000", month: "11", year: "2030", verificationValue: "242"),
                                             fraudDetails: FraudDetails(customerIP: "192.16.1.1", customerEmail: "customer@email.comm")
        )
    }

    func testSuccessfulPayment() async throws {
        let dummy = DummyResponse(status: "paid")
        MockURLProtocol.stub = MockURLProtocol.Stub(
            data: try JSONEncoder().encode(dummy),
            response: HTTPURLResponse(url: URL(string: Constants.urlString)!,
                                      statusCode: 200,
                                      httpVersion: nil,
                                      headerFields: nil),
            error: nil
        )

        await manager.setSession(makeMockSession())
        await manager.configure(apiKey: "TEST_KEY")
        
        let result: DummyResponse = try await manager.createPayment(requestInfo, as: DummyResponse.self)

        XCTAssertEqual(result.status, "paid")
    }

    func testAPIError() async throws {
        MockURLProtocol.stub = MockURLProtocol.Stub(
            data: "{\"error\":\"Unauthorized\"}".data(using: .utf8),
            response: HTTPURLResponse(url: URL(string: Constants.urlString)!,
                                      statusCode: 401,
                                      httpVersion: nil,
                                      headerFields: nil),
            error: nil
        )

        await manager.setSession(makeMockSession())
        await manager.configure(apiKey: "TEST_KEY")

        do {
            let _: DummyResponse = try await manager.createPayment(requestInfo, as: DummyResponse.self)
            XCTFail("Expected API error")
        } catch TransactionError.apiError(let status, _) {
            XCTAssertEqual(status, 401)
        }
    }

    func testMissingAPIKey() async throws {
        MockURLProtocol.stub = MockURLProtocol.Stub(
            data: "{\"error\":\"Unauthorized\"}".data(using: .utf8),
            response: HTTPURLResponse(url: URL(string: Constants.urlString)!,
                                      statusCode: 401,
                                      httpVersion: nil,
                                      headerFields: nil),
            error: nil
        )
        
        await manager.setSession(makeMockSession())
        await manager.configure(apiKey: "")

        do {
            let _: DummyResponse = try await manager.createPayment(requestInfo, as: DummyResponse.self)
            XCTFail("Expected missing API key error")
        } catch TransactionError.missingAPIKey {
            // success
        }
    }

    func testDecodingError() async throws {
        MockURLProtocol.stub = MockURLProtocol.Stub(
            data: "invalid json".data(using: .utf8),
            response: HTTPURLResponse(url: URL(string: Constants.urlString)!,
                                      statusCode: 200,
                                      httpVersion: nil,
                                      headerFields: nil),
            error: nil
        )

        await manager.setSession(makeMockSession())
        await manager.configure(apiKey: "TEST_KEY")

        do {
            let _: DummyResponse = try await manager.createPayment(requestInfo, as: DummyResponse.self)
            XCTFail("Expected decoding error")
        } catch TransactionError.decodingError(_) {
            // success
        }
    }

    func testNetworkFailure() async throws {
        MockURLProtocol.stub = MockURLProtocol.Stub(
            data: nil,
            response: nil,
            error: URLError(.notConnectedToInternet)
        )

        await manager.setSession(makeMockSession())
        await manager.configure(apiKey: "TEST_KEY")

        do {
            let _: DummyResponse = try await manager.createPayment(requestInfo, as: DummyResponse.self)
            XCTFail("Expected network error")
        } catch {
            // success
        }
    }
    
    private func makeMockSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }
}

