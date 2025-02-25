//
//  ImageClassifier.swift
//  objectrecognition
//
//  Created by Joel Vargas on 24/02/25.
//

import Foundation
import Vision
import CoreML
import UIKit

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

