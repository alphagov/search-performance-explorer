# Benchmarking search using the health check script

TODO: consider updating mentions to Rummager, as it was renamed to Search on gds-api-adapters version 63.0.0.

As we work on rummager we want some objective metrics of the performance of search, i.e. does it return useful results? That's what the health check is for.

It can run 3 kinds of checks.

## Click model benchmark

This is the default test.

Run it using `./bin/health_check -j "https://www.gov.uk/api/search.json"`.

The `-j` argument can be replaced with the URL of any rummager instance you want to test.

The benchmark runs some of the most popular search queries, and evaluates the results using a [click model](http://clickmodels.weebly.com/the-book.html) trained on Google Analytics data.

It outputs a percentage score for the whole test set. The score will be 100% if all the results are ranked in the "best" order according to the click model.

### Use case
The advantage of this benchmark is it spits out a single number and it runs quickly, so it can be used to optimise features of the ranking algorithm.

The score considers whole result pages but pays more attention to what's at the top (or what's not at the top).

### Limitations
The benchmark only looks at a narrow slice of queries (the most popular ones), so it's not representive of all users. In particular, it doesn't test queries that use multiple words, and it doesn't include spelling errors or alternative ways of referring to things.

### Updating the data
The model is stored as a JSON file in `data/click_model.json`. This was created using the [PyClick python library](https://github.com/markovi/PyClick) and data from BigQuery. For more details see the [python code](https://github.com/MatMoore/accelerator/) used to process the data.

The model will become out of date as new content is added to GOV.UK and query trends change over time.

## Curated checks
This test looks at manually curated queries and search results stored in a spreadsheet.

For each query/result pair there is a simple check that verifies whether the result was found or not found in the top N results.

To run it first download the healthcheck data:

```
./bin/health_check -d
```

Then run against your chosen indices:

```
./bin/health_check
```

Against remote:

```
./bin/health_check -j "https://www.gov.uk/api/search.json"
```

Against development:

```
./bin/health_check -j "http://www.dev.gov.uk/api/search.json"
```

### Use case
You can use these checks to get an idea of what's changed when modifying the search algorithm. If a huge number of checks suddenly fail, it's a good sign
that something isn't working as expected.

Queries are also tagged which can be useful for identifying particular queries that are relevant to what you are changing.

Example tags:

- benchmarking-bank-holidays
- long-word-count

### Limitations
The number of passed checks is an unreliable way to measure how search is performing. The checks do not distinguish between results going up or down by 1 or 2 ranks and results completely dissapearing.

In the past, we've found it useful to copy the raw check results into a spreadsheet and analyse the change in position of search results as well as
whether the check actually passed.

The checks typically only look at one or 2 results per query, and mostly ensure that specific results *are* in the top N results. It doesn't do a good job of flagging bad results that also show up in the top N results.

### Updating the data
The data is stored in a [spreadsheet](https://docs.google.com/spreadsheets/d/1JjSoy68vscNjrvQm8b9hHt0nbZgFxk8lrcTdqV08iHk/edit#gid=1400194374) which has been compiled by hand.

Some of the checks were based on other data sources. For example: we've used Google Analytics to find queries with high refinement rates and then manually identified content that might answer the query.

## Suggestions checks
This checks a set of search terms to see whether the search API spelling suggestions are working as expected.

You will first need to download the data using:

```
./bin/health_check -d
```

Then run

```
./bin/health_check -j "https://www.gov.uk/api/search.json" -t suggestions
```

Unlike the curated checks, the results of these checks are unambiguous. It either corrected the query or it didn't.

Ideally, all these tests should pass, but in practice there may be some amount of false positives (returning a suggestion for a valid search term) and false negatives (not returning a suggestion for a misspelt search term).

### Use case
This should be used for testing any changes to the spelling suggestion functionality. Spelling suggestions are important because without them the user
is likely to just get stuck with a bad results page and give up.

### Updating the data

The data is stored in the [spelling tab](https://docs.google.com/spreadsheets/d/1JjSoy68vscNjrvQm8b9hHt0nbZgFxk8lrcTdqV08iHk/edit#gid=9) of the health check spreadsheet.
