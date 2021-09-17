Pod::Spec.new do |s|
  s.platform = :ios, '11.0'
  s.ios.deployment_target = '11.0'
  s.name = "PSCCoreData"
  s.version = "1.0.11"
  s.license = 'MIT'
  s.summary = "Helper for managing the CoreData Stack."
  s.homepage = "https://github.com/PocketScientists/PSCCoreDataStack.git"
  s.description =
    'Helper for managing the CoreData Stack. Contains extensions for NSManagedObject and NSManagedObjectContext'
  s.authors = {
    'Jürgen Falb' => 'j.falb@nousdigital.net',
    'Philip Messlehner' => 'p.messlehner@pocketscience.com'
  }
  s.source = { :git => "https://github.com/PocketScientists/PSCCoreDataStack.git", :tag => '1.0.11' }
  s.source_files = 'PSCCoreDataStack/*.{h,m}', 'PSCCoreData/PSCCoreData.h'

  s.public_header_files = 'PSCCoreDataStack/*.{h}', 'PSCCoreData/PSCCoreData.h'

  s.frameworks = 'CoreData', 'Foundation', 'UIKit'

  s.requires_arc = true
end
