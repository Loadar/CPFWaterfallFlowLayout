Pod::Spec.new do |s|
  s.name = 'CPFWaterfallFlowLayout'
  s.version = '2.5.0'
  s.summary = 'Swift瀑布流布局'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'chenpengfei' => 'afeiafeia@163.com' }
  s.source = { :git => 'https://github.com/Loadar/CPFWaterfallFlowLayout.git', :tag => s.version.to_s }
  s.homepage = 'https://github.com/Loadar/CPFWaterfallFlowLayout'

  s.ios.deployment_target = "9.0"
  s.swift_version = '5.0'
  s.requires_arc = true
  
  s.subspec 'Base' do |subspec|
      subspec.source_files = 'Sources/CPFWaterfallFlowLayout/*.swift'
      subspec.exclude_files = 'Sources/CPFWaterfallFlowLayout/WaterfallLayout+Cpf.swift'
  end
  
  s.subspec 'Cpf' do |subspec|
      subspec.source_files = 'Sources/CPFWaterfallFlowLayout/WaterfallLayout+Cpf.swift'
      subspec.dependency 'CPFChain'
      subspec.dependency 'CPFWaterfallFlowLayout/Base'
  end

end
