namespace :lint do
  desc "Run rubocop on ruby files"
  task "ruby_lint" do
    sh "bundle exec rubocop  --format clang app Gemfile lib spec"
  end
  desc "Run scss-lint on the stylesheet"
  task "css_lint" do
    sh "bundle exec scss-lint app/assets/stylesheets"
  end
end
