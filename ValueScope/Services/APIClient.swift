import Foundation

/// 网络请求基础层
actor APIClient {
    static let shared = APIClient()

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        return URLSession(configuration: config)
    }()

    func fetch<T: Decodable>(_ url: URL, type: T.Type) async throws -> T {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw APIError.badResponse
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func fetchData(_ url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw APIError.badResponse
        }
        return data
    }
}

enum APIError: Error, LocalizedError {
    case badResponse
    case invalidData
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .badResponse: "服务器响应异常"
        case .invalidData: "数据解析失败"
        case .networkError(let e): "网络错误: \(e.localizedDescription)"
        }
    }
}
