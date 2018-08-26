//
//  ViewController.swift
//  SimpleTimer
//
//  Created by Kenta Murata on 2018/08/25.
//  Copyright © 2018 mrkn.jp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var timerView: TimerView!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var resetButton: UIButton!
    
    var currentTimerValue: UInt = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startTimer() {
        
    }
    
    @IBAction func stopTimer() {
        
    }

    @IBAction func resetTimer() {
        self.currentTimerValue = 0
        updateTimerValue()
    }

    @IBAction func click5minButton() {
        self.currentTimerValue += 5 * 60
        updateTimerValue()
    }

    @IBAction func click15minButton() {
        self.currentTimerValue += 15 * 60
        updateTimerValue()
    }

    @IBAction func click25minButton() {
        self.currentTimerValue += 25 * 60
        updateTimerValue()
    }

    func updateTimerValue() {
        self.timerView.currentSeconds = self.currentTimerValue
        self.timerView.setNeedsDisplay()
    }
}
