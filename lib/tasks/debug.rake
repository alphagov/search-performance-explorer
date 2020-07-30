namespace :debug do
  desc "Run the core of the search query with explain plans enabled and special boosting disabled"
  task :explain, [:query] => :environment do |_, args|
    Explainotron.explain!(args.query).report
  end
end
