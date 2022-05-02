ARG WODBY_BASE_IMAGE
FROM ${WODBY_BASE_IMAGE}

ARG COPY_FROM
ARG COPY_TO
COPY --chown=wodby:wodby ${COPY_FROM} ${COPY_TO}

RUN make init -f /usr/local/bin/actions.mk
