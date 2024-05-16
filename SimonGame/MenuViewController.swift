//
//  MenuViewController.swift
//  SimonGame
//
//  Created by Daksh on 10/11/2023.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var playersField: UITextField!
    var totalPlayers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func playButton(_ sender: Any) {
        playersField.resignFirstResponder()
        if let players = Int(playersField.text!) {
            totalPlayers = players
        }
    }
    
    @IBAction func segueToGame(_ sender: Any) {
        if (totalPlayers > 0 && totalPlayers < 6) {
            performSegue(withIdentifier: "toGame", sender: self)
        }
    }
    
    
    @IBAction func unwindToMenu(_ unwindSegue: UIStoryboardSegue) {
       let _ = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGame" {
            let ViewController = segue.destination as! ViewController
            ViewController.numOfPlayers = totalPlayers
        }
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
