FROM jekyll/jekyll:3.8
ENV JEKYLL_ENV=development
RUN bundle update jekyll
RUN bundle install
RUN bundle exec jekyll serve --watch --incremental --config _config-dev.yaml --host 0.0.0.0 --drafts
EXPOSE 4000
