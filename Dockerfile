FROM ruby:3.3.9
LABEL maintainer=ist@scalingo.com

COPY . /usr/src/app/
WORKDIR /usr/src/app

RUN bundle install --without development test

ENTRYPOINT ["bash", "bin/docker-entrypoint.sh"]
