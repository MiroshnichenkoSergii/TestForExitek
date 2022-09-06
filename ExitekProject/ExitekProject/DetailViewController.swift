//
//  DetailViewController.swift
//  ExitekProject
//
//  Created by Sergii Miroshnichenko on 05.09.2022.
//

import UIKit

class DetailViewController: UIViewController {
    var selectedMobile: String?
    var selectedImei: String?

    @IBOutlet var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        infoLabel.text = selectedImei!
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
