//
//  LongestCommonSubsequence.swift
//  MusicScale
//
//  Created by 윤범태 on 5/10/25.
//

/// 두 오름차순 정렬된 정수 배열 간의 Longest Common Subsequence (LCS)의 길이를 반환합니다.
///
/// - Parameters:
///   - a: 첫 번째 정수 배열 (오름차순 정렬되어 있어야 함)
///   - b: 두 번째 정수 배열 (오름차순 정렬되어 있어야 함)
/// - Returns: 두 배열 간 순서를 유지하며 공통적으로 나타나는 최장 부분 수열의 길이
func lcsLength(_ a: [Int], _ b: [Int]) -> Int {
  let m = a.count
  let n = b.count
  var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

  for i in 1...m {
    for j in 1...n {
      if a[i - 1] == b[j - 1] {
        dp[i][j] = dp[i - 1][j - 1] + 1
      } else {
        dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
      }
    }
  }

  return dp[m][n]
}

/// 두 오름차순 정렬된 정수 배열 간의 LCS 기반 유사도를 0~100 범위의 퍼센트 값으로 반환합니다.
///
/// - Parameters:
///   - a: 첫 번째 정수 배열
///   - b: 두 번째 정수 배열
/// - Returns: LCS 길이를 기반으로 계산한 유사도 (0.0~100.0%)
///
/// - Note: 유사도는 다음 공식을 따릅니다:
///         `similarity = (2 * LCS_length) / (a.count + b.count) * 100`
func similarityLCS(_ a: [Int], _ b: [Int]) -> Double {
  let lcs = Double(lcsLength(a, b))
  return (2 * lcs) / Double(a.count + b.count) * 100.0
}
