//
//  MusicManager.swift
//  SoundClassification - demo
//
//  Created by Kathan Lunagariya on 16/11/21.
//

import Foundation
import AVFoundation

public class MusicManager{
    
    public static let sharedInstance = MusicManager()
    var player:AVAudioPlayer?
    
    private init() { }
    
    public func setUp(){
        let musicURL = Bundle.main.url(forResource: "bgmusic", withExtension: "mp3")!
        
        do{
            player = try AVAudioPlayer(contentsOf: musicURL)
            guard player != nil else{
                print("player is nil...")
                return
            }
            
            player!.volume = 0.65
            player!.prepareToPlay()
            //player!.play()
            
        }catch{
            print(error)
            print("falied to play...")
        }
    }
    
    public func play(){
        player?.play()
    }
    
    public func stop(){
        player?.stop()
        player?.prepareToPlay()
    }
}
