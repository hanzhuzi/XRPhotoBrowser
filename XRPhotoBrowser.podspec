Pod::Spec.new do |spec|
  
  spec.name         = "XRPhotoBrowser"
  spec.version      = "1.0.1"
  spec.summary      = "Powerful, low memory usage, efficient and smooth photo browsing framework that supports image transit effect."
  spec.platform     = :ios, "9.0"
  spec.description  = <<-DESC
                   Powerful, low memory usage, efficient and smooth photo browsing framework that supports image transit effect.
                   DESC
                   
  spec.homepage     = "https://github.com/hanzhuzi/XRPhotoBrowser"
  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.author       = { "hanzhuzi" => "violet_buddhist@163.com" }
  spec.source       = { :git => "https://github.com/hanzhuzi/XRPhotoBrowser.git", :tag => "#{spec.version}" }

  spec.source_files  = "Source/Classes", "XRPhotoBrowser/Sources/**/*.{h,m}"
  
  spec.resource_bundles = {
      'XRPhotoBrowser' => ['XRPhotoBrowser/Sources/XRPhotoBrowser.bundle/*.png']
  }
  
  spec.ios.framework  = 'UIKit', 'Foundation'
  spec.weak_frameworks = 'Photos'
  spec.requires_arc = true

  # dependency frameworks
  spec.dependency "SDWebImage", "~> 5.0.6"

end
