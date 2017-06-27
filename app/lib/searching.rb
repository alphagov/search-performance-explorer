class Searching
  attr_reader :params
  def initialize(params)
    @params = params
  end

  def count
    return 10 if params["count"].blank?
    return 1000 if params["count"].to_i > 1000
    params["count"]
  end

  def call
    terms = params["search_term"].split.join("+")
    url = "https://www.gov.uk/api/search.json?q=#{terms}&count=#{count}"

    # Creates an empty hash to put the search results from our 'A'
    #    test in, also an array to add our 'A' titles and a counter
    #    to increment within each of the following loops

     a_list = {}
     a_list_titles = []
     a_counter = 0
     b_counter = 0

    # <h2 class="results-header">A Results</h2>
    # Adds the A test parameter to the URL
     uri = URI("#{url}&ab_tests=#{params["which_test"]}:A")
    # Gets a result from the search API based on the URL we made
     response = Net::HTTP.get(uri)
     findings_left = JSON.parse(response)
    # Loops over the 'results' section of our result
     findings_left["results"].each do |each_bit|
      # increments counter and creates hash entry based on link and counter
       a_counter += 1
       a_list["#{each_bit["link"]}"] = a_counter
       a_list_titles << each_bit["title"]
     end
     uri = URI("#{url}&ab_tests=#{params["which_test"]}:B")
     response = Net::HTTP.get(uri)
     findings_right = JSON.parse(response)
     [findings_left, findings_right, a_list, a_list_titles]
  end

end
