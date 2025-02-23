import SwiftUI
import PhotosUI
import Vision
import CoreML

struct ContentView: View {
    @StateObject var imagePicker = ImagePicker()
    @StateObject var imageClassifier = ImageClassifier()
    
    // Controla si estamos analizando
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationStack {
            VStack {
                // Si hay una imagen seleccionada
                if let pickedImage = imagePicker.image {
                    pickedImage
                        .resizable()
                        .scaledToFit()
                    
                    if isAnalyzing {
                        Text("Analizando imagen...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                        
                    } else {
                        Text("Reconocimiento: \(imageClassifier.result)")
                            .font(.headline)
                            .padding()
                        
                        Button("Analizar Imagen") {
                            isAnalyzing = true
                            Task {
                                // Convertir el Image de SwiftUI a UIImage
                                // VOLVEMOS a cargar la imagen como 'Data' desde 'imageSelection'
                                if let data = try? await imagePicker.imageSelection?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    // Clasificamos con Core ML
                                    imageClassifier.classify(image: uiImage)
                                }
                                isAnalyzing = false
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                } else {
                    Text("Elige una foto para analizar.")
                }
            }
            .padding()
            .navigationTitle("Reconocimiento")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotosPicker(selection: $imagePicker.imageSelection) {
                        Image(systemName: "photo")
                            .imageScale(.large)
                    }
                }
            }
        }
    }
}

// Clase para manejar la clasificación de imágenes con Core ML
class ImageClassifier: ObservableObject {
    @Published var result: String = "Esperando imagen..."
    private var model: VNCoreMLModel?

    init() {
        do {
            let config = MLModelConfiguration()
            // Asegúrate de tener 'MobileNetV2.mlmodel' en tu proyecto
            let coreMLModel = try MobileNetV2(configuration: config).model
            model = try VNCoreMLModel(for: coreMLModel)
        } catch {
            print("Error cargando modelo CoreML: \(error)")
        }
    }

    func classify(image: UIImage) {
        guard let model = model,
              let ciImage = CIImage(image: image) else {
            DispatchQueue.main.async {
                self.result = "Error al procesar la imagen."
            }
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            DispatchQueue.main.async {
                if let results = request.results as? [VNClassificationObservation],
                   let firstResult = results.first {
                    self.result = "\(firstResult.identifier) (\(Int(firstResult.confidence * 100))%)"
                } else {
                    self.result = "No se pudo reconocer la imagen."
                }
            }
        }

        // Procesamos la imagen en una cola de alta prioridad
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.result = "Error en la clasificación: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct SingleImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
