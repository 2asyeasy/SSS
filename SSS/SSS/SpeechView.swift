//
//  SpeechView.swift
//  SampleProject
//
//  Created by Khai on 2020/05/27.
//  Copyright © 2020 NUBiz Inc. All rights reserved.
//

import UIKit

protocol SpeechViewDelegate {
    func startRecoding()
    func stopRecoding()
    func dismiss()
}

class SpeechView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var recodingImageView: UIImageView!
    @IBOutlet var recodingButton: UIButton!
    @IBOutlet var recodingLabel: UILabel!
    
    private var delegate: SpeechViewDelegate?
    private var isRecoding: Bool = false
    private var isAnimating: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    public func setDelegate(_ delegate: SpeechViewDelegate?) {
        self.delegate = delegate
    }
    
    private func initialize() {
        Bundle.main.loadNibNamed("SpeechView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
     
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        emptyView.addGestureRecognizer(tapGesture)
        
        recodingImageView.isUserInteractionEnabled = false
    }

    private func showAnimation() {
        if isRecoding {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                self.isAnimating = !self.isAnimating
                self.recodingButton.setImage(UIImage(named: self.isAnimating ? "btn_speech_on" : "btn_speech_off"), for: .normal)
                self.showAnimation()
            })
        }
        else {
            DispatchQueue.main.async {
                self.recodingButton.setImage(UIImage(named: "btn_speech_off"), for: .normal)
            }
        }
    }
    
    @IBAction func onButtonPressed(_ sender: UIButton) {
        if sender.tag == 101 {
            isRecoding = !isRecoding
            if delegate != nil {
                if isRecoding {
                    delegate?.startRecoding()
                }
                else {
                    delegate?.stopRecoding()
                }
                self.showAnimation()
            }
        }
    }
    
    @objc
    private func dismiss() {
        if delegate != nil {
            delegate?.stopRecoding()
            delegate?.dismiss()
        }
    }
}
