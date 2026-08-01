FROM lua:5.1

# Required for luarocks installation
RUN apk add make openssl gcc libc-dev

# luarocks use the $USER to identify user -.-
# https://github.com/luarocks/luarocks/issues/901#issuecomment-426585122
ENV USER root

RUN mkdir ~/tmp-luarocks && cd ~/tmp-luarocks \
    && wget https://luarocks.org/releases/luarocks-3.0.4.tar.gz \
    && tar zxpf luarocks-3.0.4.tar.gz \
    && cd luarocks-3.0.4 \
    && ./configure > /dev/null \
    && make build > /dev/null \
    && make install > /dev/null \
    && cd / && rm -rf /tmp-luarocks

# Required by luarocks to install packages
RUN apk add unzip curl

ENTRYPOINT ["luarocks"]
