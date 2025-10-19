'use client'

import { useAccount, useConnect, useDisconnect } from 'wagmi'
import { MASTER_ADDRESS } from '@/lib/contracts'
import { useEffect, useState } from 'react'

export function Header() {
  const { address, isConnected } = useAccount()
  const { connect, connectors } = useConnect()
  const { disconnect } = useDisconnect()
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  const handleWalletClick = () => {
    if (isConnected) {
      disconnect()
    } else {
      const connector = connectors[0]
      if (connector) {
        connect({ connector })
      }
    }
  }

  const shortAddress = address
    ? `${address.slice(0, 6)}...${address.slice(-4)}`
    : ''

  return (
    <div className="header">
      <h1>プロトコライト // ON-CHAIN PROTOCOLITES</h1>
      <div className="subtitle">
        LIVE BLOCKCHAIN VIEWER — GENERATIVE ASCII ART PROTOCOL
        <span className="network-badge">SEPOLIA TESTNET</span>
        <button
          className={`wallet-button ${mounted && isConnected ? 'connected' : ''}`}
          onClick={handleWalletClick}
        >
          {mounted && isConnected ? `■ ${shortAddress}` : '● CONNECT WALLET'}
        </button>
      </div>
      <div className="contract-address">Master: {MASTER_ADDRESS}</div>
    </div>
  )
}
