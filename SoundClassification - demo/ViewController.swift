//
//  ViewController.swift
//  SoundClassification - demo
//
//  Created by Kathan Lunagariya on 16/11/21.
//

import UIKit
import AVFAudio
import SoundAnalysis

class ViewController: UIViewController {
    
    //MARK: SOUND - CLASSIFICATION...
    let audioEngine = AVAudioEngine()
    
    var inputFormat:AVAudioFormat! = nil
    
    var streamAnalyzer: SNAudioStreamAnalyzer!
    let lbl = "speech"  //cheering, shout, yell, laughter etc.
    
    //MARK: OBJECTS...
    let header:UILabel = {
       
        let lbl = UILabel()
        lbl.text = "experience the Smart-Audio mode..."
        lbl.textAlignment = .center
        lbl.font = .preferredFont(forTextStyle: .largeTitle)
        lbl.numberOfLines = 0
        lbl.adjustsFontSizeToFitWidth = true
        
        lbl.textColor = .white
        lbl.backgroundColor = .systemTeal
        
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 7
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let volumeBar = VolumeSideBar()
    
    let playButton:UIButton = {
       
        let btn = UIButton()
        btn.configuration = .tinted()
        btn.configuration?.image = UIImage(systemName: "play.circle.fill")
        btn.configuration?.cornerStyle = .capsule
        btn.tintColor = .systemTeal
        
        let config = UIImage.SymbolConfiguration(scale: .large)
        btn.configuration?.preferredSymbolConfigurationForImage = config
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let smartAudioButton:UIButton = {
       
        let btn = UIButton()
        btn.configuration = .tinted()
        btn.configuration?.image = UIImage(systemName: "music.quarternote.3")
        btn.configuration?.title = "Smart Audio Mode"
        btn.configuration?.subtitle = "not enabled"
        btn.configuration?.cornerStyle = .capsule
        btn.tintColor = .systemTeal
        btn.configuration?.imagePadding = 25
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var currentSliderValue:Float = 0.65
    var isSomeoneSpeaking = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(header)
        view.addSubview(volumeBar)
        view.addSubview(playButton)
        view.addSubview(smartAudioButton)
        
        volumeBar.volumeSlider.addTarget(self, action: #selector(didChangeSlider(sender:)), for: .valueChanged)
        playButton.addTarget(self, action: #selector(didTapPlayBtn), for: .touchUpInside)
        smartAudioButton.addTarget(self, action: #selector(didTapSmartAudioBtn), for: .touchUpInside)
        
        MusicManager.sharedInstance.setUp()
    }
    
    
    @objc func didChangeSlider(sender:UISlider){
        currentSliderValue = sender.value
        MusicManager.sharedInstance.player?.volume = sender.value
        volumeBar.volumeImage.image = UIImage(systemName: "volume.3.fill", variableValue: Double(sender.value))
    }
    
    @objc func didTapPlayBtn(){
        
        guard let player = MusicManager.sharedInstance.player else {
            print("player found nil...")
            return
        }
        
        if player.isPlaying{
            player.stop()
            player.prepareToPlay()
            playButton.configuration?.image = UIImage(systemName: "play.circle.fill")
        }else{
            player.play()
            playButton.configuration?.image = UIImage(systemName: "pause.circle.fill")
        }
    }
    
    @objc func didTapSmartAudioBtn(){
        
        if audioEngine.isRunning{
            DispatchQueue.main.async {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.smartAudioButton.configuration?.subtitle = "not enabled"
            }
        }else{
            startAudioEngine()
            
            DispatchQueue.main.async {
                self.smartAudioButton.configuration?.subtitle = "enabled"
            }
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([
            header.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            header.widthAnchor.constraint(equalToConstant: 200),
            header.heightAnchor.constraint(equalToConstant: 200),
            
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            
            volumeBar.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 25),
            volumeBar.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -25),
            volumeBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            volumeBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            smartAudioButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            smartAudioButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            smartAudioButton.widthAnchor.constraint(equalToConstant: 200),
            smartAudioButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    

    func startAudioEngine(){
        inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { granted in
            
            if !granted{
                print("first allow to use microphone...")
            }
            else{
                
                do{
                    try self.audioEngine.start()
                    
                    self.audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: self.inputFormat) { buffer, time in
                        self.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
                    }
                    
                    self.streamAnalyzer = SNAudioStreamAnalyzer(format: self.inputFormat)
                    
                    let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
                    try self.streamAnalyzer.add(request, withObserver: self)
                    
                }catch{
                    print(error)
                }
                
            }
            
        }
    }

}


extension ViewController: SNResultsObserving{
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        
        guard let res = result as? SNClassificationResult else {
            print("can't convert to SNClassificationResult...")
            return
        }
        
        guard let classification = res.classification(forIdentifier: self.lbl) else {
            print("can't classified sound...")
            return
        }
        
        if classification.confidence > 0.5{
            print("\(self.lbl) - \(classification.confidence)")
            
            DispatchQueue.main.async {
                self.isSomeoneSpeaking = true
            }
        }else{
            DispatchQueue.main.async {
                self.isSomeoneSpeaking = false
            }
        }
        
        handleSlider()
    }
    
    
    func handleSlider(){
        
        guard let player = MusicManager.sharedInstance.player else {
            print("player found nil...")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
            if self.isSomeoneSpeaking && player.isPlaying{
                let volume = self.getDecreasedVolume(player: player)
                UIView.animate(withDuration: 2) {
                    self.volumeBar.volumeSlider.setValue(volume, animated: true)
                }completion: { _ in
                    player.volume = volume
                    self.volumeBar.volumeImage.image = UIImage(systemName: "volume.3.fill", variableValue: Double(volume))
                }
            }
            else{
                UIView.animate(withDuration: 2) {
                    self.volumeBar.volumeSlider.setValue(self.currentSliderValue, animated: true)
                }completion: { _ in
                    player.volume = self.currentSliderValue
                    self.volumeBar.volumeImage.image = UIImage(systemName: "volume.3.fill", variableValue: Double(self.currentSliderValue))
                }
            }
        }
    }
    
    func getDecreasedVolume(player:AVAudioPlayer) -> Float{
        let volume = player.volume
        
        if volume >= 0.75{
            return 0.45
        }
        else if volume <= 0.35{
            return volume
        }
        else{
            return volume - 0.20 < 0.35 ? 0.35 : volume-0.20
        }
    }
}
