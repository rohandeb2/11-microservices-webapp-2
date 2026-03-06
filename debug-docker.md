1. The "Case Sensitivity" Bug (Linux vs. Windows)
The Error: exec: "/app/bin/adservice": stat /app/bin/adservice: no such file or directory.

The Cause: You were developing on a case-insensitive system, but Linux is case-sensitive. The Gradle build produced AdService, but the Dockerfile looked for adservice.

Interview Tip: Explain how you used ls inside the build directory to verify the exact artifact name and aligned the ENTRYPOINT to match the Linux filesystem requirements.

2. The "Permission Denied" (Exit Code 126)
The Error: /bin/sh: ./gradlew: Permission denied.

The Cause: The Gradle wrapper script (gradlew) lost its "executable" bit during the transfer from the host to the Docker container.

The Fix: You used chmod +x inside the Dockerfile and locally.

Interview Tip: Mention Git Index permissions—git update-index --chmod=+x—as the permanent fix for CI/CD pipelines to ensure the bit is preserved in the repository.

3. The "Alpine vs. Glibc" (Architecture Mismatch)
The Error: No such file or directory while running protoc (gRPC tools) on Alpine.

The Cause: gRPC tools often download a binary compiled for glibc (Debian/Ubuntu), but Alpine uses musl.

The Fix: You used a Multi-Stage build with a Debian-based SDK for building and an Alpine-based image for the runtime.

Interview Tip: Discuss the tradeoff between image size (Alpine) and binary compatibility (Debian/Ubuntu).

4. The "User ID / Group" Mismatch
The Error: unable to find group 65532: no matching entries in group file.

The Cause: You tried to use the Distroless "nonroot" user ID (65532) on a standard Python or Alpine image where that user doesn't exist.

The Fix: You implemented explicit user/group creation (addgroup and adduser) for Python/Java and used nonroot:nonroot for Go services.

Interview Tip: This shows your commitment to DevSecOps and the "Principle of Least Privilege" by refusing to run containers as root.

5. The "Pathing" Mystery (Multi-Stage Artifacts)
The Error: failed to compute cache key: /app/build/install/adservice: not found.

The Cause: Gradle's installDist task created a folder named hipstershop because of the settings.gradle configuration, but the Dockerfile was hardcoded to look for a folder named adservice.

The Fix: You used find to locate the folder and correctly mapped the COPY --from=builder command.

6. The "Go Build" Redundancy
The Error: Attempting to run go build between the builder stage and the final stage.

The Cause: A syntax error where a command was placed outside of any defined FROM stage.

The Fix: Cleaning up the Dockerfile structure to ensure all operations happen within the proper context.

7. Docker Compose Strategy (Service Discovery)
The Problem: The frontend was "Created" but couldn't talk to the backend.

The Cause: Hardcoded localhost connections instead of using Docker's internal DNS (Service Names).

The Fix: Implementing Environment Variables (e.g., AD_SERVICE_ADDR=adservice:9555) to allow services to communicate across the boutique-network.



8. The "Zombie Container" (Signal Handling)
The Problem: Containers were taking 10+ seconds to stop, or not shutting down gracefully when you ran docker compose down.

The Cause: Using "Shell Form" (ENTRYPOINT python app.py) instead of "Exec Form" (ENTRYPOINT ["python", "app.py"]). In Shell form, the shell (/bin/sh) becomes PID 1 and ignores SIGTERM signals.

The Fix: You standardized all 11 Dockerfiles to use the JSON Array/Exec Form.

Interview Tip: This proves you understand how Kubernetes handles Graceful Shutdowns and avoids data corruption during pod evictions.

9. The "Dependency Chain" Failure
The Problem: The checkoutservice or frontend would crash immediately on startup because they couldn't connect to redis or the productcatalog.

The Cause: Docker starts containers in parallel. Even if a container is "Running," the application inside might not be ready to accept connections yet.

The Fix: You utilized depends_on with condition: service_healthy in your docker-compose.yml to ensure the database (Redis) was actually ready before the app started.

10. The "Fat Image" Bloat
The Problem: Initially, your images were 800MB–1GB (especially Java and .NET).

The Cause: Including the entire SDK, source code, and build tools in the final production image.

The Fix: You implemented Multi-Stage builds and switched to Distroless and Alpine runtimes, bringing images down to ~50MB–200MB.

Interview Tip: This is a direct cost-saving measure for AWS (lower ECR storage costs and faster scaling/pull times).

11. The "Broken Bridge" (Service Discovery)
The Problem: Services were throwing "Connection Refused" or "DNS not found" errors.

The Cause: Relying on default network behavior without explicitly defining a Custom Bridge Network and proper Aliasing.

The Fix: You created the boutique-network and assigned aliases, allowing the frontend to reach the adservice using a simple hostname instead of an unstable IP address.

12. The "JVM Container Blindness"
The Problem: The adservice was getting OOMKilled (Out of Memory) even though the container had 1GB of RAM.

The Cause: Older Java versions (and some configurations) don't realize they are in a container and try to use the RAM of the entire Host (your laptop/Node), causing the Docker Cgroup to kill the process.

The Fix: You applied -XX:MaxRAMPercentage=75.0 to ensure the JVM respects the Docker memory limits.++



<!-- copy the dockerfile fromt he oriignal repo and try to make docker compose and try to run see if any error occurs or not -->


