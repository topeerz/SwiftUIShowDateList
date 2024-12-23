//
//  DateService.swift
//  SwiftUIShowDateList
//
//  Created by topeerz on 27/08/2024.
//

import Foundation

protocol DateServiceProtocol {
    func getDate() async throws -> CurrnetDate?
}

struct DateService: DateServiceProtocol {

    private var urlSession: URLSession?

    init(urlSession: URLSession?) {
        self.urlSession = urlSession
    }

    func getDate() async throws -> CurrnetDate? {
        guard let url = URL(string: "https://aluminum-accidental-tray.glitch.me/testme") else {
            fatalError("url failed")
        }

        guard let urlSession = urlSession else {
            // TODO: add error handling?
            fatalError("url session doesn't exist")
        }

        // TODO: handle response error statuses?
        let (data, response) = try await urlSession.data(from: url)
        return try? JSONDecoder().decode(CurrnetDate.self, from: data)
    }
}
