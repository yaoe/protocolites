'use client'

import { useEffect, useState } from 'react'

interface ModalProps {
  isOpen: boolean
  animationUrl: string | null
  onClose: () => void
}

export function Modal({ isOpen, animationUrl, onClose }: ModalProps) {
  const [html, setHtml] = useState<string | null>(null)

  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        onClose()
      }
    }

    if (isOpen) {
      document.addEventListener('keydown', handleEscape)
    }

    return () => {
      document.removeEventListener('keydown', handleEscape)
    }
  }, [isOpen, onClose])

  useEffect(() => {
    if (animationUrl) {
      try {
        if (!animationUrl.startsWith('data:')) {
          setHtml(null)
          return
        }
        const base64 = animationUrl.split(',')[1]
        const decoded = atob(base64)
        setHtml(decoded)
      } catch (error) {
        console.error('Error decoding animation URL:', error)
        setHtml(null)
      }
    }
  }, [animationUrl])

  if (!isOpen) return null

  return (
    <div className={`modal ${isOpen ? 'active' : ''}`} onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <button className="modal-close" onClick={onClose}>
          ×
        </button>
        {html && (
          <iframe
            className="modal-iframe"
            sandbox="allow-scripts allow-same-origin"
            srcDoc={html}
            title="Protocolite Full View"
          />
        )}
      </div>
    </div>
  )
}
