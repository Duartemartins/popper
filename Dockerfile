# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.3.0
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

# Install base runtime packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libjemalloc2 \
      libvips \
      sqlite3 && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# ————— Build stage —————
FROM base AS build

# Tell rbsecp256k1 to use the system library (note singular 'library')
ENV BUNDLE_BUILD__RBSECP256K1="--with-system-library"

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libyaml-dev \
      libsecp256k1-dev \
      pkg-config \
      autoconf \
      automake \
      libtool \
      libgmp-dev \
      gettext \
      libffi-dev \
      libssl-dev \
      python3-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets without requiring RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# ————— Runtime stage —————
FROM base

# Install only the shared libs necessary at runtime
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      libgmp10 \
      libffi8 \
      libssl3 \
      libsecp256k1-0 && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

WORKDIR /rails

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Create non-root user and set permissions
RUN groupadd --system --gid 1000 rails && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash rails && \
    mkdir -p /rails/public/up && \
    echo "OK" > /rails/public/up/index.html && \
    chmod -R 755 /rails/public && \
    chown -R rails:rails /rails /usr/local/bundle

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
HEALTHCHECK --interval=5s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3000/up/ || exit 1

USER 1000:1000
CMD ["./bin/thrust", "./bin/rails", "server"]