import { onchainTable, index } from "ponder";

/**
 * Spreaders are the parent NFTs from ProtocolitesMaster
 * Each spreader can have many infections through its infection contract
 */
export const spreader = onchainTable(
  "spreader",
  (t) => ({
    // Composite ID: chainId:contractAddress:tokenId
    id: t.text().primaryKey(),
    tokenId: t.bigint().notNull(),
    owner: t.hex().notNull(),
    dna: t.bigint().notNull(),
    birthBlock: t.bigint().notNull(),
    infectionContractAddress: t.hex().notNull(),

    // Decoded DNA traits for filtering/searching
    bodyType: t.integer().notNull(),
    bodyChar: t.integer().notNull(),
    eyeChar: t.integer().notNull(),
    eyeSize: t.integer().notNull(),
    antennaTip: t.integer().notNull(),
    armStyle: t.integer().notNull(),
    legStyle: t.integer().notNull(),
    hatType: t.integer().notNull(),
    hasCigarette: t.boolean().notNull(),

    // Metadata (decoded from tokenURI)
    name: t.text(),
    description: t.text(),
    image: t.text(),
    animationUrl: t.text(),

    // Derived count
    infectionCount: t.integer().notNull().default(0),

    // Timestamps
    createdAt: t.bigint().notNull(),
    updatedAt: t.bigint().notNull(),
  }),
  (table) => ({
    ownerIdx: index().on(table.owner),
    tokenIdIdx: index().on(table.tokenId),
    infectionCountIdx: index().on(table.infectionCount),
    bodyTypeIdx: index().on(table.bodyType),
  })
);

/**
 * Infections are child NFTs from individual ProtocoliteInfection contracts
 * Each infection belongs to one spreader (parent)
 */
export const infection = onchainTable(
  "infection",
  (t) => ({
    // Composite ID: chainId:contractAddress:tokenId
    id: t.text().primaryKey(),
    tokenId: t.bigint().notNull(),
    parentSpreaderId: t.text().notNull(), // Reference to spreader (indexed, no FK constraint)
    parentTokenId: t.bigint().notNull(),
    infectionContractAddress: t.hex().notNull(),
    owner: t.hex().notNull(),
    dna: t.bigint().notNull(),
    infectedBy: t.hex().notNull(), // Address that triggered the infection
    birthBlock: t.bigint().notNull(),

    // Decoded DNA traits
    bodyType: t.integer().notNull(),
    bodyChar: t.integer().notNull(),
    eyeChar: t.integer().notNull(),
    eyeSize: t.integer().notNull(),
    antennaTip: t.integer().notNull(),
    armStyle: t.integer().notNull(),
    legStyle: t.integer().notNull(),
    hatType: t.integer().notNull(),
    hasCigarette: t.boolean().notNull(),

    // Metadata (decoded from tokenURI)
    name: t.text(),
    description: t.text(),
    image: t.text(),
    animationUrl: t.text(),

    // Timestamps
    createdAt: t.bigint().notNull(),
  }),
  (table) => ({
    ownerIdx: index().on(table.owner),
    parentIdx: index().on(table.parentSpreaderId),
    tokenIdIdx: index().on(table.tokenId),
    infectedByIdx: index().on(table.infectedBy),
  })
);

/**
 * Tracks all ProtocoliteInfection contracts that have been deployed
 * Used for dynamic contract indexing
 */
export const infectionContract = onchainTable(
  "infectionContract",
  (t) => ({
    id: t.hex().primaryKey(), // Contract address
    parentSpreaderId: t.text().notNull(), // Reference to spreader (indexed, no FK constraint)
    parentTokenId: t.bigint().notNull(),
    parentDna: t.bigint().notNull(),
    deployedAt: t.bigint().notNull(),
    deployedAtBlock: t.bigint().notNull(),
  }),
  (table) => ({
    parentIdx: index().on(table.parentSpreaderId),
  })
);
