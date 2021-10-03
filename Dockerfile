FROM jekyll/jekyll

EXPOSE 4000

WORKDIR /srv/jekyll

COPY ./Gemfile* ./

RUN bundle install

CMD ["bundle", "exec", "jekyll", "serve", "-H", "0.0.0.0"]
