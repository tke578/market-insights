FROM ruby:2.6.3

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y build-essential nodejs yarn postgresql-client

RUN mkdir /market-insights

WORKDIR /market-insights

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . /market-insights

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]


LABEL maintainer="tke578@gmail.com"