FROM dakusui/jq-front:v0.43
ADD out/main/scripts/ /app/
RUN chmod 755 /app/bin/testrunner
ENV LANG=en_US.UTF-8
ENV PATH="/app:${PATH}"
RUN find /app && \
    apt-get update && \
    mkdir -p /var/lib/cmd-unit
ENTRYPOINT ["/app/bin/testrunner"]
