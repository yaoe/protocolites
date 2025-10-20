import { createClient } from "@ponder/client";

/**
 * Ponder indexer client for SQL-over-HTTP queries
 * Base URL points to localhost:42069 where the indexer is running
 */
export const ponderClient = createClient("http://127.0.0.1:42069/sql");

/**
 * REST API base URL for custom endpoints
 */
export const INDEXER_API_URL = "http://localhost:42069/api";
