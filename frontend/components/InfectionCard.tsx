'use client'

import { InfectionNFT } from '@/lib/types'

interface InfectionCardProps {
  infection: InfectionNFT
  onClick: () => void
}

export function InfectionCard({ infection, onClick }: InfectionCardProps) {
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

  const html = infection.metadata.animation_url
    ? decodeDataURI(infection.metadata.animation_url)
    : null

  return (
    <div className="infection-card" onClick={onClick}>
      <div className="infection-preview">
        {html && (
          <iframe
            sandbox="allow-scripts allow-same-origin"
            srcDoc={html}
            title={`Infection #${infection.tokenId}`}
          />
        )}
      </div>
      <div className="infection-label">
        <div style={{ marginBottom: '4px' }}>INFECTION #{infection.tokenId}</div>
        <div
          style={{
            fontSize: '7px',
            color: '#999',
            wordBreak: 'break-all',
            lineHeight: '1.3',
          }}
        >
          {infection.owner}
        </div>
      </div>
    </div>
  )
}
