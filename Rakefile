class String
  def self.colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def red
    self.class.colorize(self, 31)
  end

  def green
    self.class.colorize(self, 32)
  end
end

desc 'Run the tests'
task :test do
  verbose = ENV['VERBOSE']
  mac = test_scheme('SSKeychainTests-Mac', verbose)
  ios = test_scheme('SSKeychainTests-iOS', verbose)

  puts "\n\n\n" if verbose
  puts "Mac: #{mac == 0 ? 'PASSED'.green : 'FAILED'.red}"
  puts "iOS: #{ios == 0 ? 'PASSED'.green : 'FAILED'.red}"
end

task :default => :test

namespace :docs do
  header_path = 'SSKeychain/*.h'
  appledoc_options = [
    '--output Documentation',
    '--project-name SSKeychain',
    '--project-company \'Sam Soffes\'',
    '--company-id com.samsoffes',
    "--project-version #{`cat VERSION`.strip}",
    '--keep-intermediate-files',
    '--create-html',
    '--templates ~/Library/Application\ Support/appledoc/Templates/',
    '--no-repeat-first-par',
    '--verbose']

  desc 'Clean docs'
  task :clean do
    `rm -rf Documentation`
  end

  desc 'Install docs'
  task :install => [:'docs:clean'] do
    `appledoc #{appledoc_options.join(' ')} --create-docset --install-docset #{header_path}`
  end

  desc 'Publish docs'
  task :publish => [:'docs:clean'] do
    extra_options = [
      '--create-docset',
      '--publish-docset',
      '--install-docset',
      '--docset-atom-filename com.samsoffes.sskeychain.atom',
      '--docset-feed-url http://docs.samsoff.es/%DOCSETATOMFILENAME',
      '--docset-package-url  http://docs.samsoff.es/%DOCSETPACKAGEFILENAME'
      ]
    `appledoc #{appledoc_options.join(' ')} #{extra_options.join(' ')} #{header_path}`
  end
end

def test_scheme(scheme, verbose = false)
  command = "xcodebuild -project Tests/SSKeychain.xcodeproj -scheme #{scheme} TEST_AFTER_BUILD=YES 2>&1"
  IO.popen(command) do |io|
    while line = io.gets do
      puts line if verbose
      if line == "** BUILD SUCCEEDED **\n"
        return 0
      elsif line == "** BUILD FAILED **\n"
        return 1
      end
    end
  end
end
