//
//  TMDBNetworkingClient.swift
//  MoviesNetwork
//
//  Created by User on 9/10/25.
//

import Foundation
import Combine

/// HTTP client for TMDB API operations
public final class TMDBNetworkingClient: TMDBNetworkingClientProtocol, Sendable {
    private let session: URLSession
    private let networkingConfig: NetworkingConfig
    private let decoder: JSONDecoder

    public init(session: URLSession = TMDBNetworkingClient.configuredSession(), networkingConfig: NetworkingConfig) {
        self.session = session
        self.networkingConfig = networkingConfig

        // Configure decoder for TMDB API
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    public func request<T: Decodable>(_ endpoint: EndpointProtocol) -> AnyPublisher<T, Error> {
        guard let url = buildURL(for: endpoint) else {
            return Fail(error: TMDBNetworkingError.invalidURL)
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add endpoint-specific headers
        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return session.dataTaskPublisher(for: request)
            .tryMap { output in
                if let httpResponse = output.response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
                    throw TMDBNetworkingError.httpError(httpResponse.statusCode)
                }
                return output.data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                if let tmdbError = error as? TMDBNetworkingError {
                    return tmdbError
                }
                if let decodingError = error as? DecodingError {
                    return TMDBNetworkingError.decodingError(decodingError)
                }
                return TMDBNetworkingError.networkError(error)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Convenience session factory
    public static func configuredSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }

    private func buildURL(for endpoint: EndpointProtocol) -> URL? {
        var components = URLComponents()
        components.scheme = networkingConfig.baseURL.scheme
        components.host = networkingConfig.baseURL.host
        components.path = networkingConfig.apiBaseURL.appendingPathComponent(endpoint.path).path

        var queryItems = endpoint.queryParameters
        queryItems.append(URLQueryItem(name: "api_key", value: networkingConfig.apiKey))

        components.queryItems = queryItems

        return components.url
    }
}
