# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MusicScale' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MusicScale
  pod 'DropDown'

  # add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'
  # or pod ‘Firebase/AnalyticsWithoutAdIdSupport’
  # for Analytics without IDFA collection capability
  # add pods for any other desired Firebase products
  # https://firebase.google.com/docs/ios/setup#available-pods
  # Add the pods for any other Firebase products you want to use in your app
  # For example, to use Firebase Authentication and Cloud Firestore
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'Google-Mobile-Ads-SDK'

  target 'MusicScaleTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MusicScaleUITests' do
    # Pods for testing
  end

end
post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end