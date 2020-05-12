FROM funnyzak/java8-nodejs-python-go-etc

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.vendor="potato<silenceace@gmail.com>" \
    org.label-schema.name="GitWebhookRun" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.description="Pull your project git code into a data volume and trigger run event via Webhook." \
    org.label-schema.url="https://yycc.me" \
    org.label-schema.schema-version="1.0"	\
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.vcs-url="https://github.com/funnyzak/git-webhook-docker" 

ENV LANG=C.UTF-8

# Create Dir
RUN mkdir -p /app/hook && mkdir -p /app/code && mkdir -p /var/log/webhook

# Copy webhook config
COPY conf/hooks.json /app/hook/hooks.json
COPY scripts/hook.sh /app/hook/hook.sh

# Copy our Scripts
COPY scripts/start.sh /usr/bin/start.sh
COPY scripts/utils.sh /app/scripts/utils.sh
COPY scripts/run_scripts_after_pull.sh /usr/bin/run_scripts_after_pull.sh
COPY scripts/run_scripts_before_pull.sh /usr/bin/run_scripts_before_pull.sh
COPY scripts/run_scripts_on_startup.sh /usr/bin/run_scripts_on_startup.sh
COPY scripts/run_scripts_after_package.sh /usr/bin/run_scripts_after_package.sh

# Add permissions to our scripts
RUN chmod +x /app/scripts/utils.sh
RUN chmod +x /app/hook/hook.sh
RUN chmod +x /usr/bin/run_scripts_after_pull.sh
RUN chmod +x /usr/bin/run_scripts_before_pull.sh
RUN chmod +x /usr/bin/run_scripts_on_startup.sh
RUN chmod +x /usr/bin/run_scripts_after_package.sh

# Add any user custom scripts + set permissions
ADD custom_scripts /custom_scripts
RUN chmod +x -R /custom_scripts

RUN chmod +x -R /app/code
WORKDIR /app/code

# Expose Webhook port
EXPOSE 9000

# run start script
ENTRYPOINT ["/bin/bash", "/usr/bin/start.sh"]
