//
//  ViewController.swift
//  SimonGame
//
//  Created by Daksh on 09/11/2023.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    @IBOutlet weak var startGame: UIButton!
    @IBOutlet var soundButton: [UIButton]!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreCounter: UILabel!
    @IBOutlet weak var playersLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var currentGoalLabel: UILabel!
    
    // Declaring sound players for each button
    var redSoundButton:AVAudioPlayer!
    var yellowSoundButton:AVAudioPlayer!
    var blueSoundButton:AVAudioPlayer!
    var greenSoundButton:AVAudioPlayer!

    var roundNum = 1
    var sequenceLength = 10
    var numOfPlayers = 0
    var playerCount = 1
    var sequence = [Int]()
    var currentItemInSequence = 0
    var numOfClicks = 0
    var isReady = false
    var gameLost = true
    
    var score = 0
    // Persistent data storage to save high score across app sessions
    var highScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: "HighScore")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "HighScore")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSounds()
        updateHighScoreLabel()
    }
    
    //  Gets the mp3 files for each colour button and assigns it to the buttons
    func setupSounds() {
        
        let soundFilePath = Bundle.main.path(forResource: "red", ofType: "mp3")
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath!)
        
        let soundFilePath2 = Bundle.main.path(forResource: "yellow", ofType: "mp3")
        let soundFileURL2 = NSURL(fileURLWithPath: soundFilePath2!)
        
        let soundFilePath3 = Bundle.main.path(forResource: "blue", ofType: "mp3")
        let soundFileURL3 = NSURL(fileURLWithPath: soundFilePath3!)
        
        let soundFilePath4 = Bundle.main.path(forResource: "green", ofType: "mp3")
        let soundFileURL4 = NSURL(fileURLWithPath: soundFilePath4!)
        
        do {
            try redSoundButton = AVAudioPlayer(contentsOf: soundFileURL as URL)
            try yellowSoundButton = AVAudioPlayer(contentsOf: soundFileURL2 as URL)
            try blueSoundButton = AVAudioPlayer(contentsOf: soundFileURL3 as URL)
            try greenSoundButton = AVAudioPlayer(contentsOf: soundFileURL4 as URL)
        }
        catch
        {
            print("Error")
        }
        
        redSoundButton.delegate = self
        yellowSoundButton.delegate = self
        blueSoundButton.delegate = self
        greenSoundButton.delegate = self
        
        redSoundButton.numberOfLoops = 0
        yellowSoundButton.numberOfLoops = 0
        blueSoundButton.numberOfLoops = 0
        greenSoundButton.numberOfLoops = 0
        
    }
    
    // Generates sequence as per sequenceLength
    func generateSequence() {
        for _ in stride(from: 1, to: sequenceLength + 1, by: 1) {
            sequence.append(Int.random(in: 1..<5))
        }
        print(sequence)
    }
    
    // Game begins when play button is pressed
    @IBAction func startGame(_ sender: Any) {
        gameLost = false
        
        // For multiplayer
        if (numOfPlayers > 1) {
            playersLabel.text = "Player \(playerCount)'s turn"
            playersLabel.isHidden = false
        }
        roundNum = 1
        scoreCounter.isHidden = false
        currentGoalLabel.isHidden = false
        scoreLabel.text = "Score"
        scoreCounter.text = "0"
        currentGoalLabel.text = "Current Goal: \(sequenceLength)"
        disableButtons()
        startGame.isHidden = true
        generateSequence()
        playNextItemInSequence()
    }
    
    // Plays sound to show user the next button in the sequence to recreate, and calls highlightButton
    func playNextItemInSequence () {
        if (roundNum - 1 == sequenceLength) {
            restartGame(winner: true)
        }
        else {
            let selectedItem = sequence[currentItemInSequence]
            
            switch selectedItem {
            case 1:
                highlightButton(tag: 1)
                // time delay added to match with button highlight time delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.redSoundButton.play()
                }
                break
            case 2:
                highlightButton(tag: 2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.yellowSoundButton.play()
                }
                break
            case 3:
                highlightButton(tag: 3)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.blueSoundButton.play()
                }
                break
            case 4:
                highlightButton(tag: 4)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.greenSoundButton.play()
                }
                break
            default:
                break
            }
            
            currentItemInSequence += 1
        }
        
    }
    
    // Plays sound when button is pressed, and calls checkIfCorrect function
    @IBAction func buttonPressed(_ sender: AnyObject) {
        
        if isReady {
            let button = sender as! UIButton
            
            switch button.tag {
            case 1:
                redSoundButton.play()
                // Changes transparency of button to mimick a clicking animation
                soundButton[0].alpha = 0.5
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.soundButton[0].alpha = 1
                }
                checkIfCorrect(tag: 1)
                break
            case 2:
                yellowSoundButton.play()
                soundButton[1].alpha = 0.5
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.soundButton[1].alpha = 1
                }
                checkIfCorrect(tag: 2)
                break
            case 3:
                blueSoundButton.play()
                soundButton[2].alpha = 0.5
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.soundButton[2].alpha = 1
                }
                checkIfCorrect(tag: 3)
                break
            case 4:
                greenSoundButton.play()
                soundButton[3].alpha = 0.5
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.soundButton[3].alpha = 1
                }
                checkIfCorrect(tag: 4)
                break
            default:
                break
            }
        }
        
    }
    
    // Checks if the button pressed is correct as per the sequence
    func checkIfCorrect(tag: Int) {
        if tag == sequence[numOfClicks] {
            if numOfClicks == (roundNum - 1) {
                // time delay before start of next road to give user time to prepare
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.nextRound()
                }
                return
            }
            numOfClicks += 1
        }
        else {
            restartGame(winner: false)
        }
            
    }
    
    // Resets game and variables to initial values
    func restartGame(winner: Bool) {
        gameLost = true
        disableButtons()
        updateHighScore(score: score)
        updateHighScoreLabel()
        score = 0
        isReady = false
        numOfClicks = 0
        playerCount = 1
        sequence = []
        scoreCounter.isHidden = true
        playersLabel.isHidden = true
        
        // Increases sequence if user reaches goal, else alerts user that game is over
        if (winner == false) {
            scoreLabel.text = "GAME OVER"
        }
        else {
            scoreLabel.text = "YOU WIN\nNew goal has been set"
            sequenceLength += 5
            currentGoalLabel.text = "Current Goal: \(sequenceLength)"
        }
        currentItemInSequence = 0
        roundNum = 1
        startGame.isHidden = false
    }
    
    
    // Starts the next round if the sequence is recreated successfully
    func nextRound() {
        roundNum += 1
        score += 1
        scoreCounter.text = "\(score)"
        isReady = false
        numOfClicks = 0
        currentItemInSequence = 0
        disableButtons()
        
        if(playerCount < numOfPlayers) {
            playerCount += 1
            playersLabel.text = "Player \(playerCount)'s turn"
        }
        else {
            playerCount = 1
            playersLabel.text = "Player \(playerCount)'s turn"

        }
        
        playNextItemInSequence()
        
    }
    
    // Plays next sound in sequence when previous sound finishes playing
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        // If statement added to avoid playing next item when user loses the game
        if gameLost == true {
            return
        }
        else if currentItemInSequence < roundNum {
            playNextItemInSequence()
        }
        else {
            isReady = true
            resetButtonHighlight()
            enableButtons()
        }
        
    }
    
    // Shows user visually the next button in the sequence by highlighting it
    func highlightButton (tag: Int) {
        switch tag {
        case 1:
            resetButtonHighlight()
            // time delay added between each button highlight to ensure sequence is displayed with clarity
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.soundButton[tag - 1].setImage(UIImage(named: "redPressed"), for: .normal)
            }
        case 2:
            resetButtonHighlight()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.soundButton[tag - 1].setImage(UIImage(named: "yellowPressed"), for: .normal)}
        case 3:
            resetButtonHighlight()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.soundButton[tag - 1].setImage(UIImage(named: "bluePressed"), for: .normal)
            }
        case 4:
            resetButtonHighlight()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.soundButton[tag - 1].setImage(UIImage(named: "greenPressed"), for: .normal)
            }
        default:
            break;
        }
    }
    
    // Resets button highlight from pressed to normal
    func resetButtonHighlight () {
        soundButton[0].setImage(UIImage(named: "red"), for: .normal)
        soundButton[1].setImage(UIImage(named: "yellow"), for: .normal)
        soundButton[2].setImage(UIImage(named: "blue"), for: .normal)
        soundButton[3].setImage(UIImage(named: "green"), for: .normal)
    }
    
    // Update high score variable
    func updateHighScore(score: Int) {
        highScore = max(highScore, score)
    }
    
    // Update high score label with new high score
    func updateHighScoreLabel() {
        highScoreLabel.text = "High Score: \(highScore)"
    }
    
    func disableButtons() {
        for button in soundButton {
            button.isUserInteractionEnabled = false
        }
    }
    
    func enableButtons() {
        for button in soundButton {
            button.isUserInteractionEnabled = true
        }
    }
    
    
}
