// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solady/utils/Base64.sol";
import "solady/utils/LibString.sol";
import "solady/auth/Ownable.sol";

import "./interfaces/IProtocolitesRenderer.sol";

/**
 * @title ProtocolitesRendererUltra
 * @notice ULTRA optimized - removes hats/cigarettes, simplifies logic
 */
contract ProtocolitesRendererUltra is Ownable, IProtocolitesRenderer {
    string public renderScript;

    constructor() {
        _initializeOwner(msg.sender);
        renderScript = getScript();
    }

    function setRenderScript(string memory _script) external onlyOwner {
        renderScript = _script;
    }

    function tokenURI(uint256 tokenId, TokenData memory data) external view returns (string memory) {
        return string.concat("data:application/json;base64,", Base64.encode(bytes(metadata(tokenId, data))));
    }

    function metadata(uint256 tokenId, TokenData memory data) public view returns (string memory) {
        bool isKid = data.isKid;
        uint256 size = isKid ? 16 : 24;

        string memory animation = string.concat(
            '<!DOCTYPE html><html><head><meta charset="UTF-8">',
            '<style>@import url("https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@200&display=swap");',
            '*{margin:0;padding:0}body{font-family:"JetBrains Mono",monospace;background:#fff;display:flex;align-items:center;justify-content:center;min-height:100vh}',
            '.a{font-size:',
            isKid ? '18' : '24',
            'px;line-height:',
            isKid ? '18' : '24',
            'px;white-space:pre}</style></head><body><div class="a" id="d"></div><script>',
            'const T=',
            LibString.toString(tokenId),
            ',D="',
            LibString.toHexString(data.dna),
            '",K=',
            isKid ? '1' : '0',
            ',S=',
            LibString.toString(size),
            ';',
            renderScript,
            '</script></body></html>'
        );

        return string.concat(
            '{"name":"Protocolite #',
            LibString.toString(tokenId),
            isKid ? " (Child)" : " (Spreader)",
            '","description":"On-chain ASCII creatures","animation_url":"data:text/html;base64,',
            Base64.encode(bytes(animation)),
            '","attributes":[{"trait_type":"Type","value":"',
            isKid ? "Child" : "Spreader",
            '"},{"trait_type":"DNA","value":"',
            LibString.toHexString(data.dna),
            '"}]}'
        );
    }

    // Ultra-compressed: removes hats, cigarettes, simplifies body/eye logic
    function getScript() private pure returns (string memory) {
        return string.concat(
            // Setup: hash, color, random, DNA decode (ultra compact)
            'let h=0,i;for(i of D)h=((h<<5)-h)+i.charCodeAt()|0;h=h<0?-h:h;',
            'const C=["#c00","#080","#04c","#c90","#80c","#08a"][Number((BigInt(D)>>17n)%6n)];',
            'let R=h;const r=()=>(R=(R*9301+49297)%233280,R/233280);',
            'const N=BigInt(D),',
            'B=Number(N&7n)%3,', // Only 3 body types instead of 6
            'BC=["\\u2588","\\u2593","\\u2592"][Number(N>>3n&3n)%3],',
            'E=["\\u25cf","\\u25c9","\\u25ce"][Number(N>>5n&3n)%3],',
            'AS=Number(N>>8n&1n)?"\\u2500":"\\u2588",',
            'LS=Number(N>>9n&1n)?"\\u2502":"\\u2588",',
            'AT=["\\u25cf","\\u25c9","\\u2726"][Number(N>>10n&3n)%3];',

            // Grid and constants
            'const G=Array(S).fill().map(()=>Array(S).fill(" ")),',
            'X=S>>1,Y=S>>1,W=S==24?6:3,H=S==24?8:4,Y0=S==24?7:6,',
            'IB=c=>["\\u2588","\\u2593","\\u2592"].includes(c);',

            // Body (simplified to 3 types: square, round, diamond)
            'for(let y=0;y<H;y++)for(let x=-W;x<=W;x++){',
            'const py=Y0+y,px=X+x,rx=x/W,ry=(y-H/2)/(H/2);',
            'let b=B==0||B==1&&Math.sqrt(rx*rx+ry*ry)<=1||B==2&&Math.abs(rx)+Math.abs(ry)<=1;',
            'if(b&&px>=0&&px<S&&py>=0&&py<S)G[py][px]=BC}',

            // Eyes (simplified - only 2 patterns)
            'const EY=Y0+1,ec=K?1+~~(r()*2):1+~~(r()*2);',
            'if(K){',
            'if(ec==1){for(let y=0;y<2;y++)for(let x=-1;x<=1;x++)if(IB(G[EY+y][X+x]))G[EY+y][X+x]=" ";',
            'G[EY][X-1]=BC;G[EY][X]=E;G[EY][X+1]=BC;G[EY+1][X]=BC}',
            'else{for(let y=0;y<2;y++)for(let x=0;x<2;x++){',
            'if(IB(G[EY+y][X-2+x]))G[EY+y][X-2+x]=" ";if(IB(G[EY+y][X+1+x]))G[EY+y][X+1+x]=" "}',
            'G[EY][X-2]=BC;G[EY][X-1]=E;G[EY+1][X-2]=BC;G[EY+1][X-1]=BC;G[EY][X+1]=E;G[EY][X+2]=BC;G[EY+1][X+1]=BC;G[EY+1][X+2]=BC}',
            '}else{',
            'if(ec==1){for(let y=0;y<3;y++)for(let x=-2;x<=2;x++)if(IB(G[EY+y][X+x]))G[EY+y][X+x]=" ";',
            'for(let x=-2;x<=2;x++){G[EY][X+x]=BC;G[EY+2][X+x]=BC}',
            'G[EY+1][X-2]=BC;G[EY+1][X-1]=E;G[EY+1][X]=E;G[EY+1][X+1]=E;G[EY+1][X+2]=BC}',
            'else{for(let y=0;y<3;y++)for(let x=0;x<3;x++){',
            'if(IB(G[EY+y][X-4+x]))G[EY+y][X-4+x]=" ";if(IB(G[EY+y][X+2+x]))G[EY+y][X+2+x]=" "}',
            'for(let y=0;y<3;y++)for(let x=0;x<3;x++){G[EY+y][X-4+x]=y==1&&x==1?E:BC;G[EY+y][X+2+x]=y==1&&x==1?E:BC}}}',

            // Simplified mouth
            'if(r()>.4){const my=EY+(K?2:3);if(my<S&&IB(G[my][X]))G[my][X]="\\u2500"}',

            // Arms (simplified)
            'const ac=1+~~(r()*3),al=K?1+~~(r()*2):2+~~(r()*3);',
            'for(let a=0;a<ac;a++){const ay=Y0+2+a*(K?1:2);if(ay>=Y0+H)break;',
            'let l=X,rr=X;for(let x=X;x>=0&&IB(G[ay][x]);x--)l=x;for(let x=X;x<S&&IB(G[ay][x]);x++)rr=x;',
            'for(let i=1;i<=al;i++){if(l-i>=0)G[ay][l-i]=AS;if(rr+i<S)G[ay][rr+i]=AS}}',

            // Legs (simplified)
            'const lc=1+~~(r()*3),ly=Y0+H,ll=K?1+~~(r()*2):2+~~(r()*2),bp=[];',
            'for(let x=0;x<S;x++)if(G[ly-1]&&IB(G[ly-1][x]))bp.push(x);',
            'const lp=[];if(bp.length){',
            'if(lc==1)lp.push(bp[~~(bp.length/2)]);',
            'else if(lc==2){lp.push(bp[~~(bp.length*.3)]);lp.push(bp[~~(bp.length*.7)])}',
            'else{lp.push(bp[~~(bp.length*.25)]);lp.push(bp[~~(bp.length*.75)])}}',
            'for(let x of lp)if(x>=0&&x<S)for(let i=0;i<ll;i++)if(ly+i<S)G[ly+i][x]=LS;',

            // Antennas (simplified)
            'const nc=1+~~(r()*3),nl=K?1:1+~~(r()*2),tp=[];',
            'for(let x=0;x<S;x++)if(G[Y0]&&IB(G[Y0][x]))tp.push(x);',
            'const np=[];if(tp.length){',
            'if(nc==1)np.push(tp[~~(tp.length/2)]);',
            'else if(nc==2){np.push(tp[~~(tp.length*.3)]);np.push(tp[~~(tp.length*.7)])}',
            'else{np.push(tp[~~(tp.length*.25)]);np.push(tp[~~(tp.length*.75)])}}',
            'for(let x of np)for(let i=1;i<=nl;i++){const y=Y0-i;if(y>=0)G[y][x]=i==nl?AT:"\\u2502"}',

            // Render
            'd.textContent=G.map(r=>r.join("")).join("\\n");d.style.color=C'
        );
    }
}
