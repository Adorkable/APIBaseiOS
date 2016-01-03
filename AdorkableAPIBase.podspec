Pod::Spec.new do |s|
  s.name         = 'AdorkableAPIBase'
  s.version      = '0.3.3'
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/Adorkable/APIBaseiOS'
  s.authors      =  { 'Ian Grossberg' => 'yo.ian.g@gmail.com' }
  s.summary      = 'A purdy simple API base'

  s.ios.deployment_target = '9.1'
  s.osx.deployment_target = '10.11'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.source       =  { :git => 'https://github.com/Adorkable/APIBaseiOS.git', :tag => s.version.to_s }
  s.source_files = 'Sources/*.swift'

  s.requires_arc = true
end