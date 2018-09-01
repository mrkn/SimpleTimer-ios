//
//  Configuration.swift
//  SimpleTimer
//
//  Created by Kenta Murata on 2018/09/01.
//  Copyright © 2018 mrkn.jp. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let configurationDidChangeLeftIncrementButtonSecondsNotification = Notification.Name("jp.mrkn.SimpleTimer.configurationDidChangeLeftIncrementButtonSecondsNotification")
    static let configurationDidChangeCenterIncrementButtonSecondsNotification = Notification.Name("jp.mrkn.SimpleTimer.configurationDidChangeCenterIncrementButtonSecondsNotification")
    static let configurationDidChangeRightIncrementButtonSecondsNotification = Notification.Name("jp.mrkn.SimpleTimer.configurationDidChangeRightIncrementButtonSecondsNotification")
    static let configurationDidChangeMiddleAleartSecondsNotification = Notification.Name("jp.mrkn.SimpleTimer.configurationDidChangeMiddleAleartSecondsNotification")
    static let configurationDidChangeDisableSleepNotification = Notification.Name("jp.mrkn.SimpleTimer.configurationDidChangeDisableSleepNotification")
}

class Configuration: NSObject, Codable {
    public var initialSeconds: UInt = 10

    public var leftIncrementButtonSeconds: Int = 5*60 {
        didSet {
            self.postUpdateNotification(name: .configurationDidChangeLeftIncrementButtonSecondsNotification)
        }
    }

    public var centerIncrementButtonSeconds: Int = 15*60 {
        didSet {
            self.postUpdateNotification(name: .configurationDidChangeCenterIncrementButtonSecondsNotification)
        }
    }

    public var rightIncrementButtonSeconds: Int = 25*60 {
        didSet {
            self.postUpdateNotification(name: .configurationDidChangeRightIncrementButtonSecondsNotification)
        }
    }

    public var middleAleartSeconds: [UInt] = [5*60, 15*60] {
        didSet {
            self.postUpdateNotification(name: .configurationDidChangeMiddleAleartSecondsNotification)
        }
    }

    public var disableSleep: Bool = false {
        didSet {
            self.postUpdateNotification(name: .configurationDidChangeDisableSleepNotification)
        }
    }

    public override func awakeFromNib() {
        loadFromDefaults()
    }

    private let kUserDefaultsKey = "configuration"

    private func postUpdateNotification(name: Notification.Name) {
        self.saveToDefaults()
        NotificationCenter.default.post(name: name, object: self)
    }

    public func loadFromDefaults() {
        guard let jsonData = UserDefaults.standard.data(forKey: kUserDefaultsKey) else { return }
        guard let configuration = try? JSONDecoder().decode(Configuration.self, from: jsonData) else { return }

        self.initialSeconds = configuration.initialSeconds
        self.leftIncrementButtonSeconds = configuration.leftIncrementButtonSeconds
        self.centerIncrementButtonSeconds = configuration.centerIncrementButtonSeconds
        self.rightIncrementButtonSeconds = configuration.rightIncrementButtonSeconds
        self.middleAleartSeconds = configuration.middleAleartSeconds
        self.disableSleep = configuration.disableSleep
    }

    public func saveToDefaults() {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(self) else { return }
        UserDefaults.standard.set(jsonData, forKey: kUserDefaultsKey)
    }
}
