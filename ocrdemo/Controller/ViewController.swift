//
//  ViewController.swift
//  ocrdemo
//
//  Created by Gabriel Figueroa on 8/21/18.
//  Copyright © 2018 Gabriel Figueroa. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController, G8TesseractDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        view.endEditing(true)
        presentImagePicker()
    }
    
    func performImageRecognition(_ image: UIImage) {
        
        if let tesseract = G8Tesseract(language: "eng") {
            
            tesseract.engineMode = .tesseractCubeCombined
            tesseract.pageSegmentationMode = .auto
            tesseract.image = image.g8_blackAndWhite()
            tesseract.recognize()
            textView.text = tesseract.recognizedText
        }
        activityIndicator.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    
    func presentImagePicker() {
        
        let scanningOptionActionController = UIAlertController(title: "Choose scanning option",
                                                          message:nil, preferredStyle: .actionSheet)
        let ocrAlertAction = UIAlertAction(title: "OCR Scanner",
                                           style: .default){ (action: UIAlertAction) -> Void in
                                            let ocrActionController = UIAlertController(title: "OCR Scanner", message: "Choose scanning method", preferredStyle: .actionSheet)
                                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                                let cameraButton = UIAlertAction(title: "Scan using camera", style: .default)
                                                    let imagePicker = UIImagePickerController()
                                                    imagePicker.delegate = self
                                                    imagePicker.sourceType = .camera
                                                    self.present(imagePicker, animated: true)
                                                    ocrActionController.addAction(cameraButton)
                                            }
                                            let libraryButton = UIAlertAction(title: "Choose existing", style: .default) { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .photoLibrary
                                            self.present(imagePicker, animated: true)
                                            }
                                            ocrActionController.addAction(libraryButton)
                                            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
                                            ocrActionController.addAction(cancelButton)
                                            self.present(ocrActionController, animated: true)
        }
        scanningOptionActionController.addAction(ocrAlertAction)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        scanningOptionActionController.addAction(cancelButton)
        self.present(scanningOptionActionController, animated: true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let scaledImage = selectedPhoto.scaleImage(640) {
            activityIndicator.startAnimating()
            dismiss(animated: true, completion: {
                self.performImageRecognition(scaledImage)
                
            })
        }
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}

extension UIImage {
    
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
        
    }
}


