Pod::Spec.new do |s|
  s.name = 'CPFWaterfallFlowLayout'
  s.version = '0.0.1'
  s.summary = 'Swift瀑布流布局'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'chenpengfei' => 'afeiafeia@163.com' }
  s.source = { :git => 'htts://github.com/Loadar/CPFWaterfallFlowLayout.git', :tag => s.version.to_s }
  s.homepage = 'htts://github.com/Loadar/CPFWaterfallFlowLayout'

  s.ios.deployment_target = "8.0"
  s.source_files = 'Classes/*.swift'
  s.requires_arc = true
end