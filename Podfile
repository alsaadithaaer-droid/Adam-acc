platform :ios, '12.0'
ENV['COCOAPODS_DISABLE_STATS'] = 'true'
project 'Runner', {'Debug' => :debug, 'Profile' => :release, 'Release' => :release}
target 'Runner' do
  flutter_application_path = '../'
  load File.join(flutter_application_path, '.flutter', 'packages', 'flutter_tools', 'bin', 'podhelper.rb') rescue nil
end