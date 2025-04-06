FROM ruby:3.4.2-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./

RUN bundle config set --local without 'development test' && \
  bundle install --jobs 4 --retry 3

FROM ruby:3.4.2-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
  tzdata \
  libjemalloc-dev \
  netcat-openbsd \
  libssl-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2 \
  RUBY_YJIT_ENABLE=1 \
  RUBYOPT="-W0 --yjit" \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  TZ=UTC

COPY --from=builder /usr/local/bundle /usr/local/bundle

COPY . .

RUN chmod +x ./bin/server

EXPOSE 8888

CMD ["./bin/server"]
