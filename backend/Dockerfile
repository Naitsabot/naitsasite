FROM nimlang/nim:latest

WORKDIR /usr/src/app

COPY . .

RUN nimble build -y

EXPOSE 8080

CMD ["naitsabackendapp"]
