'use client'

import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { PonderProvider } from '@ponder/react'
import { WagmiProvider } from 'wagmi'
import { config } from '@/lib/wagmi'
import { ponderClient } from '@/lib/indexer'
import { useState } from 'react'
import { Toaster } from 'react-hot-toast'

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
          <Toaster
            position="top-right"
            toastOptions={{
              duration: 4000,
              style: {
                background: '#000000',
                color: '#ffffff',
                border: '1px solid #000000',
                fontFamily: '"JetBrains Mono", "Courier New", monospace',
                fontSize: '11px',
                fontWeight: '300',
                letterSpacing: '0.05em',
                textTransform: 'uppercase',
                padding: '16px 20px',
              },
              success: {
                iconTheme: {
                  primary: '#ffffff',
                  secondary: '#000000',
                },
              },
              error: {
                style: {
                  background: '#cc0000',
                  color: '#ffffff',
                  border: '1px solid #cc0000',
                },
                iconTheme: {
                  primary: '#ffffff',
                  secondary: '#cc0000',
                },
              },
            }}
          />
        </QueryClientProvider>
      </PonderProvider>
    </WagmiProvider>
  )
}
