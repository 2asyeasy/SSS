//
//  ViewController.swift
//  SSS
//
//  Created by Seonggwan Mun on 2022/11/18.
//

import UIKit
import Speech

class ViewController: UIViewController {

    @IBOutlet var controllerButton: UIButton!
    @IBOutlet var speechTextView: UITextView!
    
    //  Speech
    private var speechView: SpeechView!
    private let audioEngine = AVAudioEngine()
    
    //  Locale - https://gist.github.com/ndbroadbent/588fefab8e0f1b459fcec8181b41b39c
    private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var request: SFSpeechAudioBufferRecognitionRequest!
    private var recognitionTask: SFSpeechRecognitionTask?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onButtonPressed(_ sender: UIButton) {
        if sender.tag == 101 {
            //  show or hide controller
            showSpeechView()
        }
    }
}

extension ViewController: SFSpeechRecognizerDelegate {
        
    //  MARK: - SFSpeechRecognizerDelegate
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            self.showSpeechAlert(alertType: .functionError)
        }
    }
    
    //  MARK: - Info.plist >>> NSSpeechRecognitionUsageDescription, NSMicrophoneUsageDescription
    func checkPermission(isAuthorized: @escaping (Bool) -> Void) -> Void {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    isAuthorized(true)
                }
                else {
                    isAuthorized(false)
                }
            }
        }
    }

    //  Error Alert Type
    enum SpeechAlertType {
        case permissionDenied
        case functionError
    }

    func showSpeechAlert(alertType: SpeechAlertType) -> Void {
        let message = alertType == .permissionDenied ? "SFSpeechRecognizer-permission denied." : "SFSpeechRecognizer is not available."
        let ac = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { (action) in
            
        }
        ac.addAction(ok)
        self.navigationController?.present(ac, animated: true, completion: nil)
    }
}

extension ViewController: SpeechViewDelegate {
    
    func showSpeechView() -> Void {
        checkPermission(isAuthorized: { (granted) in
            if granted {
                self.speechView = SpeechView(frame: self.view.bounds)
                self.speechView.setDelegate(self)
                self.view.addSubview(self.speechView)
            }
            else {
                self.showSpeechAlert(alertType: .permissionDenied)
            }
        })
    }
    
    func startRecoding() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        request = SFSpeechAudioBufferRecognitionRequest()
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        }
        catch {
            print(error.localizedDescription)
        }

        guard let recognizer = SFSpeechRecognizer() else {
            return
        }

        if !recognizer.isAvailable {
            return
        }

        recognitionTask?.finish()
        recognitionTask = nil
        if recognitionTask == nil {
            recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
                if let result = result {
                    let bestString = result.bestTranscription.formattedString
                    self.speechTextView.text = bestString

                    for segment in result.bestTranscription.segments {
                        let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                        //lastString = bestString.substring(from: indexTo)
                        
                        //  MARK: - https://stackoverflow.com/a/46617119
                        let lastString = String(bestString[indexTo...])
                    }
                }
                else if let error = error {
                    //  MARK: - The operation couldn’t be completed. (kAFAssistantErrorDomain error 216.)
                }
            })
        }
        else {
            stopRecoding()
            startRecoding()
        }
    }
    
    func stopRecoding() {
        //  MARK: - kAFAssistantErrorDomain error 216.
        //  https://stackoverflow.com/a/46294296
        
        if audioEngine.isRunning {
            let node = audioEngine.inputNode
            node.removeTap(onBus: 0)
            node.reset()
            audioEngine.stop()
            request.endAudio()
            if let task = recognitionTask {
                switch task.state {
                case .starting:
                    
                    break
                case .running:
                    task.cancel()

                    break
                case .completed:
                    
                    break
                case .canceling:
                    
                    break
                case .finishing:
                    
                    break
                default:
                    
                    break
                }
            }
            recognitionTask = nil
            request = nil
        }
    }
    
    func dismiss() {
        if speechView != nil {
            speechView.removeFromSuperview()
            speechView.setDelegate(nil)
            speechView = nil
        }
    }
}
