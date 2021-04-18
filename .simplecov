SimpleCov.coverage_dir 'out/testreport-coverage'
SimpleCov.add_filter '.git'
SimpleCov.add_filter 'src'
SimpleCov.add_filter 'out/misc'
SimpleCov.add_group 'Executables', 'out/(bin/testrunner|(lib|bin)/.*\.sh)'
SimpleCov.add_group 'Libraries', 'out/lib/.*\.rc'
# SimpleCov.add_group 'Libraries_2', 'lib/.*\.rc'
SimpleCov.add_group 'Tests', 'out/test/.*\.sh'
# SimpleCov.add_group 'Tests_2', 'test/.*\.sh'
SimpleCov.add_group 'Build tools', 'buildtools/.*\.(rc|sh)|build.sh'