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
        s.axis = .vertical
        s.distribution = .fill
        s.spacing = 15
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    let volumeImage:UIImageView = {
      
        let img = UIImageView()
        let config = UIImage.SymbolConfiguration.preferringMulticolor()
        img.image = UIImage(systemName: "volume.3.fill", variableValue: 0.65, configuration: config)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(volumeImage)
        stack.addArrangedSubview(volumeSlider)
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
