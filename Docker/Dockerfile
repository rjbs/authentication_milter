# DOCKER-VERSION 0.3.4
FROM        debian:jessie
MAINTAINER  Marc Bradshaw <marc@marcbradshaw.net>

# Install required libraries
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y \
        bzip2 \
        cron \
        gcc \
        libmysqlclient-dev \
        libssl-dev \
        libxml2-dev \
        make \
        patch \
        perlbrew

# Install perl to perlbrew
RUN perlbrew init && \
    perlbrew install perl-5.20.0 && \
    perlbrew switch perl-5.20.0 && \
    perlbrew install-cpanm

# Install perl modules
RUN perlbrew exec cpanm \
        Module::Install && \
    perlbrew exec cpanm --notest \
        Mail::SPF --install-args="--install-path sbin=/tmp" && \
    perlbrew exec cpanm \
        DBD::mysql \
        Mail::Milter::Authentication

# Cleanup
RUN perlbrew clean && \
    apt-get clean

ADD startup.pl /opt/startup.pl
CMD [ "/perl5/perlbrew/perls/perl-5.20.0/bin/perl", "/opt/startup.pl" ]

