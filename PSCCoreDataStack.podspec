Pod::Spec.new do |s|
  s.name              = 'PSCCoreDataStack'
  s.version           = '0.0.9'

  s.summary           = 'A persistence layer for CoreData'
  s.description       = <<-DESC
                        This library can be used for easier access to basic CoreData functionality
                        have fun.
                        DESC

  s.homepage          = 'http://nousguide.com/'
  s.documentation_url = 'http://nousguide.com/help/'

  s.license      = { :file => 'LICENCE' }
  s.author            = { 'Thomas Heingaertner' => 'mail@t.heingaertner@nousguide.com', 'Alexander Wold' => 'mail@a.wolf@nousguide.com' }
  s.source            = { :git => 'https://github.com/PocketScientists/PSCCoreDataStack.git', :tag => s.version.to_s }

  s.platform          = :ios, '5.0'
  s.source_files      = 'PSCCoreDataStack/*.{h,m}'
  s.requires_arc      = true

  s.frameworks              = 'CoreData'
end
