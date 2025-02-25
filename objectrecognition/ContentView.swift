import SwiftUI
import PhotosUI
import Vision
import CoreML

struct ContentView: View {
    @StateObject var imagePicker = ImagePicker()
    @State private var navigateToRecognizer = false
    @State private var selectedImage: UIImage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {

                // 🔹 Botón de Escanear (Ícono negro)
                Button {
                    // Aquí podrías agregar funcionalidad para escanear con la cámara
                } label: {
                    VStack {
                        Image(systemName: "camera.viewfinder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.black) // 🔹 Icono en negro
                        Text("Escanear")
                            .font(.title3)
                            .foregroundColor(.black) 
                    }
                }
                .buttonStyle(.plain)

                // 🔹 PhotosPicker para importar imagen (Ícono negro)
                PhotosPicker(selection: $imagePicker.imageSelection, matching: .images) {
                    VStack {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.black) // 🔹 Icono en negro
                        Text("Importar")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                }
                .onChange(of: imagePicker.imageSelection) { _, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage  // 🔹 Guarda la imagen como UIImage antes de navegar
                            navigateToRecognizer = true  // 🔹 Activa la navegación
                        }
                    }
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationDestination(isPresented: $navigateToRecognizer) {
                if let selectedImage {
                    Recognizer(uiImage: selectedImage)
                }
            }
        }
    }
}
