ARG RUBY_VERSION=ruby:3.1.4
ARG NODE_VERSION=18

FROM $RUBY_VERSION
ARG RUBY_VERSION
ARG NODE_VERSION
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

# Node.jsとYarnのインストール
RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq \
    && apt-get install -y build-essential nodejs yarn

# アプリケーションディレクトリの作成
RUN mkdir /app
WORKDIR /app

# Bundlerのインストール
RUN gem install bundler

# Gemfileとyarnファイルのコピー
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY yarn.lock /app/yarn.lock

# Gemfileとyarnの依存関係のインストール
RUN bundle install
RUN yarn install
# アプリケーションコードのコピー
COPY . /app

# node_modulesの削除（必要に応じて）
RUN rm -rf node_modules

# 依存関係の再インストール
RUN yarn install --check-files

# アセットのプリコンパイル
RUN echo "Before precompile" && ls -la && RAILS_ENV=production bundle exec rake assets:precompile --trace && echo "After precompile"

# サーバーの起動
CMD ["rails", "server", "-b", "0.0.0.0"]