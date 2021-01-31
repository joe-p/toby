Gem::Specification.new do |s|
    s.name        = 'toby'
    s.version     = '1.0.0-rc3'
    s.licenses    = ['MIT']
    s.summary     = "A TOML Parser for Ruby. TOML + Ruby = Toby."
    s.description = "Toby is a TOML 1.0.0 parser for Ruby that allows the parsing, editing, and dumping of the TOML file format (including comments). Toby also supports conversion from TOML to a Ruby Hash or JSON."
    s.authors     = ["Joe Polny"]
    s.files       = Dir["lib/**/*"]
    s.homepage    = 'https://github.com/joe-p/toby'
    s.metadata    = { 
        "source_code_uri" => "https://github.com/joe-p/toby",
        'bug_tracker_uri'   => 'https://github.com/joe-p/toby/issues',
    }
end