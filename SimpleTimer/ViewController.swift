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
    @IBOutlet var currentTimeDisplay: UILabel!
    
    var currentTimerValue: UInt = 10
    var timer: Timer!

    var isTimerRunning: Bool {
        get {
            return self.timer != nil && self.timer.isValid
        }
    }

    var timerShouldBeStartedAfterActivated = false
    var timeAtBecomingDeactive: time_t = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTimerValue()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { (notification) in
            if self.isTimerRunning {
                self.stopTimer()
                self.timerShouldBeStartedAfterActivated = true
                self.timeAtBecomingDeactive = time(nil)
            }
        }
        defaultCenter.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil) { (notification) in
            if self.timerShouldBeStartedAfterActivated {
                self.timerShouldBeStartedAfterActivated = false
                
                let deactivatedSeconds = max(time(nil) - self.timeAtBecomingDeactive, 0)
                self.currentTimerValue -= UInt(deactivatedSeconds)
                self.updateTimerValue()
                self.startTimer()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startTimer() {
        self.startButton.isHidden = true
        self.stopButton.isHidden = false
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (tm) in
            if self.currentTimerValue == 0 {
                self.stopTimer()
                return
            }
            self.currentTimerValue -= 1
            self.updateTimerValue()
        })
    }
    
    @IBAction func stopTimer() {
        self.timer.invalidate()
        self.stopButton.isHidden = true
        self.startButton.isHidden = false
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
        self.updateTimeDisplay()
    }
    
    func updateTimeDisplay() {
        let minutes = self.currentTimerValue / 60
        let seconds = self.currentTimerValue % 60
        let text = String(format: "%02d : %02d", minutes, seconds)
        self.currentTimeDisplay.text = text
    }
}
