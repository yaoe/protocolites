# Protocolites website refactor

We have a static html website, and want to turn that into a Next.js application.

Importantly, the aesthitics and CSS should match what's in the website prototype.

However there are areas for improvement:
- Setup wagmi and viem for wallet connection and blockchain interaction
- Utilize react query for data fetching and caching (https://wagmi.sh/react/guides/tanstack-query)
- Break things into smaller UI components where it makes sense
