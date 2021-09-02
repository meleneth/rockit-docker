FROM phusion/passenger-full:latest
MAINTAINER Jason Parmer <meleneth@gmail.com>
RUN mkdir -p /home/app/rockit
RUN chown app:app /home/app/rockit
WORKDIR /home/app/rockit
COPY ./rockit/package.json ./package.json
RUN chown app:app ./package.json
RUN npm install -g yarn
RUN gem install ffi -v 1.15.3
RUN su -c "yarn install" app
COPY ./rockit/Gemfile ./Gemfile
#COPY ./rockit/Gemfile.lock ./Gemfile.lock
#COPY ./rockit/yarn.lock ./yarn.lock
RUN chown app:app Gemfile  yarn.lock
RUN su -c "bundle install" app
COPY --chown=app:app ./rockit .
RUN su -c "git checkout -- ." app
RUN bash -lc 'rvm --default use ruby-3.0.2'
RUN su -c 'SECRET_KEY_BASE=`bin/rake secret` RAILS_ENV=production ./bin/rails assets:precompile' app
RUN rm -f /etc/service/nginx/down
copy --chown=root:root ./rockit.conf /etc/nginx/sites-enabled/rockit.conf
EXPOSE 80
