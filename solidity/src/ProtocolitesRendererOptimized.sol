// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solady/utils/Base64.sol";
import "solady/utils/LibString.sol";
import "solady/auth/Ownable.sol";

import "./interfaces/IProtocolitesRenderer.sol";

/**
 * @title ProtocolitesRendererOptimized
 * @notice Highly optimized renderer - same look, minimal gas
 * @dev Removes animations, aggressively minifies code
 */
contract ProtocolitesRendererOptimized is Ownable, IProtocolitesRenderer {
    string public renderScript;

    constructor() {
        _initializeOwner(msg.sender);
        renderScript = getMinifiedScript();
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

        // Ultra-compact HTML - no animations, minimal CSS
        string memory animation = string.concat(
            '<!DOCTYPE html><html><head><meta charset="UTF-8">',
            '<style>@import url("https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@200&display=swap");',
            '*{margin:0;padding:0}',
            'body{font-family:"JetBrains Mono",monospace;background:#fff;display:flex;align-items:center;justify-content:center;min-height:100vh}',
            '.a{font-size:',
            isKid ? '18' : '24',
            'px;line-height:',
            isKid ? '18' : '24',
            'px;white-space:pre}',
            '</style></head><body><div class="a" id="d"></div><script>',
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

        string memory attributes = string.concat(
            '[{"trait_type":"Type","value":"',
            isKid ? "Child" : "Spreader",
            '"},{"trait_type":"DNA","value":"',
            LibString.toHexString(data.dna),
            '"}]'
        );

        string memory json = string.concat(
            '{"name":"Protocolite #',
            LibString.toString(tokenId),
            isKid ? " (Child)" : " (Spreader)",
            '","description":"On-chain ASCII art with DNA inheritance","animation_url":"data:text/html;base64,',
            Base64.encode(bytes(animation)),
            '","attributes":',
            attributes,
            '}'
        );

        return json;
    }

    // Aggressively minified generation script
    function getMinifiedScript() private pure returns (string memory) {
        return string.concat(
            getPart1(),
            getPart2(),
            getPart3(),
            getPart4()
        );
    }

    function getPart1() private pure returns (string memory) {
        return string.concat(
            // Hash, family detection, random, DNA decoder - all minified
            'function H(s){let h=0,i=0;for(;i<s.length;)h=((h<<5)-h)+s.charCodeAt(i++)|0;return h<0?-h:h}',
            'const F={r:"#c00",g:"#080",b:"#04c",y:"#c90",p:"#80c",c:"#08a"},',
            'C=F[["r","g","b","y","p","c"][Number((BigInt(D)>>17n)%6n)]];',
            'let R=H(D);function r(){return R=(R*9301+49297)%233280,R/233280}',
            // Decode DNA
            'const N=BigInt(D),',
            'B=["square","round","diamond","mushroom","invader","ghost"][Number(N&7n)%6],',
            'BC=["\\u2588","\\u2593","\\u2592","\\u2591"][Number(N>>3n&3n)],',
            'E=["\\u25cf","\\u25c9","\\u25ce","\\u25cb"][Number(N>>5n&3n)],',
            'M=Number(N>>7n&1n),',
            'A=["\\u25cf","\\u25c9","\\u25cb","\\u25ce","\\u2726","\\u2727","\\u2605"][Number(N>>8n&7n)%7],',
            'AS=Number(N>>11n&1n)?"\\u2500":"\\u2588",',
            'LS=Number(N>>12n&1n)?"\\u2502":"\\u2588",',
            'H=Number(N>>13n&7n)%5,',
            'CG=Number(N>>16n&1n);'
        );
    }

    function getPart2() private pure returns (string memory) {
        return string.concat(
            // Grid setup, body generation
            'const G=Array(S).fill().map(()=>Array(S).fill(" ")),',
            'X=S>>1,Y=S>>1,',
            'W=S==24?6:3,H2=S==24?8:4,Y0=S==24?7:6,',
            'IB=c=>["\\u2588","\\u2593","\\u2592","\\u2591"].includes(c);',
            // Body generation - combined and minified
            'for(let y=0;y<H2;y++)for(let x=-W;x<=W;x++){',
            'const py=Y0+y,px=X+x,rx=x/W,ry=(y-H2/2)/(H2/2);',
            'let b=0;',
            'if(B=="square")b=1;',
            'else if(B=="round")b=Math.sqrt(rx*rx+ry*ry)<=1;',
            'else if(B=="diamond")b=Math.abs(rx)+Math.abs(ry)<=1;',
            'else if(B=="mushroom")b=K?(ry<-.2?1:Math.abs(rx)<=.7):(ry<0?1:Math.abs(rx)<=.6);',
            'else if(B=="invader")b=ry<-.3?Math.abs(rx)<=.7:ry<.3?1:Math.abs(rx)<=.85;',
            'else if(B=="ghost"){const d=Math.sqrt(rx*rx+ry*ry);b=ry<.5?d<=1:Math.abs(rx)<=.9&&(Math.floor(x+W)%2==0||ry<.8)}',
            'if(b&&px>=0&&px<S&&py>=0&&py<S)G[py][px]=BC}'
        );
    }

    function getPart3() private pure returns (string memory) {
        return string.concat(
            // Eyes, mouth, cigarette - minified
            'const EY=Y0+1;',
            'if(K){', // Kids
            'const ec=1+~~(r()*3);',
            'if(ec==1){for(let y=0;y<2;y++)for(let x=-1;x<=1;x++)if(IB(G[EY+y][X+x]))G[EY+y][X+x]=" ";',
            'G[EY][X-1]=BC;G[EY][X]=E;G[EY][X+1]=BC;G[EY+1][X]=BC}',
            'else if(ec==2){for(let y=0;y<2;y++)for(let x=0;x<2;x++){',
            'if(IB(G[EY+y][X-2+x]))G[EY+y][X-2+x]=" ";',
            'if(IB(G[EY+y][X+1+x]))G[EY+y][X+1+x]=" "}',
            'G[EY][X-2]=BC;G[EY][X-1]=E;G[EY+1][X-2]=BC;G[EY+1][X-1]=BC;',
            'G[EY][X+1]=E;G[EY][X+2]=BC;G[EY+1][X+1]=BC;G[EY+1][X+2]=BC}',
            'else for(let x of[-2,0,2]){if(IB(G[EY][X+x]))G[EY][X+x]=" ";G[EY][X+x]=E}',
            '}else{', // Adults
            'const ec=1+~~(r()*3);',
            'if(ec==1){for(let y=0;y<3;y++)for(let x=-2;x<=2;x++)if(IB(G[EY+y][X+x]))G[EY+y][X+x]=" ";',
            'for(let x=-2;x<=2;x++){G[EY][X+x]=BC;G[EY+2][X+x]=BC}',
            'G[EY+1][X-2]=BC;G[EY+1][X-1]=E;G[EY+1][X]=E;G[EY+1][X+1]=E;G[EY+1][X+2]=BC}',
            'else if(ec==2){for(let y=0;y<3;y++)for(let x=0;x<3;x++){',
            'if(IB(G[EY+y][X-4+x]))G[EY+y][X-4+x]=" ";',
            'if(IB(G[EY+y][X+2+x]))G[EY+y][X+2+x]=" "}',
            'for(let y=0;y<3;y++)for(let x=0;x<3;x++){',
            'G[EY+y][X-4+x]=y==1&&x==1?E:BC;G[EY+y][X+2+x]=y==1&&x==1?E:BC}}',
            'else for(let i of[-3,3])for(let y=0;y<2;y++){',
            'if(IB(G[EY+y][X+i]))G[EY+y][X+i]=" ";',
            'if(IB(G[EY+y][X+i-1]))G[EY+y][X+i-1]=" ";',
            'G[EY+y][X+i]=E;G[EY+y][X+i-1]=E}}',
            // Mouth
            'if(r()>.3){const my=EY+(K?2:3);',
            'if(my<S&&IB(G[my][X])){G[my][X]="\\u2500";',
            'if(r()>.5&&IB(G[my][X-1]))G[my][X-1]="\\u2500";',
            'if(r()>.5&&IB(G[my][X+1]))G[my][X+1]="\\u2500"}}',
            // Cigarette
            'if(CG){const cy=EY+(K?2:3),cx=X+(r()>.5?3:-3);',
            'if(cx>=0&&cx<S&&cy<S){G[cy][cx]=["\\u2248","\\u223c","~"][~~(r()*3)];if(cx+1<S)G[cy][cx+1]="\\u2219"}}'
        );
    }

    function getPart4() private pure returns (string memory) {
        return string.concat(
            // Arms, legs, antennas, hat - minified
            'const ac=1+~~(r()*4),al=K?1+~~(r()*2):2+~~(r()*4);',
            'for(let a=0;a<ac;a++){const ay=Y0+2+a*(K?1:2);',
            'if(ay>=Y0+H2)break;',
            'let l=X,rr=X;',
            'for(let x=X;x>=0&&IB(G[ay][x]);x--)l=x;',
            'for(let x=X;x<S&&IB(G[ay][x]);x++)rr=x;',
            'for(let i=1;i<=al;i++){if(l-i>=0)G[ay][l-i]=AS;if(rr+i<S)G[ay][rr+i]=AS}}',
            // Legs
            'const lc=1+~~(r()*4),ly=Y0+H2,ll=K?1+~~(r()*2):2+~~(r()*3),bp=[];',
            'for(let x=0;x<S;x++)if(G[ly-1]&&IB(G[ly-1][x]))bp.push(x);',
            'const lp=[];',
            'if(bp.length){',
            'if(lc==1)lp.push(bp[~~(bp.length/2)]);',
            'else if(lc==2){lp.push(bp[~~(bp.length*.25)]);lp.push(bp[~~(bp.length*.75)])}',
            'else if(lc==3){lp.push(bp[0]);lp.push(bp[~~(bp.length/2)]);lp.push(bp[bp.length-1])}',
            'else{lp.push(bp[0]);lp.push(bp[~~(bp.length*.33)]);lp.push(bp[~~(bp.length*.66)]);lp.push(bp[bp.length-1])}}',
            'for(let x of lp)if(x>=0&&x<S)for(let i=0;i<ll;i++)if(ly+i<S)G[ly+i][x]=LS;',
            // Antennas
            'const nc=1+~~(r()*4),nl=K?1:1+~~(r()*2),tp=[];',
            'for(let x=0;x<S;x++)if(G[Y0]&&IB(G[Y0][x]))tp.push(x);',
            'const np=[];',
            'if(tp.length){',
            'if(nc==1)np.push(tp[~~(tp.length/2)]);',
            'else if(nc==2){np.push(tp[~~(tp.length*.25)]);np.push(tp[~~(tp.length*.75)])}',
            'else if(nc==3){np.push(tp[0]);np.push(tp[~~(tp.length/2)]);np.push(tp[tp.length-1])}',
            'else{np.push(tp[0]);np.push(tp[~~(tp.length*.33)]);np.push(tp[~~(tp.length*.66)]);np.push(tp[tp.length-1])}}',
            'for(let x of np)for(let i=1;i<=nl;i++){const y=Y0-i;if(y>=0)G[y][x]=i==nl?A:"\\u2502"}',
            // Hat
            'const hy=Y0-nl-1;',
            'if(H&&hy>=0){',
            'if(H==1){for(let x=-2;x<=2;x++)if(X+x>=0&&X+x<S)G[hy][X+x]="\\u2580";',
            'if(hy+1<S)G[hy+1][X]="\\u2588"}',
            'else if(H==2)for(let x=-2;x<=2;x++)if(X+x>=0&&X+x<S)G[hy][X+x]="\\u2550";',
            'else if(H==3)for(let x=-2;x<=2;x++)if(X+x>=0&&X+x<S&&hy-1>=0){G[hy-1][X+x]="\\u2580";G[hy][X+x]="\\u2584"}',
            'else if(H==4&&X-2>=0&&X+2<S){G[hy][X-2]="\\u2554";G[hy][X-1]="\\u2550";G[hy][X]="\\u2550";G[hy][X+1]="\\u2550";G[hy][X+2]="\\u2557"}}',
            // Render
            'd.textContent=G.map(r=>r.join("")).join("\\n");d.style.color=C'
        );
    }
}
