# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'CongressionalAppBiking' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CongressionalAppBiking

  # Google Sign In
  
    pod 'GoogleSignIn'
    pod 'Firebase/Auth'
    pod 'Firebase/Analytics'
    
  # Regular Animations
    pod 'lottie-ios'
    
  # Google Maps
    #pod 'GoogleMaps'
    
  # Realtime Database (General location, time last seen, etc.)
    pod 'Firebase/Database'
    
  # Storage (Phone numbers, names, friends, etc.)
    pod 'Firebase/Storage'
    pod 'FirebaseUI/Storage'
    

end

# Disable Warnings
post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
  
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
   config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
   
  end
 end
end
