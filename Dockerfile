FROM ruby:latest

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y nodejs mysql-client libmysqlclient-dev vim --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV development
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

COPY Gemfile /usr/src/app/
#COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app
EXPOSE 3000
RUN bundle install
RUN rails db:migrate
CMD ["rails", "server", "-b", "0.0.0.0"]
