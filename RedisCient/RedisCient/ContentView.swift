//
//  ContentView.swift
//  RedisCient
//
//  Created by Javier Calatrava on 26/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var precioService = PriceService()
    @State private var productoSeleccionado: Product?
    @State private var nuevoPrecio: String = ""

    var body: some View {
        NavigationView {
            List(precioService.products) { producto in
                HStack {
                    Text(producto.product)
                    Spacer()
                    Text("$\(producto.price)")
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    // Selecciona el producto para actualizar su precio
                    productoSeleccionado = producto
                    nuevoPrecio = producto.price
                }
            }
            .onAppear {
                Task {
                   await precioService.fetchPrices()
                }
            }
            .navigationTitle("Precios de Productos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                           await precioService.fetchPrices()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(item: $productoSeleccionado) { producto in
                // Hoja para actualizar el precio
                VStack {
                    Text("Actualizar Precio")
                        .font(.headline)
                        .padding()
                    TextField("Nuevo Precio", text: $nuevoPrecio)
                        .keyboardType(.decimalPad)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Actualizar Precio") {
                        if let producto = productoSeleccionado {
                            Task { [nuevoPrecio] in
                               await precioService.updatePrice(product: producto.product, price: nuevoPrecio)
                            }
                            productoSeleccionado = nil // Cerrar el formulario
                            nuevoPrecio = "" // Limpiar el campo
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
