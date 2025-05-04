//
//  DiscountManager.swift
//  MusicScale
//
//  Created by 윤범태 on 5/4/25.
//

import FirebaseDatabase

class DiscountManager {
  private init() {}
  static let shared = DiscountManager()
  
  private let databaseRef = Database.database().reference()
  
  private let isDiscountNowKey = "is_discount_now"
  private let globalDiscountRateKey = "global_discount_rate"
  
  private var isDiscountNowCache: (value: Bool, timestamp: Date)?
  private var globalDiscountRateCache: (value: Double, timestamp: Date)?

  private let cacheDuration: TimeInterval = 60  // 1분 캐시
  
  // MARK: - Create or Update
  
  func setIsDiscountNow(_ value: Bool) {
    databaseRef.child(isDiscountNowKey).setValue(value)
  }
  
  func setGlobalDiscountRate(_ value: Double) {
    databaseRef.child(globalDiscountRateKey).setValue(value)
  }
  
  func setAll(isDiscountNow: Bool, discountRate: Double) {
    let updates: [String: Any] = [
      isDiscountNowKey: isDiscountNow,
      globalDiscountRateKey: discountRate
    ]
    databaseRef.updateChildValues(updates)
  }
  
  // MARK: - Read
  
  func fetchIsDiscountNow(completion: @escaping (Bool?) -> Void) {
    // 캐시가 유효하면 반환
    if let cached = isDiscountNowCache, Date().timeIntervalSince(cached.timestamp) < cacheDuration {
      completion(cached.value)
      return
    }

    // 아니면 Firebase에서 가져옴
    databaseRef.child(isDiscountNowKey).observeSingleEvent(of: .value) { snapshot in
      let value = snapshot.value as? Bool
      if let value {
        self.isDiscountNowCache = (value, Date())
      }
      completion(value)
    }
  }

  func fetchGlobalDiscountRate(completion: @escaping (Double?) -> Void) {
    // 캐시가 유효하면 반환
    if let cached = globalDiscountRateCache, Date().timeIntervalSince(cached.timestamp) < cacheDuration {
      completion(cached.value)
      return
    }

    // 아니면 Firebase에서 가져옴
    databaseRef.child(globalDiscountRateKey).observeSingleEvent(of: .value) { snapshot in
      if let value = snapshot.value as? NSNumber {
        let doubleValue = value.doubleValue
        self.globalDiscountRateCache = (doubleValue, Date())
        completion(doubleValue)
      } else {
        completion(nil)
      }
    }
  }
  
  func fetchAll(completion: @escaping (Bool?, Double?) -> Void) {
    databaseRef.observeSingleEvent(of: .value) { snapshot in
      let dict = snapshot.value as? [String: Any]
      let isDiscount = dict?[self.isDiscountNowKey] as? Bool
      let discountRate = (dict?[self.globalDiscountRateKey] as? NSNumber)?.doubleValue
      completion(isDiscount, discountRate)
    }
  }
  
  // MARK: - Delete
  
  func removeIsDiscountNow() {
    databaseRef.child(isDiscountNowKey).removeValue()
  }
  
  func removeGlobalDiscountRate() {
    databaseRef.child(globalDiscountRateKey).removeValue()
  }
  
  func removeAll() {
    databaseRef.child(isDiscountNowKey).removeValue()
    databaseRef.child(globalDiscountRateKey).removeValue()
  }
}

extension DiscountManager {
  func isDiscountNow() async throws -> Bool {
    if let cached = isDiscountNowCache, Date().timeIntervalSince(cached.timestamp) < cacheDuration {
      return cached.value
    }
    
    return try await withCheckedThrowingContinuation { continuation in
      fetchIsDiscountNow { result in
        if let result = result {
          self.isDiscountNowCache = (result, Date())
          continuation.resume(returning: result)
        } else {
          continuation.resume(throwing: NSError(domain: "DiscountManager", code: 0, userInfo: nil))
        }
      }
    }
  }

  func globalDiscountRate() async throws -> Double {
    if let cached = globalDiscountRateCache, Date().timeIntervalSince(cached.timestamp) < cacheDuration {
      return cached.value
    }
    
    return try await withCheckedThrowingContinuation { continuation in
      fetchGlobalDiscountRate { result in
        if let result = result {
          self.globalDiscountRateCache = (result, Date())
          continuation.resume(returning: result)
        } else {
          continuation.resume(throwing: NSError(domain: "DiscountManager", code: 1, userInfo: nil))
        }
      }
    }
  }
}
