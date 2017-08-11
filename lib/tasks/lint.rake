namespace :lint do
  desc "Run govuk-lint on ruby files"
  task "ruby_lint" do
    sh "bundle exec govuk-lint-ruby --format clang app config Gemfile lib spec"
  end
  desc "Run govuk-lint on the stylesheet"
  task "css_lint" do
    sh "bundle exec govuk-lint-sass app/assets/stylesheets"
  end
end
