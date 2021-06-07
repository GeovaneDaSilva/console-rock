# frozen_string_literal: true

PIPELINE_CONFIGS = {
  archive: {
    app_results_threshold:  95.days, # how long to wait before archiving app results
    result_count_threshold: 10_000,
    destroy_limit:          2000,
    archive_limit:          5000
  }
}.with_indifferent_access
