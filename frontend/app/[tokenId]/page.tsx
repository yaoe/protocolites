'use client'

import { use } from 'react'
import { useRouter } from 'next/navigation'
import { useSingleProtocolite } from '@/hooks/useSingleProtocolite'
import { InfectionCard } from '@/components/InfectionCard'
import { useAccount, useSendTransaction } from 'wagmi'
import { parseEther } from 'viem'
import { MASTER_ADDRESS } from '@/lib/contracts'
import { zeroAddress } from 'viem'

export default function ProtocoliteDetailPage({
  params,
}: {
  params: Promise<{ tokenId: string }>
}) {
  const { tokenId } = use(params)
  const router = useRouter()

  const { data: nft, isLoading, error, refetch } = useSingleProtocolite(Number(tokenId))
  const { isConnected } = useAccount()
  const { sendTransaction } = useSendTransaction()

  const handleFeed = async () => {
    if (!isConnected) {
      alert('Please connect your wallet first!')
      return
    }

    try {
      sendTransaction(
        {
          to: MASTER_ADDRESS,
          value: parseEther('0.001'),
        },
        {
          onSuccess: () => {
            alert(
              `Transaction sent! Protocolite #${tokenId} will be fed and reproduce once the transaction is confirmed.`
            )
            setTimeout(() => refetch(), 3000)
          },
          onError: (error) => {
            console.error('Transaction failed:', error)
            alert('Transaction failed: ' + error.message)
          },
        }
      )
    } catch (error) {
      console.error('Error sending feed transaction:', error)
      alert('Transaction failed: ' + (error as Error).message)
    }
  }

  const handleInfect = async () => {
    if (!isConnected) {
      alert('Please connect your wallet first!')
      return
    }

    if (!nft || nft.infectionAddress === zeroAddress) {
      alert('This spreader has no infection contract yet! They need to be fed first.')
      return
    }

    try {
      sendTransaction(
        {
          to: nft.infectionAddress,
          value: parseEther('0'),
        },
        {
          onSuccess: () => {
            alert(
              'Transaction sent! You will receive your infection NFT once the transaction is confirmed.'
            )
            setTimeout(() => refetch(), 3000)
          },
          onError: (error) => {
            console.error('Transaction failed:', error)
            alert('Transaction failed: ' + error.message)
          },
        }
      )
    } catch (error) {
      console.error('Error sending infection transaction:', error)
      alert('Transaction failed: ' + (error as Error).message)
    }
  }

  const decodeDataURI = (uri: string): string | null => {
    try {
      if (!uri || !uri.startsWith('data:')) return null
      const base64 = uri.split(',')[1]
      return atob(base64)
    } catch (error) {
      console.error('Error decoding data URI:', error)
      return null
    }
  }

  if (isLoading) {
    return (
      <>
        <div className="detail-header">
          <button className="btn-back" onClick={() => router.push('/')}>
            ← BACK TO GALLERY
          </button>
        </div>
        <div className="content">
          <div className="loading">
            <div className="loading-dots">LOADING FROM BLOCKCHAIN</div>
          </div>
        </div>
      </>
    )
  }

  if (error || !nft) {
    return (
      <>
        <div className="detail-header">
          <button className="btn-back" onClick={() => router.push('/')}>
            ← BACK TO GALLERY
          </button>
        </div>
        <div className="content">
          <div className="error">
            {error ? `Failed to load: ${(error as Error).message}` : 'Protocolite not found'}
          </div>
        </div>
      </>
    )
  }

  const titleText = (nft.metadata?.name || `Protocolite #${nft.tokenId}`).replace(
    /\s*\(spreader\)\s*/i,
    ''
  )
  const html = nft.metadata.animation_url ? decodeDataURI(nft.metadata.animation_url) : null
  const shortOwner = `${nft.owner.slice(0, 6)}...${nft.owner.slice(-4)}`
  const raribleNftUrl = `https://testnet.rarible.com/token/${MASTER_ADDRESS.toLowerCase()}:${nft.tokenId}`
  const raribleCollectionUrl =
    nft.infectionAddress !== zeroAddress
      ? `https://testnet.rarible.com/collection/${nft.infectionAddress.toLowerCase()}/items`
      : null
  const openseaUserUrl = `https://testnets.opensea.io/${nft.owner}`

  return (
    <>
      <div className="detail-header">
        <button className="btn-back" onClick={() => router.push('/')}>
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
                  <span className="detail-info-value">{nft.infections.length}</span>
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
            <h3 className="detail-section-title">INFECTIONS ({nft.infections.length})</h3>
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
  )
}
