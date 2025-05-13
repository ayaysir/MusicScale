//
//  Date+.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/06/14.
//

import Foundation

extension Date {
  // https://stackoverflow.com/questions/27310883/swift-ios-doesrelativedateformatting-have-different-values-besides-today-and
  var yearsFromNow: Int {
    return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
  }
  var monthsFromNow: Int {
    return Calendar.current.dateComponents([.month], from: self, to: Date()).month!
  }
  var weeksFromNow: Int {
    return Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear!
  }
  var daysFromNow: Int {
    return Calendar.current.dateComponents([.day], from: self, to: Date()).day!
  }
  var isInYesterday: Bool {
    return Calendar.current.isDateInYesterday(self)
  }
  var hoursFromNow: Int {
    return Calendar.current.dateComponents([.hour], from: self, to: Date()).hour!
  }
  var minutesFromNow: Int {
    return Calendar.current.dateComponents([.minute], from: self, to: Date()).minute!
  }
  var secondsFromNow: Int {
    return Calendar.current.dateComponents([.second], from: self, to: Date()).second!
  }
  
  var relativeTime: String {
    if yearsFromNow > 0 { return "\(yearsFromNow) year" + (yearsFromNow > 1 ? "s" : "") + " ago" }
    if monthsFromNow > 0 { return "\(monthsFromNow) month" + (monthsFromNow > 1 ? "s" : "") + " ago" }
    if weeksFromNow > 0 { return "\(weeksFromNow) week" + (weeksFromNow > 1 ? "s" : "") + " ago" }
    if isInYesterday { return "Yesterday" }
    if daysFromNow > 0 { return "\(daysFromNow) day" + (daysFromNow > 1 ? "s" : "") + " ago" }
    if hoursFromNow > 0 { return "\(hoursFromNow) hour" + (hoursFromNow > 1 ? "s" : "") + " ago" }
    if minutesFromNow > 0 { return "\(minutesFromNow) minute" + (minutesFromNow > 1 ? "s" : "") + " ago" }
    if secondsFromNow >= 0 { return secondsFromNow < 15 ? "Just now"
      : "\(secondsFromNow) second" + (secondsFromNow > 1 ? "s" : "") + " ago" }
    return "Checking..."
  }
  
  // https://stackoverflow.com/questions/53356392/how-to-get-day-and-month-from-date-type-swift-4
  
  func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
    return calendar.dateComponents(Set(components), from: self)
  }
  
  func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
    return calendar.component(component, from: self)
  }
  
  /// 연월일만 뽑기 - 예) 20201203
  var ymdText: String {
    let year = get(.year)
    let month = get(.month) <= 9 ? "0\(get(.month))" : "\(get(.month))"
    let day = get(.day) <= 9 ? "0\(get(.day))" : "\(get(.day))"
    
    return "\(year)\(month)\(day)"
  }
}
