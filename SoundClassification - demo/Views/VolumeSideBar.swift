//
//  VolumeSideBar.swift
//  SoundClassification - demo
//
//  Created by Kathan Lunagariya on 16/11/21.
//

import Foundation
import UIKit

class VolumeSideBar: UIView{
    
    let stack:UIStackView = {
        
        let s = UIStackView()
        s.axis = .horizontal
        s.distribution = .fill
        s.spacing = 15
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    let downVolumeImage:UIImageView = {
      
        let img = UIImageView()
        img.image = UIImage(systemName: "volume.1.fill")
        img.contentMode = .scaleAspectFit
        img.tintColor = .systemTeal
        return img
    }()
    
    let volumeSlider:UISlider = {
       
        let slider = UISlider()
        slider.value = 0.65
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.minimumTrackTintColor = .systemTeal
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    let upVolumeImage:UIImageView = {
      
        let img = UIImageView()
        img.image = UIImage(systemName: "volume.3.fill")
        img.contentMode = .scaleAspectFit
        img.tintColor = .systemTeal
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(downVolumeImage)
        stack.addArrangedSubview(volumeSlider)
        stack.addArrangedSubview(upVolumeImage)
        self.addSubview(stack)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor, constant: 7),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 7),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -7),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -7)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
