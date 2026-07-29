# ==============================
# Stage 1 - Build Application
# ==============================
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .

COPY src ./src

RUN mvn clean package -DskipTests

# ==============================
# Stage 2 - Runtime Image
# ==============================
FROM eclipse-temurin:17-jre

LABEL maintainer="Dandu Rama Siva Naga Raju"

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8083

ENTRYPOINT ["java","-jar","app.jar"]