Gem::Specification.new do |s|
    s.name    = 'resilience'
    s.version = '0.0.1'
    s.executables   = ['resilience.rb']
    s.add_dependency('colored')

    s.author = "Mo Morsi"
    s.description = %q{Ruby ReFS utils}
    s.summary = %q{A module/command-line utility to parse a ReFS file system image}
    s.homepage = %q{https://gist.github.com/movitto/866de4356f56a3b478ca}
    s.licenses = ["MIT"]
end
