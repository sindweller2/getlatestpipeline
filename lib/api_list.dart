String getLatestPipeline(String url, String project, String ref) {
  return 'https://' +
      url +
      '/api/v4/projects/' +
      project +
      '/pipelines/latest?ref=' +
      ref;
}
