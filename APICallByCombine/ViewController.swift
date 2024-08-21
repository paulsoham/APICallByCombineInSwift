//
//  ViewController.swift
//  APICallByCombine
//
//  Created by sohamp on 21/08/24.
//

import UIKit
import Combine

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var sampleTableView: UITableView!
    private var viewModel: ViewModel
    private var cancellables = Set<AnyCancellable>() // Added for Combine

    // Dependency Injection
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = ViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        viewModel.fetchTodos()
    }
    
    
   /* private func setupBindings(){
        viewModel.onUpdate = { [weak self] in
            self?.sampleTableView.reloadData()
        }
        viewModel.onError = { [weak self] errorMessage in
            self?.showErrorAlert(message: errorMessage)
        }
    }*/

    
    private func setupBindings() {
        viewModel.$todos
            .receive(on: DispatchQueue.main) // Ensure updates are received on the main thread
            .sink { [weak self] _ in
                guard let self = self else { return }
                // Reload data on the main thread
                self.sampleTableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$error
            .receive(on: DispatchQueue.main) // Ensure error handling is done on the main thread
            .sink { [weak self] errorMessage in
                if let message = errorMessage {
                    self?.showErrorAlert(message: message)
                }
            }
            .store(in: &cancellables)
    }



    
    private func showErrorAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.todos.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell (style: .subtitle, reuseIdentifier: "cell")
        let todo = viewModel.todos[indexPath.row]
        cell.textLabel?.text = todo.title
        cell.detailTextLabel?.text = todo.completed ? "Completed" : "Not Completed"
        return cell
    }

}


