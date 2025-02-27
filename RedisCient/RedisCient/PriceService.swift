//
//  PrecioService.swift
//  RedisCient
//
//  Created by Javier Calatrava on 26/2/25.
//

import Foundation

struct Product: Codable, Identifiable, Sendable {
    var id: String { product }
    let product: String
    var price: String
}

@MainActor
class PriceService: ObservableObject {
    @Published var products: [Product] = []

    func fetchPrices() async {
        guard let url = URL(string: "http://localhost:3000/prices") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            if let productos = try? decoder.decode([Product].self, from: data) {
                self.products = productos
            }
        } catch {
            print("Error fetching prices:", error)
        }
    }

    func updatePrice(product: String, price: String) async {
        guard let url = URL(string: "http://localhost:3000/price") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["product": product, "price": price]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        do {
            let (_, _) = try await URLSession.shared.data(for: request)
            await self.fetchPrices()
        } catch {
            print("Error updating price: \(error.localizedDescription)")
        }
    }
}

