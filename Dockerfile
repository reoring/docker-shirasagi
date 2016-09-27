FROM centos:7.2.1511

RUN yum -y update
RUN yum -y groupinstall "Development Tools"
RUN yum -y install ImageMagick ImageMagick-devel sudo wget git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel

# Install RVM, Ruby 2.3.1
RUN yum -y install curl git which tar
RUN sed -i '0,/enabled=.*/{s/enabled=.*/enabled=1/}' /etc/yum.repos.d/CentOS-Base.repo
RUN wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm && rpm -ivh epel-release-7-8.noarch.rpm
RUN yum update -y
RUN yum -y install nginx

# Install rbenv and ruby-build
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN /root/.rbenv/plugins/ruby-build/install.sh
ENV PATH /root/.rbenv/bin:$PATH
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> .bashrc
# Install multiple versions of ruby
ENV CONFIGURE_OPTS --disable-install-doc
ADD ./versions.txt /root/versions.txt
RUN xargs -L 1 rbenv install < /root/versions.txt

# Install Bundler for each version of ruby
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN bash -l -c 'for v in $(cat /root/versions.txt); do rbenv global $v; gem install bundler; done'

# Install MongoDB
#ADD ./10gen.txt /
#RUN cat /10gen.txt >> /etc/yum.repos.d/mongodb.repo
#RUN yum -y --enablerepo=10gen install mongo-10gen mongo-10gen-server
#RUN mkdir -p /data/db
#RUN /sbin/chkconfig mongod on

# Install Mecab
RUN rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm
RUN yum makecache
RUN yum -y install mecab mecab-ipadic

# Install Shirasagi
RUN git clone -b stable --depth 1 https://github.com/shirasagi/shirasagi /var/www/shirasagi
WORKDIR /var/www/shirasagi
RUN cp -n config/samples/*.{rb,yml} config/
ADD config/mongoid.yml config/
ADD config/unicorn.rb config/
RUN /bin/bash -l -c "bundle --without test development"
RUN /bin/bash -l -c "bundle exec rake assets:precompile"

ADD config/nginx.conf /etc/nginx/conf.d/
ADD config/default-nginx.conf /etc/nginx/nginx.conf

# CMD ["bundle exec rake unicorn:start && tail -f log/*"]

ADD start.sh /var/www/shirasagi
RUN chmod +x start.sh

ENTRYPOINT ["bash", "-l", "-c"]
CMD ["/var/www/shirasagi/start.sh"]
