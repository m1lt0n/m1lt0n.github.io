FROM ruby:3.4.7

EXPOSE 4000

ENV BUNDLE_FROZEN=true
WORKDIR /srv/jekyll

RUN gem install bundler -v 2.6.9
RUN gem install jekyll

COPY Gemfile* .

RUN bundle install

CMD ["bundle", "exec", "jekyll", "serve", "-H", "0.0.0.0"]
