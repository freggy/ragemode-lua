FROM openjdk:17 AS builder
WORKDIR /build
ADD https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/451/downloads/paper-1.20.4-451.jar paper.jar
RUN java -jar paper.jar

FROM gcr.io/distroless/java17
WORKDIR /opt/paper
ADD https://hangarcdn.papermc.io/plugins/Saturn/LuaLink/versions/1.20.2-52/PAPER/LuaLink-1.20.2-52.jar /opt/paper/plugins/ll.jar
COPY --from=builder /build/paper.jar /opt/paper/paper.jar
COPY --from=builder /build/cache /opt/paper/cache
COPY ./hijacked /opt/paper/world
COPY ./ragemode.lua /opt/paper/plugins/LuaLink/scripts/ragemode.lua
ENV JAVA_TOOL_OPTIONS="-Dcom.mojang.eula.agree=true --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED"
CMD ["paper.jar", "--nogui"]
