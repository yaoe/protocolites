"use client";

import { useEffect, useState, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { InfectionCard } from "@/components/InfectionCard";
import {
  useAccount,
  useSendTransaction,
  useWaitForTransactionReceipt,
} from "wagmi";
import { parseEther, zeroAddress } from "viem";
import { eq } from "@ponder/client";
import { usePonderQuery } from "@ponder/react";
import { MASTER_ADDRESS } from "@/lib/contracts";
import { spreader, infection } from "@/lib/ponder.schema";
import toast from "react-hot-toast";

function ProtocoliteDetailPageContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [tokenId, setTokenId] = useState<string | null>(null);
  const { isConnected } = useAccount();
  const { sendTransaction, data: hash } = useSendTransaction();
  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({
      hash,
    });

  // Get tokenId from URL search params
  useEffect(() => {
    const tokenIdParam = searchParams.get("tokenId");
    if (tokenIdParam) {
      setTokenId(tokenIdParam);
    }
  }, [searchParams]);

  // Query the specific spreader
  const {
    data: spreaderData = [],
    isLoading: isLoadingSpreader,
    refetch: refetchSpreader,
  } = usePonderQuery({
    queryFn: (db) =>
      db
        .select()
        .from(spreader)
        .where(eq(spreader.tokenId, BigInt(tokenId || "0"))),
    enabled: !!tokenId,
  });

  // Query infections for this spreader
  const {
    data: infections = [],
    isLoading: isLoadingInfections,
    refetch: refetchInfections,
  } = usePonderQuery({
    queryFn: (db) =>
      db
        .select()
        .from(infection)
        .where(eq(infection.parentTokenId, BigInt(tokenId || "0"))),
    enabled: !!spreaderData[0] && !!tokenId,
  });

  const isLoading = isLoadingSpreader || isLoadingInfections;
  const error = null;
  const isFromIndexer = true;

  // Transform data to match UI types
  const nft = spreaderData[0]
    ? {
        tokenId: Number(spreaderData[0].tokenId),
        metadata: {
          name:
            spreaderData[0].name || `Protocolite #${spreaderData[0].tokenId}`,
          description: spreaderData[0].description || "",
          image: spreaderData[0].image || "",
          animation_url: spreaderData[0].animationUrl || "",
        },
        dna: spreaderData[0].dna.toString(),
        owner: spreaderData[0].owner,
        infectionAddress: spreaderData[0].infectionContractAddress,
        infections: infections.map((inf) => ({
          tokenId: Number(inf.tokenId),
          metadata: {
            name: inf.name || `Infection #${inf.tokenId}`,
            description: inf.description || "",
            image: inf.image || "",
            animation_url: inf.animationUrl || "",
          },
          owner: inf.owner,
        })),
      }
    : null;

  const refetch = () => {
    refetchSpreader();
    refetchInfections();
  };

  useEffect(() => {
    if (isConfirmed) {
      toast.success("Transaction confirmed! ✓", { duration: 5000 });
      setTimeout(() => refetch(), 2000);
    }
  }, [isConfirmed, refetchSpreader, refetchInfections]);

  const handleFeed = async () => {
    if (!isConnected) {
      toast.error("Please connect your wallet first!");
      return;
    }

    try {
      sendTransaction(
        {
          to: MASTER_ADDRESS,
          value: parseEther("0.001"),
        },
        {
          onSuccess: () => {
            toast.success(
              `Transaction sent! Protocolite #${tokenId} will be fed and reproduce once confirmed.`,
            );
            setTimeout(() => refetch(), 3000);
          },
          onError: (error) => {
            console.error("Transaction failed:", error);
            toast.error("Transaction failed: " + error.message);
          },
        },
      );
    } catch (error) {
      console.error("Error sending feed transaction:", error);
      toast.error("Transaction failed: " + (error as Error).message);
    }
  };

  const handleInfect = async () => {
    if (!isConnected) {
      toast.error("Please connect your wallet first!");
      return;
    }

    if (!nft || nft.infectionAddress === zeroAddress) {
      toast.error(
        "This spreader has no infection contract yet! They need to be fed first.",
      );
      return;
    }

    try {
      sendTransaction(
        {
          to: nft.infectionAddress,
          value: parseEther("0"),
        },
        {
          onSuccess: () => {
            toast.success(
              "Transaction sent! You will receive your infection NFT once confirmed.",
            );
            setTimeout(() => refetch(), 3000);
          },
          onError: (error) => {
            console.error("Transaction failed:", error);
            toast.error("Transaction failed: " + error.message);
          },
        },
      );
    } catch (error) {
      console.error("Error sending infection transaction:", error);
      toast.error("Transaction failed: " + (error as Error).message);
    }
  };

  const decodeDataURI = (uri: string): string | null => {
    try {
      if (!uri || !uri.startsWith("data:")) return null;
      const base64 = uri.split(",")[1];
      return atob(base64);
    } catch (error) {
      console.error("Error decoding data URI:", error);
      return null;
    }
  };

  // Show error if no tokenId provided
  if (!tokenId) {
    return (
      <>
        <div className="detail-header">
          <button className="btn-back" onClick={() => router.push("/")}>
            ← BACK TO GALLERY
          </button>
        </div>
        <div className="content">
          <div className="error">
            No token ID provided. Please navigate from the gallery or provide a
            tokenId parameter.
          </div>
        </div>
      </>
    );
  }

  if (isLoading) {
    return (
      <>
        <div className="detail-header">
          <button className="btn-back" onClick={() => router.push("/")}>
            ← BACK TO GALLERY
          </button>
        </div>
        <div className="content">
          <div className="loading">
            <div className="loading-dots">
              {isFromIndexer
                ? "LOADING FROM INDEXER"
                : "LOADING FROM BLOCKCHAIN"}
            </div>
          </div>
        </div>
      </>
    );
  }

  if (error || !nft) {
    return (
      <>
        <div className="detail-header">
          <button className="btn-back" onClick={() => router.push("/")}>
            ← BACK TO GALLERY
          </button>
        </div>
        <div className="content">
          <div className="error">
            {error
              ? `Failed to load: ${(error as Error).message}`
              : "Protocolite not found"}
          </div>
        </div>
      </>
    );
  }

  const titleText = (
    nft.metadata?.name || `Protocolite #${nft.tokenId}`
  ).replace(/\s*\(spreader\)\s*/i, "");
  const html = nft.metadata.animation_url
    ? decodeDataURI(nft.metadata.animation_url)
    : null;
  const shortOwner = `${nft.owner.slice(0, 6)}...${nft.owner.slice(-4)}`;
  const raribleNftUrl = `https://testnet.rarible.com/token/${MASTER_ADDRESS.toLowerCase()}:${nft.tokenId}`;
  const raribleCollectionUrl =
    nft.infectionAddress !== zeroAddress
      ? `https://testnet.rarible.com/collection/${nft.infectionAddress.toLowerCase()}/items`
      : null;
  const openseaUserUrl = `https://testnets.opensea.io/${nft.owner}`;

  return (
    <>
      <div className="detail-header">
        <button className="btn-back" onClick={() => router.push("/")}>
          ← BACK TO GALLERY
        </button>
        <h2 className="detail-title">{titleText}</h2>
      </div>

      <div className="detail-content">
        <div className="detail-main">
          <div className="detail-preview-large">
            {html && (
              <iframe
                sandbox="allow-scripts allow-same-origin"
                srcDoc={html}
                title={titleText}
              />
            )}
          </div>

          <div className="detail-info-card">
            <div className="detail-info-section">
              <h3 className="detail-section-title">METADATA</h3>
              <div className="detail-info-grid">
                <div className="detail-info-item">
                  <span className="detail-info-label">Token ID:</span>
                  <span className="detail-info-value">#{nft.tokenId}</span>
                </div>
                <div className="detail-info-item">
                  <span className="detail-info-label">Type:</span>
                  <span className="detail-info-value">24×24 Spreader</span>
                </div>
                <div className="detail-info-item">
                  <span className="detail-info-label">Infections:</span>
                  <span className="detail-info-value">
                    {nft.infections.length}
                  </span>
                </div>
                <div className="detail-info-item">
                  <span className="detail-info-label">Owner:</span>
                  <a
                    href={openseaUserUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="owner-link detail-info-value"
                    title={nft.owner}
                  >
                    {shortOwner}
                  </a>
                </div>
              </div>
            </div>

            <div className="detail-info-section">
              <h3 className="detail-section-title">DNA</h3>
              <div className="dna-display">{nft.dna}</div>
            </div>

            <div className="detail-info-section">
              <h3 className="detail-section-title">ACTIONS</h3>
              <div className="detail-actions">
                <button className="btn btn-small" onClick={handleFeed}>
                  ■ Feed to Reproduce
                </button>
                <button className="btn btn-small" onClick={handleInfect}>
                  ● Get Infected !
                </button>
              </div>
            </div>

            <div className="detail-info-section">
              <h3 className="detail-section-title">LINKS</h3>
              <div className="detail-links">
                <a
                  href={raribleNftUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="rarible-link"
                >
                  🔗 View on Rarible
                </a>
                {raribleCollectionUrl && (
                  <a
                    href={raribleCollectionUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="rarible-link"
                  >
                    🦠 View Infection Collection
                  </a>
                )}
              </div>
            </div>
          </div>
        </div>

        {nft.infections.length > 0 && (
          <div className="detail-infections">
            <h3 className="detail-section-title">
              INFECTIONS ({nft.infections.length})
            </h3>
            <div className="infections-grid">
              {nft.infections.map((infection) => (
                <InfectionCard
                  key={infection.tokenId}
                  infection={infection}
                  onClick={() => {}}
                />
              ))}
            </div>
          </div>
        )}
      </div>
    </>
  );
}

function LoadingFallback() {
  return (
    <>
      <div className="detail-header">
        <button className="btn-back" disabled>
          ← BACK TO GALLERY
        </button>
      </div>
      <div className="content">
        <div className="loading">
          <div className="loading-dots">LOADING...</div>
        </div>
      </div>
    </>
  );
}

export default function ProtocoliteDetailPage() {
  return (
    <Suspense fallback={<LoadingFallback />}>
      <ProtocoliteDetailPageContent />
    </Suspense>
  );
}
