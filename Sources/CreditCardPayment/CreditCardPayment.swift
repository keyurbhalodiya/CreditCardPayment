import Foundation

// MARK: - CreditCardManager
@available(iOS 13.0.0, *)
public final actor CreditCardManager {
    
    public static let manager = CreditCardManager()
    
    private init() {}
    
    private let baseURL = URL(string: "https://komoju.com/api/v1/payments")!
    private var apiKey: String?
    private var session: URLSession = .shared
    
    public func configure(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func setSession(_ session: URLSession) {
        self.session = session
    }
    
    /// Generic async version that returns any Decodable type
    public func createPayment<T: Decodable>(_ request: PaymentRequestInfo, as type: T.Type) async throws -> T {
        guard let apiKey = apiKey, apiKey.isEmpty == false else {
            throw TransactionError.missingAPIKey
        }
        
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = RequestMethod.post.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Basic auth header
        let credentials = "\(apiKey):"
        let base64Credentials = Data(credentials.utf8).base64EncodedString()
        urlRequest.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        // Encode JSON body
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        // Perform network request
        let (data, response) = try await session.data(for: urlRequest)
        
        // Check status code
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TransactionError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw TransactionError.apiError(statusCode: httpResponse.statusCode, message: message)
        }
        
        // Decode response
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw TransactionError.decodingError(error)
        }
    }
}

// MARK: - RequestMethod
private enum RequestMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - TransactionError
private enum TransactionError: Error, LocalizedError {
    case missingAPIKey
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key not configured."
        case .invalidResponse:
            return "Invalid server response."
        case .apiError(let statusCode, let message):
            return "API Error \(statusCode): \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
