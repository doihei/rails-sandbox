FROM ruby:3.4-slim AS base
WORKDIR /app

RUN apt-get update -qq && apt-get install -y \
  build-essential libpq-dev curl libyaml-dev && \
  rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && bundle install

COPY . .

ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV PORT=8080

EXPOSE 8080
# TODO: 動作確認用。本番では別途migrationジョブを実行すること
CMD ["sh", "-c", "bundle exec rails db:migrate db:seed && bundle exec rails server -b 0.0.0.0 -p 8080"]
