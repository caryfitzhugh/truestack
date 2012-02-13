namespace :workers do
  namespace :collector do
    desc "Start collector webserver with given URL"
    task :start, [:url] => :environment do |t, args|
      Truestack::Workers::Collector.start(args.url)
    end
  end
end
