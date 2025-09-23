FROM ruby:3.3
LABEL maintainer=ist@scalingo.com

COPY . /usr/src/app/
WORKDIR /usr/src/app

RUN bundle install --without development test

CMD ["bundle", "exec", "ruby", "bin/docker-cleaner"]
