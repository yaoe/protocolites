'use client'

import { useState, useEffect } from 'react'
import { Header } from '@/components/Header'
import { ControlsBar, FilterType, SortType } from '@/components/ControlsBar'
import { SpreaderCard } from '@/components/SpreaderCard'
import { useAccount, useSendTransaction, useWaitForTransactionReceipt } from 'wagmi'
import { parseEther } from 'viem'
import { count, desc, asc, gt } from '@ponder/client'
import { usePonderQuery } from '@ponder/react'
import { MASTER_ADDRESS } from '@/lib/contracts'
import { spreader, infection } from '@/lib/ponder.schema'
import toast from 'react-hot-toast'

export default function Home() {
  const [filter, setFilter] = useState<FilterType>('all')
  const [sort, setSort] = useState<SortType>('infections-desc')
  const [expandedSpreader, setExpandedSpreader] = useState<number | null>(null)

  const { isConnected } = useAccount()
  const { sendTransaction, data: hash } = useSendTransaction()
  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  })

  useEffect(() => {
    if (isConfirmed) {
      toast.success('Transaction confirmed! ✓', { duration: 5000 })
    }
  }, [isConfirmed])

  // Query total spreaders count
  const {
    data: [{ count: totalSupply }] = [{ count: 0 }],
    isLoading: isLoadingTotal,
  } = usePonderQuery({
    queryFn: (db) =>
      db.select({ count: count(spreader.id) }).from(spreader),
  })

  // Query total infections count
  const {
    data: [{ count: totalInfections }] = [{ count: 0 }],
    isLoading: isLoadingInfections,
  } = usePonderQuery({
    queryFn: (db) =>
      db.select({ count: count(infection.id) }).from(infection),
  })

  // Query spreaders with filtering and sorting
  const { data: spreaders = [], isLoading: isLoadingSpreaders } = usePonderQuery({
    queryFn: (db) => {
      let query = db.select().from(spreader)

      // Apply filter
      if (filter === 'with-infections') {
        query = query.where(gt(spreader.infectionCount, 0))
      }

      // Apply sort
      if (sort === 'id-asc') {
        query = query.orderBy(asc(spreader.tokenId))
      } else if (sort === 'id-desc') {
        query = query.orderBy(desc(spreader.tokenId))
      } else if (sort === 'infections-desc') {
        query = query.orderBy(desc(spreader.infectionCount))
      } else if (sort === 'infections-asc') {
        query = query.orderBy(asc(spreader.infectionCount))
      }

      return query
    },
  })

  // Query all infections
  const { data: infections = [], isLoading: isLoadingInfectionsData } = usePonderQuery({
    queryFn: (db) => db.select().from(infection),
  })

  // Transform Ponder data to match our UI types
  const nfts = spreaders.map((s) => {
    const spreaderInfections = infections.filter(
      (inf) => inf.parentSpreaderId === s.id
    )

    return {
      tokenId: Number(s.tokenId),
      metadata: {
        name: s.name || `Protocolite #${s.tokenId}`,
        description: s.description || '',
        image: s.image || '',
        animation_url: s.animationUrl || '',
      },
      dna: s.dna.toString(),
      owner: s.owner,
      infectionAddress: s.infectionContractAddress,
      infections: spreaderInfections.map((inf) => ({
        tokenId: Number(inf.tokenId),
        metadata: {
          name: inf.name || `Infection #${inf.tokenId}`,
          description: inf.description || '',
          image: inf.image || '',
          animation_url: inf.animationUrl || '',
        },
        owner: inf.owner,
      })),
    }
  })

  const isLoading = isLoadingTotal || isLoadingInfections || isLoadingSpreaders || isLoadingInfectionsData
  const error = null
  const isFromIndexer = true

  const sortedAndFiltered = nfts

  const handleFeed = async (tokenId: number) => {
    if (!isConnected) {
      toast.error('Please connect your wallet first!')
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
            toast.success(
              `Transaction sent! Protocolite #${tokenId} will be fed and reproduce once confirmed.`
            )
          },
          onError: (error) => {
            console.error('Transaction failed:', error)
            toast.error('Transaction failed: ' + error.message)
          },
        }
      )
    } catch (error) {
      console.error('Error sending feed transaction:', error)
      toast.error('Transaction failed: ' + (error as Error).message)
    }
  }

  const handleInfect = async (infectionAddress: string) => {
    if (!isConnected) {
      toast.error('Please connect your wallet first!')
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
            toast.success(
              'Transaction sent! You will receive your infection NFT once confirmed.'
            )
          },
          onError: (error) => {
            console.error('Transaction failed:', error)
            toast.error('Transaction failed: ' + error.message)
          },
        }
      )
    } catch (error) {
      console.error('Error sending infection transaction:', error)
      toast.error('Transaction failed: ' + (error as Error).message)
    }
  }

  return (
    <>
      <Header />
      <ControlsBar
        filter={filter}
        sort={sort}
        totalSupply={totalSupply}
        totalInfections={totalInfections}
        onFilterChange={setFilter}
        onSortChange={setSort}
      />

      <div className="content">
        {isLoading && (
          <div className="loading">
            <div className="loading-dots">
              {isFromIndexer ? 'LOADING FROM INDEXER' : 'LOADING FROM BLOCKCHAIN'}
            </div>
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
                onFeed={handleFeed}
                onInfect={handleInfect}
              />
            ))}
          </div>
        )}
      </div>
    </>
  )
}
