//
//  PreviewView.swift
//  LipLearner_release
//
//  Created by Zixiong Su on 2023/02/06.
//  Copyright © 2023 Rekimoto Lab. All rights reserved.
//

import UIKit
import AVKit

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    init(_ session: AVCaptureSession) {
        super.init(frame: .zero)
        
        previewLayer.session = session
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AVPictureInPictureVideoCallViewController {
    
    convenience init(_ previewView: PreviewView, preferredContentSize: CGSize) {
        
        // Initialize.
        self.init()
        
        // Set the preferredContentSize.
        self.preferredContentSize = preferredContentSize
        
        // Configure the PreviewView.
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.frame = self.view.frame
        
        self.view.addSubview(previewView)
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: self.view.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
}
