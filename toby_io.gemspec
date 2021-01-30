Gem::Specification.new do |s|
    s.name        = 'toby_io'
    s.version     = '1.0.0-rc1'
    s.licenses    = ['MIT']
    s.summary     = "A TOML Parser for Ruby. TOML + Ruby = Toby. Input + Output = IO"
    s.description = "Toby is a TOML 1.0.0 parser for Ruby that allows the parsing, editing, and dumping of the TOML file format (including comments). TobyIO also supports conversion from TOML to a Ruby Hash or JSON."
    s.authors     = ["Joe Polny"]
    s.files       = Dir["lib/**/*"]
    s.homepage    = 'https://github.com/joe-p/toby_io'
    s.metadata    = { 
        "source_code_uri" => "https://github.com/joe-p/toby_io",
        'bug_tracker_uri'   => 'https://github.com/joe-p/toby_io/issues',
    }
end