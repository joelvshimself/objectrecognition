import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var isShowingImageView = false
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack {
            Text("Selecciona una imagen")
                .font(.title)
                .padding()
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("Elegir de la galería 📷")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .onChange(of: selectedItem) { oldItem, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                            isShowingImageView = true
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingImageView) {
            if let selectedImage = selectedImage {
                ImageView(image: selectedImage)
            }
        }
    }
}

struct ImageView: View {
    @Environment(\.dismiss) var dismiss
    let image: UIImage
    
    var body: some View {
        VStack {
            Text("Imagen seleccionada")
                .font(.title)
                .padding()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 400)
                .padding()
            
            Button("Volver") {
                dismiss()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
