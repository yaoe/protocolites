#!/usr/bin/env python3
import requests
import json
import base64

MASTER_ADDRESS = '0x8a94e7c81a4982a80405b5aead52155208b40d18'
RPC_URL = 'https://rpc.sepolia.org'

def main():
    # Call tokenURI(1)
    payload = {
        "jsonrpc": "2.0",
        "method": "eth_call",
        "params": [{
            "to": MASTER_ADDRESS,
            "data": "0xc87b56dd0000000000000000000000000000000000000000000000000000000000000001"  # tokenURI(1)
        }, "latest"],
        "id": 1
    }

    print("Fetching tokenURI from blockchain...")
    response = requests.post(RPC_URL, json=payload)
    result = response.json()

    if 'error' in result:
        print("Error:", result['error'])
        return

    # Decode the hex response
    hex_data = result['result'][2:]  # Remove 0x

    # Skip the first 64 bytes (offset) and next 64 bytes (length)
    data_start = 128
    token_uri_hex = hex_data[data_start:]

    # Convert hex to bytes
    token_uri_bytes = bytes.fromhex(token_uri_hex)
    token_uri = token_uri_bytes.decode('utf-8').rstrip('\x00')

    print(f"TokenURI length: {len(token_uri)}")
    print(f"TokenURI starts with: {token_uri[:100]}")

    # Decode base64 JSON
    if token_uri.startswith('data:application/json;base64,'):
        json_base64 = token_uri.split(',')[1]
        json_str = base64.b64decode(json_base64).decode('utf-8')
        metadata = json.loads(json_str)

        print(f"\nMetadata name: {metadata['name']}")
        print(f"Description: {metadata['description'][:100]}...")

        # Decode HTML
        if metadata['animation_url'].startswith('data:text/html;base64,'):
            html_base64 = metadata['animation_url'].split(',')[1]
            html = base64.b64decode(html_base64).decode('utf-8')

            # Check renderer type
            is_ascii = 'ascii-display' in html or 'const grid=Array(size)' in html
            is_pixelated = '<canvas' in html

            print(f"\n{'='*80}")
            print(f"RENDERER TYPE:")
            if is_ascii:
                print("✓✓✓ ASCII RENDERER ✓✓✓")
            elif is_pixelated:
                print("✗✗✗ PIXELATED RENDERER (OLD) ✗✗✗")
            else:
                print("??? UNKNOWN ???")
            print(f"{'='*80}")

            print(f"\nHTML length: {len(html)} characters")
            print(f"\nFirst 500 characters:")
            print(html[:500])

            # Save to file
            with open('token1_render.html', 'w') as f:
                f.write(html)
            print(f"\n✓ Saved to: token1_render.html")
            print("Open with: open token1_render.html")

if __name__ == '__main__':
    main()
