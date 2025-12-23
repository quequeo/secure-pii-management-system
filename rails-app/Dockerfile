FROM ruby:3.2.4-alpine

RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    curl

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
