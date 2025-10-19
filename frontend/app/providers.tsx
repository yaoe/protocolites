'use client'

import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { PonderProvider } from '@ponder/react'
import { WagmiProvider } from 'wagmi'
import { config } from '@/lib/wagmi'
import { ponderClient } from '@/lib/indexer'
import { useState } from 'react'

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000, // 1 minute
        refetchOnWindowFocus: false,
      },
    },
  }))

  return (
    <WagmiProvider config={config}>
      <PonderProvider client={ponderClient}>
        <QueryClientProvider client={queryClient}>
          {children}
        </QueryClientProvider>
      </PonderProvider>
    </WagmiProvider>
  )
}
