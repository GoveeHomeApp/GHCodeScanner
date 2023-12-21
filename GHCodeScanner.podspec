Pod::Spec.new do |s|

  s.name         = 'GHCodeScanner'
  s.version      = '0.0.0'
  s.summary      = 'GHCodeScanner.'

  s.homepage     = 'git@github.com:GoveeHomeApp/GHCodeScanner.git'

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = 'sy'

  s.ios.deployment_target = '13.0'

  s.swift_version = '5.0'

  s.source       = { :git => 'git@github.com:GoveeHomeApp/GHCodeScanner.git', :tag => s.version.to_s }

  s.source_files = 'GHCodeScanner/Classes/**/*'

  # s.info_plist = { 'GHModular' => 'GHxxxxxxx.GHxxxxxModule' }
  
  # s.resource_bundles = { 'GHCodeScanner' => ['GHCodeScanner/*.xcassets'] }

end
