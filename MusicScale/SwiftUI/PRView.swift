//
//  PRView.swift
//  MusicScale
//
//  Created by 윤범태 on 5/14/25.
//

import SwiftUI

struct PRFeature: Hashable {
  var title: String
  var subtitle: String
  var imageSystemName: String
  var foregroundColor: Color?
}

struct PRView: View {
  let title: String
  let subtitle: String
  let primaryButtonText: String
  let secondaryButtonText: String
  let features: [PRFeature]
  var primaryAction: (() -> Void)? = nil
  var secondaryAction: (() -> Void)? = nil
  @Environment(\.presentationMode) var presentationMode
  
  var body: some View {
    VStack {
      VStack(spacing: 20) {
        Text(verbatim: title)
          .font(.largeTitle)
          .bold()
        Text(verbatim: subtitle)
          .foregroundColor(.gray)
          .font(.system(size: 14))
      }
      .padding(.vertical, 20)
      .padding(.horizontal, 40)
      
      ScrollView {
        ForEach(features, id: \.self) { feature in
          HStack(alignment: .center) {
            ZStack {
              RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .frame(width: 60, height: 60)
              Image(systemName: feature.imageSystemName)
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .foregroundColor(feature.foregroundColor ?? .orange)
            }
            
            VStack(alignment: .leading) {
              Text(verbatim: feature.title)
                .font(.system(size: 16))
                .bold()
              Text(verbatim: feature.subtitle)
            }
            Spacer()
          }
          .padding(.horizontal, 30)
          .padding(.vertical, 15)
        }
      }
      Spacer()
      
      Button(secondaryButtonText) {
        secondaryAction?()
        presentationMode.wrappedValue.dismiss()
      }
      .font(.system(size: 14))
      .foregroundColor(.gray)
      
      buttonProminent(title: primaryButtonText) {
        primaryAction?()
        presentationMode.wrappedValue.dismiss()
      }
      .font(.system(size: 17, weight: .bold))
    }
  }
  
  @ViewBuilder private func buttonProminent(
    title: String,
    backgroundColor: Color = .blue,
    foregroundColor: Color = .white,
    completion: (() -> Void)? = nil
  ) -> some View {
    Button(title) {
      completion?()
    }
    .padding()
    .frame(
      width: UIScreen.main.bounds.width * 0.7,
      height: 50
    )
    .background(backgroundColor)
    .cornerRadius(10)
    .foregroundColor(foregroundColor)
  }
}

#Preview {
  PRView(
    title: "Pro용 인앱 결제 구입",
    subtitle: "Pro용 인앱을 구입하시면 모든 광고 영구 제거, 고급 피아노 키보드 이용, 건반을 이용한 고급 스케일 검색 등을 할 수 있습니다.",
    primaryButtonText: "d",
    secondaryButtonText: "e",
    features: IAP_PromotionFeatures
  )
}
