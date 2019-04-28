//
//  MemeDetailsViewController.swift
//  MemeMe App
//
//  Created by Mawhiba Al-Jishi on 22/08/1440 AH.
//  Copyright © 1440 Udacity. All rights reserved.
//

import Foundation
import UIKit

class MemeDetailsViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var mImage: Meme!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.imageView.image = mImage.memedImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}
