Gem::Specification.new do |s|
  s.name        = 'yolodice-validator'
  s.version     = '0.1.0'
  s.summary     = 'Bet validator for YOLOdice.com'
  s.description = 'A utility that lets you verify your bets and seeds from the Bitcoin game YOLOdice.com.'
  s.authors     = ['ethan_nx']
  s.files       = Dir.glob ['lib/*.rb',
                           'bin/*',
                           '[A-Z]*.md'].to_a
  s.executables << 'yolodice-validator'
  s.homepage    = 'https://github.com/ethan-nx/yolodice-validator'
  s.license     = 'MIT'
end
