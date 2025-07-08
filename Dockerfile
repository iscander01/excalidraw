FROM node:18 AS builder

# Set working directory
WORKDIR /app

# Copy package manager files
COPY package.json yarn.lock ./

# Install dependencies for the root project
RUN yarn install --frozen-lockfile

# Copy the entire project
COPY . .

# Install dependencies for each workspace
RUN yarn workspaces foreach --no-private run install

# Build the application
RUN yarn --cwd ./excalidraw-app build

# Production stage
FROM node:18-slim AS production

# Create a non-root user
RUN useradd --user-group --create-home --shell /bin/false appuser

# Set working directory
WORKDIR /app

# Copy built files from the builder stage
COPY --from=builder /app/excalidraw-app/build ./excalidraw-app/build

# Copy package.json and yarn.lock for production dependencies
COPY package.json yarn.lock ./

# Install only production dependencies
RUN yarn install --production --frozen-lockfile

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose the application port
EXPOSE 3000

# Start the application
CMD ["yarn", "--cwd", "./excalidraw-app", "start"]