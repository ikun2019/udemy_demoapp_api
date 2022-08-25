# ベースイメージを指定する
FROM ruby:2.7.2-alpine

# Dockerfime内で使用する変数を定義
# appが入る
ARG WORKDIR
ARG RUNTIME_PACKAGES="nodejs tzdata postgresql-dev postgresql git"
ARG DEV_PACKAGES="build-base curl-dev"

# 環境変数を定義(Dockerfile、コンテナから参照可能)
ENV HOME=/${WORKDIR} \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo

# ENV test（このRUN命令は確認のためなので無くても良い）
# ベースイメージに対してコマンドを実行する(変数を展開するように指示)
# RUN echo ${HOME}

# Dockerfile内で指定した命令を実行する RUN COPY ADD ENTRYPOINT CMD
# 作業ディレクトリを定義
# コンテナ/app/Railsアプリの階層で作成される。Homeにはappが入る。
WORKDIR ${HOME}

# ホスト側のファイルをコンテナにコピー
COPY Gemfile* ./

# apkはAlpineLinuxのコマンド
RUN apk update && \
    apk upgrade && \
    apk add --no-cache ${RUNTIME_PACKAGES} && \
    apk add --virtual build-dependencies --no-cache ${DEV_PACKAGES} && \
    bundle config set force_ruby_platform true && \
    bundle install -j4 && \
    apk del build-dependencies

COPY . ./

# コンテナ内で実行したいコマンドを定義
CMD ["rails", "server", "-b", "0.0.0.0"]