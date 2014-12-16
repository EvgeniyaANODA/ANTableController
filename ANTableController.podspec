Pod::Spec.new do |spec|
  spec.name     = 'ANTableController'
  spec.version  = '1.0'
  spec.license  = { :type => 'MIT' }
  spec.homepage = 'https://github.com/anodamobi/ANTableController'
  spec.authors  = { 'Oksana Kovalchuk' => 'oksana@anoda.mobi' }
  spec.summary  = 'Adoption of DTTableViewController for using without UIViewController sublassing'
  spec.source   = { :git => 'https://github.com/anodamobi/ANTableController.git', :tag => '1.0' }

  spec.source_files =  "TableController/*.{h,m}", "TableController/Private/*.{h,m}", "TableController/Private/CellFactory/*.{h,m}", "TableController/Private/ANTableController/*.{h,m}", "TableController/Private/DTMemoryStorage/*.{h,m}", "TableController/BaseUIClasses/*.{h,m}"

  spec.public_header_files = "TableController/*.h", "TableController/Private/*.h", "TableController/Private/CellFactory/*.h", "TableController/Private/ANTableController/*.h", "TableController/Private/DTMemoryStorage/*.h", "TableController/BaseUIClasses/*.h"

  spec.framework = "Foundation", "UIKit"
  spec.requires_arc = true

  spec.dependency 'ANHelperFunctions', '~> 1.0'
  spec.dependency 'ANKeyboardHandler', '~> 1.0'
  spec.dependency 'ANStorage', '~> 1.0'
end