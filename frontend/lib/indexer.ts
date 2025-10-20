import { createClient } from "@ponder/client";

/**
 * Ponder indexer client for SQL-over-HTTP queries
 * Base URL points to localhost:42069 where the indexer is running
 */
export const ponderClient = createClient(
  process.env.NEXT_PUBLIC_INDEXER_URL ||
    (process.env.NODE_ENV === "production"
      ? "https://protocolites-production.up.railway.app/sql"
      : "http://localhost:42069/sql"),
);
