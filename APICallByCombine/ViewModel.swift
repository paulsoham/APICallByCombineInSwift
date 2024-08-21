//
//  ViewModel.swift
//  APICallByURLSession
//
//  Created by sohamp on 21/08/24.
//

import Combine

class ViewModel {
    private let apiService: APIService
//    private(set) var todo: [Todo] = []
//    var onError: ((String) -> Void)?
//    var onUpdate: (() -> Void)?
    private var cancellables = Set<AnyCancellable>() // Added for Combine
    @Published private(set) var todos: [Todo] = [] // Added for Combine
    @Published private(set) var error: String? // Added for Combine
    
    // Dependency Injection
    init(apiService:APIService = URLSessionAPIService()){
        self.apiService = apiService
    }
    
    /*func fetchTodos() {
        apiService.fetchDataByUrlSession(from: "https://jsonplaceholder.typicode.com/todos") {[weak self] (result:Result<[Todo],APIError>) in
            DispatchQueue.main.async {
                switch  result {
                case .success(let todo):
                    self?.todo = todo
                    self?.onUpdate?()
                    
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
            
        }
    }*/
    
    func fetchTodos() {
           apiService.fetchDataByUrlSession(from: "https://jsonplaceholder.typicode.com/todos")
               .sink(receiveCompletion: { [weak self] completion in
                   switch completion {
                   case .failure(let apiError):
                       self?.error = apiError.localizedDescription
                   case .finished:
                       break
                   }
               }, receiveValue: { [weak self] todos in
                   self?.todos = todos
               })
               .store(in: &cancellables)
       }
}
