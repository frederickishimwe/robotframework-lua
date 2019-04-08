FROM openresty/openresty

LABEL Robot Framework UI

#Variables
ARG app_path=/robot
ARG nginx_conf=/etc/nginx/conf.d
ARG html=/usr/local/openresty/nginx/html

# Perform updates
RUN   apt-get update && apt-get -y upgrade && apt-get install -y \
      unzip  curl    xvfb    python    python-pip  gcc   make    libpcre3-dev   zlib1g-dev

# Chrome browser to run the tests
RUN curl https://dl-ssl.google.com/linux/linux_signing_key.pub -o /tmp/google.pub \
   && cat /tmp/google.pub | apt-key add -; rm /tmp/google.pub \
   && echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/google.list \
   && mkdir -p /usr/share/desktop-directories \
   && apt-get -y update && apt-get install -y --allow-unauthenticated google-chrome-stable
# Disable the SUID sandbox so that chrome can launch without being in a privileged container
RUN dpkg-divert --add --rename --divert /opt/google/chrome/google-chrome.real /opt/google/chrome/google-chrome \
   && echo "#!/bin/bash\nexec /opt/google/chrome/google-chrome.real --no-sandbox --disable-setuid-sandbox \"\$@\"" > /opt/google/chrome/google-chrome \
   && chmod 755 /opt/google/chrome/google-chrome

# Chrome Driver
RUN mkdir -p /opt/selenium \
   && curl http://chromedriver.storage.googleapis.com/2.45/chromedriver_linux64.zip -o /opt/selenium/chromedriver_linux64.zip \
   && cd /opt/selenium; unzip /opt/selenium/chromedriver_linux64.zip; rm -rf chromedriver_linux64.zip; ln -fs /opt/selenium/chromedriver /usr/local/bin/chromedriver;


# Install pip Packages
COPY requirements  ${app_path}/requirements
RUN pip install -r ${app_path}/requirements

# Update PATH
ENV PATH="/usr/local/bin:/usr/bin:/bin:/usr/bin/env:{$PATH}"

EXPOSE 8080
ENV DISPLAY=:99

# Set work directory
WORKDIR  ${app_path}

# Copy contents from current host folder to work directory

CMD ["/usr/bin/openresty", "-g", "daemon off;"]
# CMD ["python","app.py"]
