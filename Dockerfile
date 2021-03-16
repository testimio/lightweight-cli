FROM node:12.21.0-stretch

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install google-chrome-stable xvfb \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN npm i -g @testim/testim-cli && mkdir -p /usr/testim/extension

ADD https://testimstatic.blob.core.windows.net/extension/testim-headless.zip /usr/testim/extension
RUN cd /usr/testim/extension \
  && unzip testim-headless.zip 

COPY wrap_chrome_binary /opt/bin/wrap_chrome_binary
RUN /opt/bin/wrap_chrome_binary

ENV CACHE=/tmp/testimcache/
ENV EXTENSION=/usr/testim/extension/
ENV TESTIM_CMD="testim --file-cache-location ${CACHE} --use-chrome-launcher --lightweight-mode --ext ${EXTENSION}"

VOLUME /tmp/testimcache/

WORKDIR /usr/testim
ENTRYPOINT ["testim", "--file-cache-location", "/tmp/testimcache/", "--use-chrome-launcher", "--lightweight-mode", "--ext", "./extension"]
