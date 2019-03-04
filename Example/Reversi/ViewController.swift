//
//  ViewController.swift
//  Reversi
//
//  Created by popei69 on 02/28/2019.
//  Copyright (c) 2019 popei69. All rights reserved.
//

import UIKit
import Reversi

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton! 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.addVariations()
    }
    
    func setupViews() {
        
        label.text = "Hello World"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .darkGray
        
        button.setTitle("Click me", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
    }
    
    func addVariations() {
        
        // label color
        label.addVariation("text_variation") { label, value in
            label.isHidden = value
        }
        
        // button color
        button.addVariation("button_variation") { button, _ in
            button.backgroundColor = .orange
        }
          
        // combined elements
        self.addVariation("combined_variation") { viewController, _ in
            viewController.label.textColor = .lightGray
            viewController.button.setTitleColor(.lightGray, for: .normal)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

