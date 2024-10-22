Pod::Spec.new do |s|
  s.name             = 'DeviceInsightKit'
  s.version          = '0.0.1'
  s.summary          = 'Framework for accessing device system information such as battery, CPU usage, and more.'

  s.description      = <<-DESC
  DeviceInsightKit provides easy access to various system information such as battery level, CPU usage, memory statistics, and more on iOS devices.
  DESC

  s.homepage         = 'https://github.com/aragig/DeviceInsightKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Toshihiko Arai' => 'i.officearai@gmail.com' }
  s.source           = { :git => 'https://github.com/aragig/DeviceInsightKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'DeviceInsightKit/*.swift', 'DeviceInsightKit/*.h'

  s.swift_version = '5.0'
end
