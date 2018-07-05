module HealthCheck
  DEFAULT_JSON_URL = "https://www.gov.uk/api/search.json".freeze

  class CLI
    attr_reader :opts

    def initialize
      @opts = {
        json: DEFAULT_JSON_URL,
      }
    end

    def run!
      opt_parser = OptionParser.new do |parser|
        add_actions(parser)
        add_client_options(parser)
        add_help_options(parser)
      end

      opt_parser.parse!
      call
    rescue Net::HTTPServerError => e
      warn "Unable to continue: bad response from search API:"
      $sterr.puts e.backtrace
    end

    def call
      if opts[:verbose]
        Logging.logger.root.level = :debug
        Logging.logger.root.info "Debug logging enabled"
      end

      if opts[:download]
        FileUtils.mkdir_p(DATA_DIR)
        HealthCheck::Downloader.new(data_dir: DATA_DIR).download!
      elsif opts[:type] == "suggestions"
        run_suggestions_test
      elsif opts[:type] == "curated"
        run_search_result_tests
      else
        run_click_model_benchmark
      end
    end

  private

    def run_search_result_tests
      check_file_path = DATA_DIR + "search-results.csv"
      check_file = open_file(check_file_path)

      health_check = HealthCheck::SearchChecker.new(
        search_client: search_client,
        test_data: check_file,
      )

      health_check.run!
      health_check.print_summary
    end

    # Run a health-check on the suggestions in suggestions.csv
    def run_suggestions_test
      check_file = open_file(DATA_DIR + "suggestions.csv")

      calculator = HealthCheck::SuggestionChecker.new(
        search_client: search_client,
        test_data: check_file,
      ).run!

      calculator.summarise("Overall score")
    end

    def run_click_model_benchmark
      ClickModelBenchmark.new(search_client: search_client).run!
    end

    def search_client
      HealthCheck::JsonSearchClient.new(
        base_url: URI.parse(opts[:json]),
        authentication: opts[:auth],
        rate_limit_token: opts[:rate_limit_token],
      )
    end

    def open_file(filename)
      file = open(filename)

      # Take the first n + 1 lines (including header row) from the check file
      if opts[:limit]
        file = StringIO.new(file.take(opts[:limit] + 1).join)
      end

      file
    end

    def add_client_options(parser)
      parser.on "-a", "--auth=AUTH", "Basic auth credentials (of the form 'user:pass'" do |auth|
        opts[:auth] = HealthCheck::BasicAuthCredentials.call(auth)
      end

      parser.on "--rate_limit_token=TOKEN", "Token to bypass rate limiting" do |token|
        opts[:rate_limit_token] = token
      end

      parser.on "-j", "--json=URL", "Connect to a Rummager search endpoint at the the given url (default) (eg. #{DEFAULT_JSON_URL})" do |json|
        opts[:json] = json
      end
    end

    def add_help_options(parser)
      parser.on "-h", "--help", "Show this message" do
        puts parser
        exit
      end

      parser.on "-v", "--verbose", "Show verbose logging output" do
        opts[:verbose] = true
      end

      parser.banner = %{Usage: #{File.basename(__FILE__)}

      Runs a health check.
      }
    end

    def add_actions(parser)
      parser.on "--type=TYPE", "Which tests to run. 'suggestions' or 'results' (default)" do |type|
        opts[:type] = type
      end

      parser.on "-d", "--download", "Download search healthcheck data" do
        opts[:download] = true
      end

      parser.on "--limit=N", "Limit to the first n tests" do |n|
        opts[:limit] = n.to_i
      end
    end
  end
end
