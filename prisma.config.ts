import { config } from "dotenv";
import { defineConfig } from "prisma/config";

// Load .env first. Do not let a stale .env.local override DATABASE_URL / DIRECT_URL.
config({ path: ".env" });
config({ path: ".env.local" });

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  datasource: {
    // Prisma 7 CLI uses this URL for migrate/introspect/studio.
    // Use the session-mode (direct) pooler, not transaction-mode pgbouncer.
    url: process.env.DIRECT_URL ?? "",
  },
});
