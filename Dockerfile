FROM dakusui/jq-front:v0.43
ADD out/main/scripts/ /app/
RUN chmod 755 /app/bin/testrunner
ENV PS1 '# '
ENV LANG=en_US.UTF-8
ENV PATH="/app:${PATH}"
RUN find /app && \
    apt-get update && \
    apt-get install git -y && \
    apt-get install curl -y && \
    apt-get install openjdk-8-jdk -y && \
    mkdir -p /var/lib/cmd-unit
ENTRYPOINT ["/app/bin/testrunner"]
