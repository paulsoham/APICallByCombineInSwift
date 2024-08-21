//
//  Model.swift
//  APICallByURLSession
//
//  Created by sohamp on 21/08/24.
//

struct Todo: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let completed:Bool
}
