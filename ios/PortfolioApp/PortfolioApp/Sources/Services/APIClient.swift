import Foundation

/// Errors the views can show directly (error.localizedDescription).
enum APIError: LocalizedError {
    case server(String)   // the API's own { "message": "..." }
    case network          // no internet, server down, timeout
    case unexpected       // response we couldn't read

    var errorDescription: String? {
        switch self {
        case .server(let message): message
        case .network: "Can't reach UniMate right now. Check your connection and try again."
        case .unexpected: "Something went wrong. Please try again."
        }
    }
}


/// The only place that knows the server address and talks HTTP.
struct APIClient {
    static let shared = APIClient()
    static let baseURL = URL(string: "https://unimate-dkrj.onrender.com")!

    /// GET a path like "/api/jobs?status=Open" and decode the JSON into T.
    func get<T: Decodable>(_ path: String) async throws -> T {
        let data = try await request("GET", path, body: nil)
        return try decode(data)
    }

    /// POST/PATCH with a JSON body, and decode the JSON reply into T.
    func send<T: Decodable>(_ method: String, _ path: String, body: some Encodable) async throws -> T {
        let data = try await request(method, path, body: body)
        return try decode(data)
    }

    /// POST/PATCH when the API replies 204 No Content (accept, complete, cancel...).
    func send(_ method: String, _ path: String, body: some Encodable) async throws {
        _ = try await request(method, path, body: body)
    }

    // MARK: - Private

    private func request(_ method: String, _ path: String, body: (any Encodable)?) async throws -> Data {
        guard let url = URL(string: path, relativeTo: Self.baseURL) else { throw APIError.unexpected }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 60 // Render's free tier can take ~1 min to wake up
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try Self.encoder.encode(body)
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.network
        }

        guard let http = response as? HTTPURLResponse else { throw APIError.unexpected }
        guard (200...299).contains(http.statusCode) else {
            let message = (try? Self.decoder.decode(ErrorMessage.self, from: data))?.message
            throw APIError.server(message ?? "Something went wrong (\(http.statusCode)).")
        }
        return data
    }

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            return try Self.decoder.decode(T.self, from: data)
        } catch {
            throw APIError.unexpected
        }
    }

    private struct ErrorMessage: Decodable {
        let message: String
    }

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { dateDecoder in
            let container = try dateDecoder.singleValueContainer()
            let text = try container.decode(String.self)
            // .NET sends "2026-10-16T04:23:44.4482501+00:00". Drop the fraction so
            // the standard ISO 8601 parser accepts it.
            let trimmed = text.replacingOccurrences(of: #"\.\d+"#, with: "", options: .regularExpression)
            guard let date = ISO8601DateFormatter().date(from: trimmed) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Bad date: \(text)")
            }
            return date
        }
        return decoder
    }()
}

