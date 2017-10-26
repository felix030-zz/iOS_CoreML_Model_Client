//
//  ViewController.swift
//  FanFinder
//
//  Created by Felix E. C. Klemke on 10.10.17.
//  Copyright © 2017 Navitas GmbH. All rights reserved.
//
import UIKit
import CoreML
import Vision
import AVFoundation

class ViewController: UIViewController, FrameExtractorDelegate {
    
    var frameExtractor: FrameExtractor!
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var iSee: UILabel!
    @IBOutlet weak var detect: UILabel!
    
    
    var settingImage = false
    
    var currentImage: CIImage? {
        didSet {
            if let image = currentImage{
                self.detectScene(image: image)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
    }
    
    func captured(image: UIImage) {
        self.previewImage.image = image
        if let cgImage = image.cgImage, !settingImage {
            settingImage = true
            DispatchQueue.global(qos: .userInteractive).async {[unowned self] in
                self.currentImage = CIImage(cgImage: cgImage)
            }
        }
    }

    func detectScene(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: MobileNet().model) else {
            fatalError()
        }
        // Create a Vision request with completion handler
        let request = VNCoreMLRequest(model: model) { [unowned self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let _ = results.first else {
                    self.settingImage = false
                    return
            }
            
            DispatchQueue.main.async { [unowned self] in
                if let first = results.first {
                    if Int(first.confidence * 100) > 1 {
                        self.detect.text = "Detecting \(first.identifier)"
                        self.settingImage = false
                    }
                }
                results.forEach({ (result) in
                    if Int(result.confidence * 100) > 1 {
                        self.settingImage = false
                        //                            print("\(Int(result.confidence * 100))% it's \(result.identifier) ")
                        self.iSee.text = "\(Int(result.confidence * 100))% it's \(result.identifier) "
                    }
                })
                //                 print("********************************")                
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
}

