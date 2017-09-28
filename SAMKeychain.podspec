Pod::Spec.new do |spec|
  spec.name         = 'SAMKeychain'
  spec.version      = '1.5.3'
  spec.description  = 'Simple Cocoa wrapper for the keychain that works on OS X, iOS, tvOS, and watchOS.'
  spec.summary      = 'Simple Cocoa wrapper for the keychain.'
  spec.homepage     = 'https://github.com/soffes/samkeychain'
  spec.author       = { 'Sam Soffes' => 'sam@soff.es' }
  spec.source       = { :git => 'https://github.com/soffes/samkeychain.git', :tag => "v#{spec.version}" }
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }

  spec.source_files = 'Sources/*.{h,m}'
  spec.resources = 'Support/SAMKeychain.bundle'

  spec.frameworks = 'Security', 'Foundation'

  spec.osx.deployment_target = '10.8'
  spec.ios.deployment_target = '5.0'
  spec.tvos.deployment_target = '9.0'
  spec.watchos.deployment_target = '2.0'
end
