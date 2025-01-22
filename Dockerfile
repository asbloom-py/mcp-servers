# Use a Node.js image to build the application
FROM node:22.12-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy the package manager files to the working directory
COPY package.json yarn.lock /app/

# Install dependencies
RUN yarn install

# Copy the rest of the application to the working directory
COPY . /app

# Build the TypeScript application
RUN yarn build

# Prepare the release image
FROM node:22.12-alpine AS release

# Set the working directory
WORKDIR /app

# Copy the built application from the builder image
COPY --from=builder /app/github/dist /app/dist
COPY --from=builder /app/github/package.json /app/package.json
COPY --from=builder /app/yarn.lock /app/yarn.lock

# Install production dependencies
RUN yarn install --production

# Environment variable for the GitHub Personal Access Token
ENV GITHUB_PERSONAL_ACCESS_TOKEN=<YOUR_TOKEN>

# Specify the command to run the application
ENTRYPOINT ["node", "dist/index.js"]