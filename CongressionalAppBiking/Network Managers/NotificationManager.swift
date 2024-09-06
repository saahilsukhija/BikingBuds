/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import UserNotifications
import CoreLocation

enum NotificationManagerConstants {
    static let timeBasedNotificationThreadId =
    "TimeBasedNotificationThreadId"
    static let calendarBasedNotificationThreadId =
    "CalendarBasedNotificationThreadId"
    static let locationBasedNotificationThreadId =
    "LocationBasedNotificationThreadId"
}

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var settings: UNNotificationSettings?
    
    func requestAuthorization(completion: @escaping  (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
                self.fetchNotificationSettings()
                completion(granted)
            }
    }
    
    func fetchNotificationSettings() {
        // 1
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            // 2
            DispatchQueue.main.async {
                self.settings = settings
            }
        }
    }
    
    func removeScheduledNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func removeClockInOutNotifications(type: UserSettings.ClockInNotificationSettings) {
        removeScheduledNotification(id: type.rawValue)
        removeScheduledNotification(id: "OrganizerPlusCategory")
        for i in 1...7 {
            removeScheduledNotification(id: type.rawValue + "_\(i)")
        }
    }
    
    func sendDriveLoggedNotification(drive: Drive) {
        
        guard User.shared.settings.notificationsEnabled && User.shared.settings.driveNotificationsEnabled else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "New Drive Logged"
        if let initPlace = drive.initialPlace, let place = drive.finalPlace {
            content.body = "A new drive has been logged from \(initPlace) to \(place)."
        } else {
            content.body = "A new drive has been logged."
        }
        content.categoryIdentifier = "drive"
        content.sound = .default
//        let taskData = try? JSONEncoder().encode(task)
//        if let taskData = taskData {
//            content.userInfo = ["Task": taskData]
//        }
        
        let date = DateComponents(second: 2)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        let request = UNNotificationRequest(identifier: "drive", content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request) { (error : Error?) in
                            if let theError = error {
                                print(theError.localizedDescription)
                            }
                        }
    }
    
    func sendWorkLoggedNotification(work: Work) {
        
        guard User.shared.settings.notificationsEnabled && User.shared.settings.workNotificationsEnabled else {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "New Work Logged"
        if let place = work.finalPlace {
            content.body = "A new work has been logged at \(place)."
        } else {
            content.body = "A new work has been logged."
        }
        content.categoryIdentifier = "work"
        content.sound = .default
//        let taskData = try? JSONEncoder().encode(task)
//        if let taskData = taskData {
//            content.userInfo = ["Task": taskData]
//        }
        
        let date = DateComponents(second: 2)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        let request = UNNotificationRequest(identifier: "work", content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request) { (error : Error?) in
                            if let theError = error {
                                print(theError.localizedDescription)
                            }
                        }
    }
    
    func scheduleClockNotification(type: UserSettings.ClockInNotificationSettings) {
        
        for i in 2...6 {
            let content = UNMutableNotificationContent()
            content.title = "Reminder to \(type.rawValue)"
            content.body = "Your pre-set reminder to \(type.rawValue) at your given time"
            content.categoryIdentifier = "\(type.rawValue)_\(i)"
            content.sound = .default
            //        let taskData = try? JSONEncoder().encode(task)
            //        if let taskData = taskData {
            //            content.userInfo = ["Task": taskData]
            //        }
            
            var dateComponent = (type == .clockIn ? User.shared.settings?.clockInTime : User.shared.settings?.clockOutTime)
            dateComponent?.weekday = i
            guard let date = dateComponent else {
                print("Error scheduling a clock in/out notification")
                return
            }
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            let request = UNNotificationRequest(identifier: "\(type.rawValue)_\(i)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { (error : Error?) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            }
        }
    }
    
    func sendNotificationNow(title: String, subtitle: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = subtitle
        content.categoryIdentifier = "misc"
        content.sound = .default
//        let taskData = try? JSONEncoder().encode(task)
//        if let taskData = taskData {
//            content.userInfo = ["Task": taskData]
//        }
        
        let date = DateComponents(second: 0)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        let request = UNNotificationRequest(identifier: "misc", content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request) { (error : Error?) in
                            if let theError = error {
                                print(theError.localizedDescription)
                            }
                        }
    }
}

