"use client";

import { SpreaderNFT } from "@/lib/types";
import { InfectionCard } from "./InfectionCard";
import { MASTER_ADDRESS } from "@/lib/contracts";
import { zeroAddress } from "viem";
import { useRouter } from "next/navigation";

interface SpreaderCardProps {
  nft: SpreaderNFT;
  isExpanded: boolean;
  onToggleExpand: () => void;
  onFeed: (tokenId: number) => void;
  onInfect: (infectionAddress: string) => void;
}

export function SpreaderCard({
  nft,
  isExpanded,
  onToggleExpand,
  onFeed,
  onInfect,
}: SpreaderCardProps) {
  const router = useRouter();

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

  const html = nft.metadata.animation_url
    ? decodeDataURI(nft.metadata.animation_url)
    : null;

  const titleText = (
    nft.metadata?.name || `Protocolite #${nft.tokenId}`
  ).replace(/\s*\(spreader\)\s*/i, "");

  const raribleNftUrl = `https://og.rarible.com/token/${MASTER_ADDRESS.toLowerCase()}:${nft.tokenId}`;
  const raribleCollectionUrl =
    nft.infectionAddress !== zeroAddress
      ? `https://og.rarible.com/collection/${nft.infectionAddress.toLowerCase()}/items`
      : null;
  const openseaUserUrl = `https://opensea.io/${nft.owner}`;

  const shortOwner = `${nft.owner.slice(0, 6)}...${nft.owner.slice(-4)}`;

  const handleCardClick = (e: React.MouseEvent) => {
    // Don't navigate if clicking on a button or link
    const target = e.target as HTMLElement;
    if (
      target.tagName === "BUTTON" ||
      target.tagName === "A" ||
      target.closest("button") ||
      target.closest("a")
    ) {
      return;
    }
    // Navigate to detail page
    router.push(`/protocolite?tokenId=${nft.tokenId}`);
  };

  return (
    <div
      className={`spreader-card ${isExpanded ? "expanded" : ""}`}
      onClick={handleCardClick}
    >
      <div className="spreader-header">
        <div className="spreader-preview">
          {html && (
            <iframe
              sandbox="allow-scripts allow-same-origin"
              srcDoc={html}
              title={titleText}
            />
          )}
        </div>

        <div className="spreader-info">
          <div className="spreader-title">{titleText}</div>

          <div>
            <div className="spreader-detail">
              <span className="spreader-detail-label">Token ID:</span>
              <span className="spreader-detail-value">#{nft.tokenId}</span>
            </div>
            <div className="spreader-detail">
              <span className="spreader-detail-label">Type:</span>
              <span className="spreader-detail-value">24×24</span>
            </div>
            <div className="spreader-detail">
              <span className="spreader-detail-label">Infections:</span>
              <span className="spreader-detail-value">
                {nft.infections.length}
              </span>
            </div>
            <div className="spreader-detail">
              <span className="spreader-detail-label">Owner:</span>
              <a
                href={openseaUserUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="owner-link spreader-detail-value"
                title={nft.owner}
              >
                {shortOwner}
              </a>
            </div>
          </div>

          <div
            style={{
              display: "flex",
              flexDirection: "column",
              gap: "8px",
              marginTop: "10px",
              alignSelf: "flex-start",
            }}
          >
            <button
              className="btn btn-small"
              onClick={(e) => {
                e.stopPropagation();
                onFeed(nft.tokenId);
              }}
            >
              ■ Feed to Reproduce
            </button>
            <button
              className="btn btn-small"
              onClick={(e) => {
                e.stopPropagation();
                if (nft.infectionAddress !== zeroAddress) {
                  onInfect(nft.infectionAddress);
                } else {
                  alert(
                    "This spreader has no infection contract yet! They need to be fed first.",
                  );
                }
              }}
            >
              ● Get Infected !
            </button>
          </div>
        </div>
      </div>

      <div className="spreader-footer">
        <div className="dna-display">DNA: {nft.dna}</div>

        <div className="spreader-actions">
          <div className="spreader-actions-left">
            {nft.infections.length > 0 && (
              <button
                className="btn-expand"
                onClick={(e) => {
                  e.stopPropagation();
                  onToggleExpand();
                }}
              >
                {isExpanded ? "▲ HIDE INFECTIONS" : "▼ SHOW INFECTIONS"}
              </button>
            )}
          </div>

          <div className="spreader-actions-right">
            <a
              href={raribleNftUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="rarible-link"
              title="View NFT on Rarible"
            >
              🔗 View NFT
            </a>
            {raribleCollectionUrl && (
              <a
                href={raribleCollectionUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="rarible-link"
                title="View infection collection on Rarible"
              >
                🦠 View Infections
              </a>
            )}
          </div>
        </div>
      </div>

      {nft.infections.length > 0 && (
        <div className="infections-section">
          <div className="infections-title">
            <span>INFECTIONS ({nft.infections.length})</span>
            <button
              className="infections-close"
              onClick={(e) => {
                e.stopPropagation();
                onToggleExpand();
              }}
            >
              ×
            </button>
          </div>

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
  );
}
