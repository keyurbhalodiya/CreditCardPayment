//
//  MockURLProtocol.swift
//  CreditCardPayment
//
//  Created by Bhalodiya, Keyur | ECMPD on 2025/11/01.
//

import Foundation

final class MockURLProtocol: URLProtocol {

    nonisolated(unsafe) static var stub: Stub?

    struct Stub {
        let data: Data?
        let response: HTTPURLResponse?
        let error: Error?
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let stub = MockURLProtocol.stub else { return }

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            let response = stub.response ?? HTTPURLResponse(
                url: request.url!,
                statusCode: stub.response?.statusCode ?? 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = stub.data ?? Data()
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}
