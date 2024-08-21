//
//  URLSessionAPIService.swift
//  APICallByURLSession
//
//  Created by sohamp on 21/08/24.
//

import Foundation
import Combine

enum APIError: Error, LocalizedError {
    case networkError(URLError)
    case decodingError(Error)
    case invalidURL
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return error.localizedDescription
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .invalidURL:
            return "The URL is invalid."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}


protocol APIService {
    // Generic
    //func fetchDataByUrlSession<T:Codable>(from url:String,completion: @escaping(Result<T,APIError>) -> Void)
    func fetchDataByUrlSession<T: Codable>(from url: String) -> AnyPublisher<T, APIError>

}


class URLSessionAPIService:APIService {
    private let session: URLSession
    
    // Dependency Injection
    init(session:URLSession = .shared) {
        self.session = session
    }
    
    // Protocol
     /* func fetchDataByUrlSession<T:Codable>(from url: String, completion: @escaping (Result<T, APIError>) -> Void){
            guard let url = URL(string:url) else {
                completion(.failure(.invalidURL))
                return
            }
            
            let task = session.dataTask(with: url) { data, response, error in
                    if let error = error as? URLError {
                        completion(.failure(.networkError(error)))
                        return
                    }
                    
                    guard let data = data else {
                        completion(.failure(.unknownError))
                        return
                    }
                    
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(decodedData))
                    } catch {
                        completion(.failure(.decodingError(error)))
                    }
            }
            task.resume()
    }*/
    
    func fetchDataByUrlSession<T: Codable>(from url: String) -> AnyPublisher<T, APIError> {
           guard let url = URL(string: url) else {
               return Fail(error: .invalidURL).eraseToAnyPublisher()
           }

           return session.dataTaskPublisher(for: url)
               .map(\.data)
               .decode(type: T.self, decoder: JSONDecoder())
               .mapError { error in
                   // Convert URLSession and decoding errors to APIError
                   if let urlError = error as? URLError {
                       return .networkError(urlError)
                   } else if let decodingError = error as? DecodingError {
                       return .decodingError(decodingError)
                   } else {
                       return .unknownError
                   }
               }
               .eraseToAnyPublisher()
       }
    
    
}
