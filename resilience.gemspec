Gem::Specification.new do |s|
    s.name          = 'resilience'
    s.version       = '0.2.1'
    s.executables   = Dir.glob('bin/*.rb').collect { |f| f.gsub('bin/', '')}
    s.files         = Dir.glob('lib/**/*') + %w{README.md}

    s.author        = "Mo Morsi"
    s.description   = %q{Ruby ReFS utils}
    s.summary       = %q{An experimental ReFS Library}
    s.homepage      = %q{https://github.com/movitto/resilience}
    s.licenses      = ["MIT"]
    s.email         = 'mmorsi@redhat.com'

    s.add_dependency('colored')
end
