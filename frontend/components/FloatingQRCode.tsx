"use client";

import { useState } from "react";

interface FloatingQRCodeProps {
  title?: string;
  description?: string;
  url?: string;
}

export function FloatingQRCode({
  title = "SCAN TO ACCESS",
  description = "PROTOCOLITES APP",
  url = "https://protocolites.xyz",
}: FloatingQRCodeProps) {
  const [isExpanded, setIsExpanded] = useState(false);

  return (
    <div className={`floating-qr ${isExpanded ? "expanded" : ""}`}>
      <div
        className="floating-qr-toggle"
        onClick={() => setIsExpanded(!isExpanded)}
      >
        <div className="floating-qr-icon">
          <img src="/qr_code.jpg" alt="QR Code" className="floating-qr-image" />
        </div>
        <div className="floating-qr-text">QR</div>
      </div>

      {isExpanded && (
        <div className="floating-qr-content">
          <button
            className="floating-qr-close"
            onClick={() => setIsExpanded(false)}
          >
            ×
          </button>
          <div className="floating-qr-header">
            <div className="floating-qr-title">{title}</div>
            <div className="floating-qr-description">{description}</div>
          </div>

          <div className="floating-qr-display">
            <img
              src="/qr_code.jpg"
              alt="Protocolite QR Code"
              className="floating-qr-large-image"
            />
          </div>

          {url && (
            <div className="floating-qr-url">
              <a
                href={url}
                target="_blank"
                rel="noopener noreferrer"
                className="floating-qr-url-link"
              >
                {url.replace("https://", "")}
              </a>
            </div>
          )}
        </div>
      )}

      <style jsx>{`
        .floating-qr {
          position: fixed;
          bottom: 30px;
          right: 30px;
          z-index: 1000;
          font-family: "JetBrains Mono", "Courier New", monospace;
        }

        .floating-qr-toggle {
          display: flex;
          align-items: center;
          justify-content: center;
          width: 60px;
          height: 60px;
          background: #000000;
          border: 2px solid #000000;
          cursor: pointer;
          transition: all 0.3s ease;
          position: relative;
          overflow: hidden;
        }

        .floating-qr.expanded .floating-qr-toggle {
          display: none;
        }

        .floating-qr-toggle:hover {
          transform: scale(1.05);
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

        .floating-qr-icon {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          opacity: 0.3;
          transition: opacity 0.3s ease;
        }

        .floating-qr-image {
          width: 100%;
          height: 100%;
          object-fit: cover;
          filter: invert(1);
        }

        .floating-qr-text {
          color: #ffffff;
          font-size: 12px;
          font-weight: 300;
          letter-spacing: 0.1em;
          text-transform: uppercase;
          position: relative;
          z-index: 2;
        }

        .floating-qr-content {
          position: absolute;
          bottom: 0;
          right: 0;
          width: 280px;
          background: #fafafa;
          border: 2px solid #000000;
          padding: 20px;
          display: flex;
          flex-direction: column;
          gap: 15px;
          animation: slideUp 0.3s ease;
        }

        .floating-qr-close {
          position: absolute;
          top: 10px;
          right: 10px;
          width: 30px;
          height: 30px;
          background: #000000;
          color: #ffffff;
          border: none;
          font-family: inherit;
          font-size: 18px;
          font-weight: 300;
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
          transition: all 0.2s ease;
          z-index: 10;
        }

        .floating-qr-close:hover {
          background: #333333;
          transform: scale(1.1);
        }

        @keyframes slideUp {
          from {
            opacity: 0;
            transform: translateY(20px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        .floating-qr-header {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .floating-qr-title {
          font-size: 10px;
          font-weight: 300;
          letter-spacing: 0.2em;
          text-transform: uppercase;
          color: #000;
        }

        .floating-qr-description {
          font-size: 8px;
          font-weight: 200;
          letter-spacing: 0.15em;
          text-transform: uppercase;
          color: #666;
        }

        .floating-qr-display {
          display: flex;
          justify-content: center;
        }

        .floating-qr-large-image {
          width: 200px;
          height: 200px;
          object-fit: cover;
          border: 1px solid #e8e8e8;
          background: #ffffff;
        }

        .floating-qr-url {
          text-align: center;
          padding-top: 10px;
          border-top: 1px solid #e8e8e8;
        }

        .floating-qr-url-link {
          color: #666;
          text-decoration: none;
          font-size: 8px;
          font-family: "Courier New", monospace;
          transition: color 0.2s ease;
          letter-spacing: 0.05em;
        }

        .floating-qr-url-link:hover {
          color: #000;
          text-decoration: underline;
        }

        /* Mobile Responsive */
        @media (max-width: 768px) {
          .floating-qr {
            bottom: 20px;
            right: 20px;
          }

          .floating-qr-toggle {
            width: 50px;
            height: 50px;
          }

          .floating-qr-text {
            font-size: 10px;
          }

          .floating-qr-content {
            width: 240px;
            padding: 15px;
          }

          .floating-qr-close {
            width: 25px;
            height: 25px;
            font-size: 16px;
            top: 8px;
            right: 8px;
          }

          .floating-qr-large-image {
            width: 160px;
            height: 160px;
          }

          .floating-qr-title {
            font-size: 9px;
          }

          .floating-qr-description {
            font-size: 7px;
          }

          .floating-qr-url-link {
            font-size: 7px;
          }
        }

        @media (max-width: 480px) {
          .floating-qr {
            bottom: 15px;
            right: 15px;
          }

          .floating-qr-content {
            width: calc(100vw - 60px);
            max-width: 200px;
          }

          .floating-qr-large-image {
            width: 140px;
            height: 140px;
          }
        }
      `}</style>
    </div>
  );
}
