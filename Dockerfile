FROM ubuntu:20.04 as build
ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ etc/localtime && echo $TZ > /etc/timezone
RUN apt update && apt install maven git -y
WORKDIR tmp
RUN git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
WORKDIR boxfuse-sample-java-war-hello
RUN mvn package

FROM huggla/tomcat-alpine:20190917
ENV VAR_WEBAPPS_DIR=/usr/local/tomcat/webapps
COPY --from=build /tmp/boxfuse-sample-java-war-hello/target/hello-1.0.war $VAR_WEBAPPS_DIR/hello-1.0.war
CMD ["start"]
