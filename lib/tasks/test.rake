class PrecompileBenchmark
  def initialize
    @multiplier = ENV['TEST_MULTIPLIER'].to_i || 1
  end 

  def assets_path
    Rails.root.join('app', 'assets', 'javascripts', '*')
  end

  def public_path
    Rails.root.join('public', 'assets')
  end

  def precompile_assets(runtime)
    ENV['EXECJS_RUNTIME'] = runtime
    ENV['RAILS_ENV'] = 'production'

    @multiplier.times do
      FileUtils.rm_rf public_path
      system("bundle exec rake assets:precompile RAILS_ENV=production 2>/dev/null") # -s and -q were ignored
    end
  end

  def execjs_assets(runtime)
    ExecJS.runtime = runtime
    source_code = Dir.glob(assets_path).map { |filename| File.read(filename) }.join
    @multiplier.times { ExecJS.compile source_code }
  end

  def run_benchmark name, files
    FileUtils.rm_rf assets_path
    FileUtils.cp files, assets_path

    puts  "\n\n" + ( "-" * 40) + name + ( "-" * 40) + "\n\n"

    Benchmark.bmbm do |x|
      x.report("Node.js - #{name} - (rake task)") do
        precompile_assets 'Node'
      end

      x.report("Node.js - #{name} - (execjs compile)") do
        execjs_assets ExecJS::Runtimes::Node
      end    
    end

    puts "\n\n"

    Benchmark.bmbm do |x|
      x.report("TheRubyRacer - #{name} (rake task)") do
        precompile_assets 'RubyRacer'
      end

      x.report("TheRubyRacer - #{name} (execjs compile)") do
        execjs_assets ExecJS::Runtimes::RubyRacer
      end
    end

  end

  def run
    puts "Every test will be run #{@multiplier} time(s)"

    minified_js = Dir.glob(File.join('test', 'assets', 'javascript', 'minified', "*.js"))
    development_js = Dir.glob(File.join('test', 'assets', 'javascript', 'development', "*.js"))

    run_benchmark 'minified', minified_js
    run_benchmark 'development', development_js   
  end 
end

namespace :test do
  desc "Tests both The Ruby Racer and Node.js as runtimes"
  task jsruntime: :environment do
    PrecompileBenchmark.new.run
  end
end
