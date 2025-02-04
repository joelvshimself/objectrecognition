//
//  ContentView.swift
//  objectrecognition
//
//  Created by Joel Vargas on 04/02/25.
//

import SwiftUI


struct ContentView: View {
    
    @State var tocado : Bool = false
    
    
    
    
    var body: some View {
        VStack{
            Button(action: {
                self.tocado.toggle()
                print("Escanear")
            }) {
                Text("Escanear")
            }
            
            Button(action: {
                self.tocado.toggle()
                print("Importar")
            }) {
                Text("Importar")
            }
        }
        
    }
}

#Preview {
    ContentView()
}
