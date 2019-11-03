FROM quay.io/spivegin/gitonly:latest AS git

FROM quay.io/spivegin/golang:v1.13 AS builder
WORKDIR /opt/src/src/sc.tpnfc.us/askforitpro/

RUN ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa && git config --global user.name "quadtone" && git config --global user.email "quadtone@txtsme.com"
COPY --from=git /root/.ssh /root/.ssh
RUN ssh-keyscan -H github.com > ~/.ssh/known_hosts &&\
    ssh-keyscan -H gitlab.com >> ~/.ssh/known_hosts

#COPY --from=gover /opt/go /opt/go
ENV deploy=c1f18aefcb3d1074d5166520dbf4ac8d2e85bf41 \
    GO111MODULE=on \
    GOPROXY=direct \
    GOSUMDB=off \
    GOPRIVATE=sc.tpnfc.us 
RUN git config --global url.git@github.com:.insteadOf https://github.com/ &&\
    git config --global url.git@gitlab.com:.insteadOf https://gitlab.com/ &&\
    git config --global url."https://${deploy}@sc.tpnfc.us/".insteadOf "https://sc.tpnfc.us/"

#RUN chmod +x /opt/src/src/sc.tpnfc.us/askforitpro/trivia/deps.sh
RUN git clone https://sc.tpnfc.us/askforitpro/trivia.git &&\
    cd trivia &&\
    # go mod tidy &&\
    go build -o /opt/bin/trivia trivia/main.go

FROM quay.io/spivegin/tlmbasedebian
RUN mkdir /opt/bin
COPY --from=builder /opt/src/src/sc.tpnfc.us/askforitpro/trivia/build/trivia /opt/bin/trivia
RUN chmod +x /opt/bin/trivia && ln -s /opt/bin/trivia /bin/trivia
CMD ["trivia", "qa"]

