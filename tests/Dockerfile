FROM mcr.microsoft.com/playwright:v1.58.2-noble

WORKDIR /tests
COPY package.json package-lock.json ./
RUN npm ci
COPY . .

ENTRYPOINT ["npx", "playwright", "test"]
