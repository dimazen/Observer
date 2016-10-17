Pod::Spec.new do |s|

  s.name         = "Observer"
  s.version      = "1.0.0"

  s.summary      = "Observer implementation"

  s.homepage     = "https://git.yalantis.com/dmitriy.shemet/Observer"
  s.license      = "MIT"

  s.source       = { :git => "git@git.yalantis.com:dmitriy.shemet/Observer.git, :tag => s.version.to_s }

  s.frameworks = 'Foundation', 'UIKit'

  s.requires_arc = true
  s.ios.deployment_target = '9.0'

  s.default_subspec = 'Default'

  # Default subspec that includes the most commonly-used components
  s.subspec 'Default' do |default|
    default.source_files = "Observer/Source/**/*.swift"
  end

end
