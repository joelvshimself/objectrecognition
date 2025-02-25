import SwiftUI

struct FirstView: View {
    var body: some View {
        VStack(spacing: 100) { // Ajusta el espaciado según lo necesites
            VStack {
                Image(systemName: "camera.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60) // Ajusta el tamaño del icono
                Text("Escanear")
                    .font(.title3)
            }
            
            VStack {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60) // Ajusta el tamaño del icono
                Text("Importar")
                    .font(.title3)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Para centrar los elementos en la pantalla
    }
}

#Preview {
    FirstView()
}
