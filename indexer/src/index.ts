import { ponder } from "ponder:registry";
import type { Context } from "ponder:registry";
import { spreader, infection, infectionContract } from "ponder:schema";
import { decodeDNA } from "./utils/dna";
import { decodeTokenURI } from "./utils/metadata";

/**
 * ProtocolitesMaster: ParentSpawned event
 * Triggered when a new spreader NFT is minted
 */
ponder.on("ProtocolitesMaster:ParentSpawned", async ({ event, context }) => {
  const {
    tokenId,
    owner,
    infectionContract: infectionContractAddress,
  } = event.args;
  const { client, db } = context;

  // Fetch parent data from contract
  const parentData = await client.readContract({
    abi: context.contracts.ProtocolitesMaster.abi,
    address: context.contracts.ProtocolitesMaster.address,
    functionName: "parentData",
    args: [tokenId],
  });

  const [dna, birthBlock, _infectionContract] = parentData as [
    bigint,
    bigint,
    `0x${string}`,
  ];

  // Decode DNA traits
  const traits = decodeDNA(dna);

  // Fetch metadata
  const tokenURI = (await client.readContract({
    abi: context.contracts.ProtocolitesMaster.abi,
    address: context.contracts.ProtocolitesMaster.address,
    functionName: "tokenURI",
    args: [tokenId],
  })) as string;

  const metadata = decodeTokenURI(tokenURI);
  console.log("Spreader metadata:", JSON.stringify(metadata, null, 2));

  // Create spreader ID (use hardcoded chain ID for mainnet)
  const chainId = 1;
  const spreaderId = `${chainId}:${context.contracts.ProtocolitesMaster.address}:${tokenId}`;

  // Insert spreader
  await db.insert(spreader).values({
    id: spreaderId,
    tokenId,
    owner,
    dna,
    birthBlock,
    infectionContractAddress,
    bodyType: traits.bodyType,
    bodyChar: traits.bodyChar,
    eyeChar: traits.eyeChar,
    eyeSize: traits.eyeSize,
    antennaTip: traits.antennaTip,
    armStyle: traits.armStyle,
    legStyle: traits.legStyle,
    hatType: traits.hatType,
    hasCigarette: traits.hasCigarette,
    name: metadata?.name || null,
    description: metadata?.description || null,
    image: metadata?.image || null,
    animationUrl: metadata?.animation_url || null,
    infectionCount: 0,
    createdAt: event.block.timestamp,
    updatedAt: event.block.timestamp,
  });

  // Create infection contract record for dynamic indexing
  await db.insert(infectionContract).values({
    id: infectionContractAddress,
    parentSpreaderId: spreaderId,
    parentTokenId: tokenId,
    parentDna: dna,
    deployedAt: event.block.timestamp,
    deployedAtBlock: event.block.number,
  });
});

/**
 * ProtocolitesMaster: Transfer event
 * Handle ownership changes for spreaders
 */
ponder.on("ProtocolitesMaster:Transfer", async ({ event, context }) => {
  const { from, to, tokenId } = event.args;
  const { db } = context;

  // Skip mint events (handled by ParentSpawned)
  if (from === "0x0000000000000000000000000000000000000000") {
    return;
  }

  const chainId = 11155111;
  const spreaderId = `${chainId}:${context.contracts.ProtocolitesMaster.address}:${tokenId}`;

  // Update owner
  await db.update(spreader, { id: spreaderId }).set({
    owner: to,
    updatedAt: event.block.timestamp,
  });
});

/**
 * ProtocoliteInfection: Infection event
 * Triggered when someone gets infected (receives a child NFT)
 */
ponder.on("ProtocoliteInfection:Infection", async ({ event, context }) => {
  const { kidId, victim, infector } = event.args;
  const { client, db, contracts } = context;

  // Get the infection contract address from the event
  const infectionContractAddress = event.log.address;

  // Find the parent spreader for this infection contract
  const infectionContractRecord = await db.find(infectionContract, {
    id: infectionContractAddress,
  });

  if (!infectionContractRecord) {
    console.error(
      `Infection contract ${infectionContractAddress} not found in database`,
    );
    return;
  }

  // Fetch kid data from contract
  const kidData = await client.readContract({
    abi: contracts.ProtocoliteInfection.abi,
    address: infectionContractAddress,
    functionName: "kidData",
    args: [kidId],
  });

  const [dna, birthBlock, infectedBy] = kidData as [
    bigint,
    bigint,
    `0x${string}`,
  ];

  // Decode DNA traits
  const traits = decodeDNA(dna);

  // Fetch metadata
  const tokenURI = (await client.readContract({
    abi: contracts.ProtocoliteInfection.abi,
    address: infectionContractAddress,
    functionName: "tokenURI",
    args: [kidId],
  })) as string;

  const metadata = decodeTokenURI(tokenURI);

  // Create infection ID
  const chainId = 11155111;
  const infectionId = `${chainId}:${infectionContractAddress}:${kidId}`;

  // Insert infection
  await db.insert(infection).values({
    id: infectionId,
    tokenId: kidId,
    parentSpreaderId: infectionContractRecord.parentSpreaderId,
    parentTokenId: infectionContractRecord.parentTokenId,
    infectionContractAddress,
    owner: victim,
    dna,
    infectedBy,
    birthBlock,
    bodyType: traits.bodyType,
    bodyChar: traits.bodyChar,
    eyeChar: traits.eyeChar,
    eyeSize: traits.eyeSize,
    antennaTip: traits.antennaTip,
    armStyle: traits.armStyle,
    legStyle: traits.legStyle,
    hatType: traits.hatType,
    hasCigarette: traits.hasCigarette,
    name: metadata?.name || null,
    description: metadata?.description || null,
    image: metadata?.image || null,
    animationUrl: metadata?.animation_url || null,
    createdAt: event.block.timestamp,
  });

  // Increment infection count on parent spreader
  await db
    .update(spreader, { id: infectionContractRecord.parentSpreaderId })
    .set((row) => ({
      infectionCount: row.infectionCount + 1,
      updatedAt: event.block.timestamp,
    }));
});

/**
 * ProtocoliteInfection: Transfer event
 * Handle ownership changes for infections
 * Note: Infections are soulbound, but we track transfers anyway for completeness
 */
ponder.on("ProtocoliteInfection:Transfer", async ({ event, context }) => {
  const { from, to, tokenId } = event.args;
  const { db } = context;

  // Skip mint events (handled by Infection event)
  if (from === "0x0000000000000000000000000000000000000000") {
    return;
  }

  const chainId = 11155111;
  const infectionContractAddress = event.log.address;
  const infectionId = `${chainId}:${infectionContractAddress}:${tokenId}`;

  // Update owner (should rarely happen since infections are soulbound)
  const infectionRecord = await db.find(infection, {
    id: infectionId,
  });

  if (infectionRecord) {
    await db.update(infection, { id: infectionId }).set({
      owner: to,
    });
  }
});
