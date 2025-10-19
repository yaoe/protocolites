import type { Metadata } from "next";
import "./globals.css";
import { Providers } from "./providers";

export const metadata: Metadata = {
  title: "プロトコライト // ON-CHAIN PROTOCOLITES",
  description: "LIVE BLOCKCHAIN VIEWER — GENERATIVE ASCII ART PROTOCOL",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
