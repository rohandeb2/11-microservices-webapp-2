.dockerignore — Quick DevOps Notes

Purpose

Excludes unnecessary files from Docker build context.

Makes builds faster, images smaller, and protects secrets.

Common Entries & Why

Git

.git
.gitignore

→ Prevents sending repository history to Docker.

Build artifacts

.gradle/
build/
out/

→ Temporary build files not needed in container.

Allow only final artifact

!build/libs/*.jar

→ Keeps only compiled JAR needed to run the app.

Logs

*.log
logs/

→ Runtime files, unnecessary for image build.

Environment files

.env
.env.*

→ May contain secrets (API keys, passwords).

IDE configs

.vscode/
.idea/

→ Local editor settings, irrelevant to container.

OS junk

.DS_Store
Thumbs.db

→ Auto-generated OS files.

Tests

src/test/

→ Used during development, not required in production image.

Docs

README.md

→ Useful for repo, not needed in container.





