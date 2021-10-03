FROM jekyll/jekyll

EXPOSE 4000

WORKDIR /srv/jekyll

COPY ./Gemfile /srv/jekyll/Gemfile
COPY ./Gemfile.lock /srv/jekyll/Gemfile.lock

RUN bundle install

CMD ["bundle", "exec", "jekyll", "serve", "-H", "0.0.0.0", "-P", "4000"]
