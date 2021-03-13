

import Foundation
import UIKit

class Utilities {
    
    static func styleTextField(_ textfield:UITextField, _ color: CGColor) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = color
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        
    }
    
    static func styleFilledButton(_ button:UIButton,_ color: UIColor,_ textColor: UIColor) {
        
        // Filled rounded corner style
        button.backgroundColor = color
        button.layer.cornerRadius = 25.0
        button.tintColor = textColor
    }
    
    static func styleHollowButton(_ button:UIButton,_ borderColor: UIColor,_ textColor: UIColor, _ backgroundColor:UIColor) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 2
//        button.backgroundColor = backgroundColor
        button.layer.borderColor = borderColor.cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = textColor
    }
    
    
}
