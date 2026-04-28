# Sentinel Protocol API - Production Dockerfile
FROM node:18-slim

WORKDIR /app

# Install dependencies first for caching
COPY package*.json ./
RUN npm install --production

# Copy source code
COPY . .

# Expose Sentinel Engine port
EXPOSE 3000

# Health check to ensure truth engine is online
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:3000/api/verify/health || exit 1

CMD ["node", "server.js"]
