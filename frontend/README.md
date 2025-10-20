# Protocolites Frontend

This is a [Next.js](https://nextjs.org) project for the Protocolites NFT protocol, configured for **static export** to support deployment in environments without server-side rendering (SSR) support.

## Static Export Configuration

The app is configured to generate a completely static build using Next.js's static export feature:

- **Static Routes**: All pages are pre-rendered at build time
- **Client-Side Routing**: Navigation happens entirely on the client
- **Search Params**: Dynamic content uses URL search parameters instead of dynamic routes

### Key Changes for Static Export

1. **Dynamic Routes Converted**: The `[tokenId]` dynamic route has been converted to `/protocolite` with search parameters
2. **Suspense Boundaries**: Components using `useSearchParams` are wrapped in Suspense boundaries
3. **Static Configuration**: `next.config.ts` includes `output: "export"` and other static-friendly settings

## Routing

### Gallery Page
- **Route**: `/`
- **Description**: Main gallery showing all Protocolite NFTs

### Protocolite Detail Page
- **Route**: `/protocolite?tokenId={id}`
- **Example**: `/protocolite?tokenId=1`
- **Description**: Detail page for a specific Protocolite NFT

Navigation between pages uses search parameters instead of dynamic routes to maintain static export compatibility.

## Getting Started

### Development

```bash
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

### Building for Production

```bash
# Build the static export
pnpm build

# The static files will be in the `out` directory
# You can serve them with any static file server
```

### Serving the Static Build

After building, you can serve the static files:

```bash
# Using a simple HTTP server
npx serve out

# Or copy the `out` directory to any static hosting service
```

## Deployment

Since this is a static export, you can deploy the contents of the `out` directory to any static hosting service:

- **Vercel**: Upload the `out` directory
- **Netlify**: Drag and drop the `out` directory
- **GitHub Pages**: Push the `out` directory contents
- **AWS S3**: Upload to an S3 bucket configured for static website hosting
- **Any CDN or static hosting service**

## Project Structure

```
app/
├── page.tsx              # Main gallery page
├── protocolite/
│   └── page.tsx          # Detail page (uses search params)
├── layout.tsx            # Root layout
├── globals.css           # Global styles
└── providers.tsx         # App providers (Wagmi, etc.)

components/
├── Header.tsx            # App header
├── ControlsBar.tsx       # Filtering and sorting controls
├── SpreaderCard.tsx      # NFT card component
└── InfectionCard.tsx     # Infection NFT card

lib/
├── contracts.ts          # Contract addresses and ABIs
├── types.ts              # TypeScript type definitions
└── ponder.schema.ts      # Ponder indexer schema
```

## Features

- **Fully Static**: No server-side rendering required
- **Web3 Integration**: Wagmi for wallet connection and transactions
- **Real-time Data**: Ponder indexer for fast NFT data queries
- **Responsive Design**: Works on desktop and mobile
- **Transaction Handling**: Feed and infect Protocolite NFTs
- **NFT Gallery**: Browse and filter Protocolites and their infections

## Configuration

The static export is configured in `next.config.ts`:

```typescript
const nextConfig: NextConfig = {
  output: "export",           // Enable static export
  trailingSlash: true,        // Add trailing slashes for static hosting
  images: {
    unoptimized: true,        // Disable image optimization for static export
  },
  // ... webpack configuration for Web3 libraries
}
```

## Learn More

To learn more about Next.js static exports and the technologies used:

- [Next.js Static Exports](https://nextjs.org/docs/app/building-your-application/deploying/static-exports)
- [Wagmi Documentation](https://wagmi.sh/)
- [Ponder Documentation](https://ponder.sh/)
- [Protocolites Protocol](../README.md)