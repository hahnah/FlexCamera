//
//  ViewController.swift
//  FlexCamera
//
//  Copyright © 2019年 hahnah. All rights reserved.
//

import UIKit
import FlexibleAVCapture
import Photos

class ViewController: UIViewController, FlexibleAVCaptureDelegate {
    
    var flexibleAVCaptureVC: FlexibleAVCaptureViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.checkCameraAuthorization(completion: {
            self.checkMicrophoneAuthorization(completion: {
                self.setupFlexibleAVCaptureView()
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func didCapture(withFileURL fileURL: URL) {
        // check whether photo library access is authorized
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    self.saveMovieToPhotoLibrary(fromURL: fileURL)
                } else if status == .denied {
                    let title: String = "Failed to save movie"
                    let message: String = "Allow this app to access Photo Library."
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (_) -> Void in
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                            return
                        }
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    })
                    let closeAction: UIAlertAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
                    alert.addAction(settingsAction)
                    alert.addAction(closeAction)
                    self.flexibleAVCaptureVC?.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            self.saveMovieToPhotoLibrary(fromURL: fileURL)
        }
    }
    
    private func setupFlexibleAVCaptureView() {
        self.flexibleAVCaptureVC =  FlexibleAVCaptureViewController(cameraPosition: .back)
        self.flexibleAVCaptureVC?.delegate = self
        self.flexibleAVCaptureVC?.maximumRecordDuration = CMTimeMake(value: 60, timescale: 1)
        self.flexibleAVCaptureVC?.minimumFrameRatio = 0.16
        if self.flexibleAVCaptureVC?.canSetVideoQuality(.high) ?? false {
            self.flexibleAVCaptureVC?.setVideoQuality(.high)
        }
        
        if let flexibleAVCVC = self.flexibleAVCaptureVC {
            self.present(flexibleAVCVC, animated: true, completion: nil)
        }
    }
    
    private func checkCameraAuthorization(completion: (() -> ())?) {
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { isPermitted in
                if isPermitted {
                    completion?()
                } else {
                    let title: String = "Failed to access camera"
                    let message: String = "Allow this app to access camera."
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (_) -> Void in
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                            return
                        }
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    })
                    let closeAction: UIAlertAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
                    alert.addAction(settingsAction)
                    alert.addAction(closeAction)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            completion?()
        }
    }
    
    private func checkMicrophoneAuthorization(completion: (() -> ())?) {
        if AVCaptureDevice.authorizationStatus(for: .audio) != .authorized {
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { isPermitted in
                if isPermitted {
                    completion?()
                } else {
                    let title: String = "Failed to access microphone"
                    let message: String = "Allow this app to access microphone."
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (_) -> Void in
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                            return
                        }
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    })
                    let closeAction: UIAlertAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
                    alert.addAction(settingsAction)
                    alert.addAction(closeAction)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            completion?()
        }
    }
    
    private func saveMovieToPhotoLibrary(fromURL fileURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
        }) { saved, error in
            DispatchQueue.main.async {
                let success = saved && (error == nil)
                let title = success ? "Success" : "Error"
                let message = success ? "Movie saved." : "Failed to save movie."
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                self.flexibleAVCaptureVC?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}
