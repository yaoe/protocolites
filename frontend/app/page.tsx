'use client'

import { useMemo, useState } from 'react'
import { Header } from '@/components/Header'
import { ControlsBar, FilterType, SortType } from '@/components/ControlsBar'
import { SpreaderCard } from '@/components/SpreaderCard'
import { Modal } from '@/components/Modal'
import { useProtocolites } from '@/hooks/useProtocolites'
import { useAccount, useSendTransaction, useWaitForTransactionReceipt } from 'wagmi'
import { parseEther } from 'viem'
import { MASTER_ADDRESS } from '@/lib/contracts'

export default function Home() {
  const [filter, setFilter] = useState<FilterType>('all')
  const [sort, setSort] = useState<SortType>('infections-desc')
  const [expandedSpreader, setExpandedSpreader] = useState<number | null>(null)
  const [modalAnimationUrl, setModalAnimationUrl] = useState<string | null>(null)
  const [isModalOpen, setIsModalOpen] = useState(false)

  const { data: nfts, isLoading, error, refetch } = useProtocolites()
  const { isConnected } = useAccount()
  const { sendTransaction, data: txHash } = useSendTransaction()
  const { isLoading: isTxPending } = useWaitForTransactionReceipt({
    hash: txHash,
  })

  const totalInfections = useMemo(() => {
    return nfts?.reduce((sum, nft) => sum + nft.infections.length, 0) || 0
  }, [nfts])

  const sortedAndFiltered = useMemo(() => {
    if (!nfts) return []

    let filtered = [...nfts]

    // Apply filter
    if (filter === 'with-infections') {
      filtered = filtered.filter((nft) => nft.infections.length > 0)
    }

    // Apply sort
    filtered.sort((a, b) => {
      switch (sort) {
        case 'id-asc':
          return a.tokenId - b.tokenId
        case 'id-desc':
          return b.tokenId - a.tokenId
        case 'infections-desc':
          return b.infections.length - a.infections.length
        case 'infections-asc':
          return a.infections.length - b.infections.length
        default:
          return 0
      }
    })

    return filtered
  }, [nfts, filter, sort])

  const handleFeed = async (tokenId: number) => {
    if (!isConnected) {
      alert('Please connect your wallet first!')
      return
    }

    try {
      sendTransaction(
        {
          to: MASTER_ADDRESS,
          value: parseEther('0.001'), // Sepolia testnet amount
        },
        {
          onSuccess: () => {
            alert(
              `Transaction sent! Protocolite #${tokenId} will be fed and reproduce once the transaction is confirmed.`
            )
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

  const handleInfect = async (infectionAddress: string) => {
    if (!isConnected) {
      alert('Please connect your wallet first!')
      return
    }

    try {
      sendTransaction(
        {
          to: infectionAddress as `0x${string}`,
          value: parseEther('0'),
        },
        {
          onSuccess: () => {
            alert(
              'Transaction sent! You will receive your infection NFT once the transaction is confirmed.'
            )
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

  const openModal = (animationUrl: string) => {
    setModalAnimationUrl(animationUrl)
    setIsModalOpen(true)
  }

  const closeModal = () => {
    setIsModalOpen(false)
    setModalAnimationUrl(null)
  }

  return (
    <>
      <Header />
      <ControlsBar
        filter={filter}
        sort={sort}
        totalSupply={nfts?.length || 0}
        totalInfections={totalInfections}
        onFilterChange={setFilter}
        onSortChange={setSort}
        onRefresh={() => refetch()}
      />

      <div className="content">
        {isLoading && (
          <div className="loading">
            <div className="loading-dots">LOADING FROM BLOCKCHAIN</div>
          </div>
        )}

        {error && (
          <div className="error">
            Failed to load NFTs: {(error as Error).message}
          </div>
        )}

        {!isLoading && nfts && nfts.length === 0 && (
          <div className="error">No Protocolites found on chain yet.</div>
        )}

        {!isLoading && sortedAndFiltered.length > 0 && (
          <div className="spreaders-grid">
            {sortedAndFiltered.map((nft) => (
              <SpreaderCard
                key={nft.tokenId}
                nft={nft}
                isExpanded={expandedSpreader === nft.tokenId}
                onToggleExpand={() =>
                  setExpandedSpreader(
                    expandedSpreader === nft.tokenId ? null : nft.tokenId
                  )
                }
                onOpenModal={openModal}
                onFeed={handleFeed}
                onInfect={handleInfect}
              />
            ))}
          </div>
        )}
      </div>

      <Modal
        isOpen={isModalOpen}
        animationUrl={modalAnimationUrl}
        onClose={closeModal}
      />
    </>
  )
}
