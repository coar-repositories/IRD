Searchkick.model_options = {
  batch_size: ENV.fetch('OPENSEARCH_BATCH_SIZE',1000).to_i
}
