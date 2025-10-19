// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solady/utils/Base64.sol";
import "solady/utils/LibString.sol";
import "solady/auth/Ownable.sol";

import "./interfaces/IProtocolitesRenderer.sol";

/**
 * @title ProtocolitesRendererAnimated
 * @notice Advanced renderer with canvas-based animations and temperament system
 * @dev Based on the V_ANIMATED HTML template with per-attribute animations
 */
contract ProtocolitesRendererAnimated is Ownable, IProtocolitesRenderer {
    string public renderScript;

    constructor() {
        _initializeOwner(msg.sender);
        renderScript = defaultScript();
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

        // HTML with canvas animation
        string memory animation = string.concat(
            '<!DOCTYPE html><html><head><meta charset="UTF-8">',
            '<meta name="viewport" content="width=device-width,initial-scale=1.0">',
            '<title>Protocolite #', LibString.toString(tokenId), '</title>',
            '<style>',
            '@import url("https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@100;200;300;400&display=swap");',
            '*{margin:0;padding:0;box-sizing:border-box;}',
            'body{font-family:"JetBrains Mono","Courier New",monospace;background:#fff;color:#000;',
            'display:flex;align-items:center;justify-content:center;min-height:100vh;overflow:hidden;}',
            'canvas{image-rendering:crisp-edges;image-rendering:pixelated;transform:scale(3.5);transform-origin:center;}',
            '</style></head><body>',
            '<canvas id="c"></canvas>',
            '<script>',
            'const tokenId=', LibString.toString(tokenId), ';',
            'const dna="', LibString.toHexString(data.dna), '";',
            'const isKid=', isKid ? 'true' : 'false', ';',
            'const parentDna="', LibString.toHexString(data.parentDna), '";',
            'const size=', LibString.toString(size), ';',
            renderScript,
            '</script></body></html>'
        );

        string memory attributes = string.concat(
            '[{"trait_type":"Type","value":"', isKid ? "Child" : "Spreader", '"},',
            '{"trait_type":"Size","value":"', LibString.toString(size), 'x', LibString.toString(size), '"},',
            '{"trait_type":"DNA","value":"', LibString.toHexString(data.dna), '"},',
            '{"trait_type":"Birth Block","value":', LibString.toString(data.birthBlock), '}',
            isKid ? string.concat(',{"trait_type":"Parent DNA","value":"', LibString.toHexString(data.parentDna), '"}') : '',
            ']'
        );

        string memory json = string.concat(
            '{"name":"Protocolite #', LibString.toString(tokenId),
            isKid ? " (Child)" : " (Spreader)", '",',
            '"description":"Fully on-chain generative ASCII art with advanced canvas animations and temperament system.",',
            '"animation_url":"data:text/html;base64,', Base64.encode(bytes(animation)), '",',
            '"attributes":', attributes, '}'
        );

        return json;
    }

    // Core DNA parsing and family selection
    function getScript1() private pure returns (string memory) {
        return string.concat(
            'function hashCode(s){let h=0;for(let i=0;i<s.length;i++){h=((h<<5)-h)+s.charCodeAt(i);h&=h;}return Math.abs(h);}',
            'const families={red:"#cc0000",green:"#008800",blue:"#0044cc",yellow:"#cc9900",purple:"#8800cc",cyan:"#0088aa"};',
            'function getFamilyFromDNA(d){const n=BigInt(d);const h=Number((n>>17n)%16777216n);',
            'const fams=Object.keys(families);return fams[h%fams.length];}',
            'const family=getFamilyFromDNA(dna);const familyColor=families[family];',
            'function random(){seed=(seed*9301+49297)%233280;return seed/233280;}let seed=hashCode(dna);'
        );
    }

    // DNA decoding with temperament
    function getScript2() private pure returns (string memory) {
        return string.concat(
            'function decodeDNA(d){const n=BigInt(d);',
            'const temps=["calm","balanced","energetic","chaotic","glitchy","unstable"];',
            'const tempWeights=[35,30,20,10,4,1];let totalW=100;',
            'const tempIdx=Number((n>>20n)&7n)%6;',
            'return{',
            'bodyType:["square","round","diamond","mushroom","invader","ghost"][Number((n>>0n)&7n)%6],',
            'bodyChar:["\\u2588","\\u2593","\\u2592","\\u2591"][Number((n>>3n)&3n)],',
            'eyeChar:["\\u25cf","\\u25c9","\\u25ce","\\u25cb"][Number((n>>5n)&3n)],',
            'eyeSize:Number((n>>7n)&1n)===1?"mega":"normal",',
            'antennaTip:["\\u25cf","\\u25c9","\\u25cb","\\u25ce","\\u2726","\\u2727","\\u2605"][Number((n>>8n)&7n)%7],',
            'armStyle:Number((n>>11n)&1n)===1?"line":"block",',
            'legStyle:Number((n>>12n)&1n)===1?"line":"block",',
            'hatType:["none","top","flat","double","fancy"][Number((n>>13n)&7n)%5],',
            'hasCig:Number((n>>16n)&1n)===1,',
            'temperament:temps[tempIdx]};}',
            'const dnaObj=decodeDNA(dna);'
        );
    }

    // Grid generation with type tracking
    function getScript3() private pure returns (string memory) {
        return string.concat(
            'const grid=Array(size).fill().map(()=>Array(size).fill().map(()=>({char:" ",type:"empty"})));',
            'const cx=Math.floor(size/2);const cy=Math.floor(size/2);',
            'const bodyWidth=size===24?6:3;const bodyHeight=size===24?8:4;const bodyStartY=size===24?7:6;',
            'const bodyType=dnaObj.bodyType;',
            'for(let y=0;y<bodyHeight;y++){for(let x=-bodyWidth;x<=bodyWidth;x++){',
            'const posY=bodyStartY+y;const posX=cx+x;let inBody=false;',
            'const relX=x/bodyWidth;const relY=(y-bodyHeight/2)/(bodyHeight/2);',
            'if(bodyType==="square")inBody=true;',
            'else if(bodyType==="round"){const d=Math.sqrt(relX*relX+relY*relY);inBody=d<=1.0;}',
            'else if(bodyType==="diamond")inBody=Math.abs(relX)+Math.abs(relY)<=1.0;',
            'else if(bodyType==="mushroom"){if(isKid){inBody=relY<-0.2?true:Math.abs(relX)<=0.7;}',
            'else{inBody=relY<0?true:Math.abs(relX)<=0.6;}}',
            'else if(bodyType==="invader"){if(relY<-0.3)inBody=Math.abs(relX)<=0.7;',
            'else if(relY<0.3)inBody=true;else inBody=Math.abs(relX)<=0.85;}',
            'else if(bodyType==="ghost"){const dg=Math.sqrt(relX*relX+relY*relY);',
            'if(relY<0.5)inBody=dg<=1.0;else inBody=Math.abs(relX)<=0.9&&(Math.floor(x+bodyWidth)%2===0||relY<0.8);}',
            'if(inBody&&posX>=0&&posX<size&&posY>=0&&posY<size)grid[posY][posX]={char:dnaObj.bodyChar,type:"body"};}}'
        );
    }

    // Eyes with type marking
    function getScript4() private pure returns (string memory) {
        return string.concat(
            'const isBodyChar=c=>c&&c.type==="body";const eyeY=bodyStartY+1;',
            'if(isKid){const ec=1+Math.floor(random()*3);',
            'if(ec===1){for(let dy=0;dy<2;dy++)for(let dx=-1;dx<=1;dx++)if(isBodyChar(grid[eyeY+dy][cx+dx]))grid[eyeY+dy][cx+dx]={char:" ",type:"empty"};',
            'grid[eyeY][cx-1]={char:dnaObj.bodyChar,type:"body"};grid[eyeY][cx]={char:dnaObj.eyeChar,type:"eye"};',
            'grid[eyeY][cx+1]={char:dnaObj.bodyChar,type:"body"};grid[eyeY+1][cx]={char:dnaObj.bodyChar,type:"body"};}',
            'else if(ec===2){const es=1;for(let dy=0;dy<2;dy++)for(let dx=0;dx<2;dx++){',
            'if(isBodyChar(grid[eyeY+dy][cx-es-1+dx]))grid[eyeY+dy][cx-es-1+dx]={char:" ",type:"empty"};',
            'if(isBodyChar(grid[eyeY+dy][cx+es+dx]))grid[eyeY+dy][cx+es+dx]={char:" ",type:"empty"};}',
            'grid[eyeY][cx-es-1]={char:dnaObj.bodyChar,type:"body"};grid[eyeY][cx-es]={char:dnaObj.eyeChar,type:"eye"};',
            'grid[eyeY+1][cx-es-1]={char:dnaObj.bodyChar,type:"body"};grid[eyeY+1][cx-es]={char:dnaObj.bodyChar,type:"body"};',
            'grid[eyeY][cx+es]={char:dnaObj.eyeChar,type:"eye"};grid[eyeY][cx+es+1]={char:dnaObj.bodyChar,type:"body"};',
            'grid[eyeY+1][cx+es]={char:dnaObj.bodyChar,type:"body"};grid[eyeY+1][cx+es+1]={char:dnaObj.bodyChar,type:"body"};}',
            'else{for(let dx of[-2,0,2]){if(isBodyChar(grid[eyeY][cx+dx]))grid[eyeY][cx+dx]={char:" ",type:"empty"};',
            'grid[eyeY][cx+dx]={char:dnaObj.eyeChar,type:"eye"};}}}else{'
        );
    }

    function getScript5() private pure returns (string memory) {
        return string.concat(
            'const ec=1+Math.floor(random()*3);if(ec===1){',
            'for(let dy=0;dy<3;dy++)for(let dx=-2;dx<=2;dx++)if(isBodyChar(grid[eyeY+dy][cx+dx]))grid[eyeY+dy][cx+dx]={char:" ",type:"empty"};',
            'for(let dx=-2;dx<=2;dx++){grid[eyeY][cx+dx]={char:dnaObj.bodyChar,type:"body"};grid[eyeY+2][cx+dx]={char:dnaObj.bodyChar,type:"body"};}',
            'grid[eyeY+1][cx-2]={char:dnaObj.bodyChar,type:"body"};grid[eyeY+1][cx-1]={char:dnaObj.eyeChar,type:"eye"};',
            'grid[eyeY+1][cx]={char:dnaObj.eyeChar,type:"eye"};grid[eyeY+1][cx+1]={char:dnaObj.eyeChar,type:"eye"};',
            'grid[eyeY+1][cx+2]={char:dnaObj.bodyChar,type:"body"};}else if(ec===2){const bs=2;',
            'for(let dy=0;dy<3;dy++)for(let dx=0;dx<3;dx++){',
            'if(isBodyChar(grid[eyeY+dy][cx-bs-2+dx]))grid[eyeY+dy][cx-bs-2+dx]={char:" ",type:"empty"};',
            'if(isBodyChar(grid[eyeY+dy][cx+bs+dx]))grid[eyeY+dy][cx+bs+dx]={char:" ",type:"empty"};}',
            'for(let dy=0;dy<3;dy++)for(let dx=0;dx<3;dx++){const ic=dy===1&&dx===1;',
            'grid[eyeY+dy][cx-bs-2+dx]={char:ic?dnaObj.eyeChar:dnaObj.bodyChar,type:ic?"eye":"body"};',
            'grid[eyeY+dy][cx+bs+dx]={char:ic?dnaObj.eyeChar:dnaObj.bodyChar,type:ic?"eye":"body"};}}',
            'else{for(let i=-3;i<=3;i+=3)for(let dy=0;dy<2;dy++){',
            'if(isBodyChar(grid[eyeY+dy][cx+i]))grid[eyeY+dy][cx+i]={char:" ",type:"empty"};',
            'if(isBodyChar(grid[eyeY+dy][cx+i-1]))grid[eyeY+dy][cx+i-1]={char:" ",type:"empty"};',
            'grid[eyeY+dy][cx+i]={char:dnaObj.eyeChar,type:"eye"};grid[eyeY+dy][cx+i-1]={char:dnaObj.eyeChar,type:"eye"};}}}',
            'if(random()>0.3){const my=eyeY+(isKid?2:3);if(my<size&&isBodyChar(grid[my][cx])){',
            'grid[my][cx]={char:"\\u2500",type:"mouth"};',
            'if(random()>0.5&&isBodyChar(grid[my][cx-1]))grid[my][cx-1]={char:"\\u2500",type:"mouth"};',
            'if(random()>0.5&&isBodyChar(grid[my][cx+1]))grid[my][cx+1]={char:"\\u2500",type:"mouth"};}}'
        );
    }

    // Cigarette, arms, legs
    function getScript6() private pure returns (string memory) {
        return string.concat(
            'if(dnaObj.hasCig){const cy=eyeY+(isKid?2:3);const cigChars=["\\u2248","\\u223c","~"];',
            'const cigChar=cigChars[Math.floor(random()*cigChars.length)];const cigX=cx+(random()>0.5?3:-3);',
            'if(cigX>=0&&cigX<size&&cy>=0&&cy<size){grid[cy][cigX]={char:cigChar,type:"cig"};',
            'if(cigX+1<size)grid[cy][cigX+1]={char:"\\u2219",type:"cig"};}}',
            'const armCnt=1+Math.floor(random()*4);const armLen=isKid?(1+Math.floor(random()*2)):(2+Math.floor(random()*4));',
            'const armChar=dnaObj.armStyle==="block"?"\\u2588":"\\u2500";',
            'for(let a=0;a<armCnt;a++){const ay=bodyStartY+2+a*(isKid?1:2);if(ay>=bodyStartY+bodyHeight)break;',
            'let lbe=cx,rbe=cx;for(let x=cx;x>=0;x--)if(isBodyChar(grid[ay][x]))lbe=x;else break;',
            'for(let x=cx;x<size;x++)if(isBodyChar(grid[ay][x]))rbe=x;else break;',
            'for(let i=1;i<=armLen;i++){if(lbe-i>=0)grid[ay][lbe-i]={char:armChar,type:"arm"};',
            'if(rbe+i<size)grid[ay][rbe+i]={char:armChar,type:"arm"};}}',
            'const legCnt=1+Math.floor(random()*4);const legY=bodyStartY+bodyHeight;',
            'const legLen=isKid?(1+Math.floor(random()*2)):(2+Math.floor(random()*3));',
            'const legChar=dnaObj.legStyle==="block"?"\\u2588":"\\u2502";const bps=[];',
            'for(let x=0;x<size;x++)if(grid[legY-1]&&isBodyChar(grid[legY-1][x]))bps.push(x);',
            'const lps=[];if(bps.length>0){if(legCnt===1)lps.push(bps[Math.floor(bps.length/2)]);',
            'else if(legCnt===2){lps.push(bps[Math.floor(bps.length*0.25)]);lps.push(bps[Math.floor(bps.length*0.75)]);}',
            'else if(legCnt===3){lps.push(bps[0]);lps.push(bps[Math.floor(bps.length/2)]);lps.push(bps[bps.length-1]);}',
            'else{lps.push(bps[0]);lps.push(bps[Math.floor(bps.length*0.33)]);',
            'lps.push(bps[Math.floor(bps.length*0.66)]);lps.push(bps[bps.length-1]);}}',
            'for(let lx of lps)if(lx>=0&&lx<size)for(let i=0;i<legLen;i++)if(legY+i<size)grid[legY+i][lx]={char:legChar,type:"leg"};'
        );
    }

    // Antennas and hat
    function getScript7() private pure returns (string memory) {
        return string.concat(
            'const antCnt=1+Math.floor(random()*4);const antLen=isKid?1:(1+Math.floor(random()*2));const btp=[];',
            'for(let x=0;x<size;x++)if(grid[bodyStartY]&&isBodyChar(grid[bodyStartY][x]))btp.push(x);',
            'const aps=[];if(btp.length>0){if(antCnt===1)aps.push(btp[Math.floor(btp.length/2)]);',
            'else if(antCnt===2){aps.push(btp[Math.floor(btp.length*0.25)]);aps.push(btp[Math.floor(btp.length*0.75)]);}',
            'else if(antCnt===3){aps.push(btp[0]);aps.push(btp[Math.floor(btp.length/2)]);aps.push(btp[btp.length-1]);}',
            'else{aps.push(btp[0]);aps.push(btp[Math.floor(btp.length*0.33)]);',
            'aps.push(btp[Math.floor(btp.length*0.66)]);aps.push(btp[btp.length-1]);}}',
            'for(let ax of aps)for(let i=1;i<=antLen;i++){const ay=bodyStartY-i;',
            'if(ay>=0)grid[ay][ax]={char:i===antLen?dnaObj.antennaTip:"\\u2502",type:i===antLen?"ant-tip":"ant"};}',
            'if(dnaObj.hatType&&dnaObj.hatType!=="none"){const hy=bodyStartY-antLen-1;if(hy>=0){',
            'if(dnaObj.hatType==="top"){for(let dx=-2;dx<=2;dx++)if(cx+dx>=0&&cx+dx<size)grid[hy][cx+dx]={char:"\\u2580",type:"hat"};',
            'if(hy+1<size)grid[hy+1][cx]={char:"\\u2588",type:"hat"};}',
            'else if(dnaObj.hatType==="flat"){for(let dx=-2;dx<=2;dx++)if(cx+dx>=0&&cx+dx<size)grid[hy][cx+dx]={char:"\\u2550",type:"hat"};}',
            'else if(dnaObj.hatType==="double"){for(let dx=-2;dx<=2;dx++)if(cx+dx>=0&&cx+dx<size&&hy-1>=0){',
            'grid[hy-1][cx+dx]={char:"\\u2580",type:"hat"};grid[hy][cx+dx]={char:"\\u2584",type:"hat"};}}',
            'else if(dnaObj.hatType==="fancy"&&cx-2>=0&&cx+2<size){grid[hy][cx-2]={char:"\\u2554",type:"hat"};',
            'grid[hy][cx-1]={char:"\\u2550",type:"hat"};grid[hy][cx]={char:"\\u2550",type:"hat"};',
            'grid[hy][cx+1]={char:"\\u2550",type:"hat"};grid[hy][cx+2]={char:"\\u2557",type:"hat"};}}}'
        );
    }

    // Canvas animation engine
    function getScript8() private pure returns (string memory) {
        return string.concat(
            'const canvas=document.getElementById("c");const ctx=canvas.getContext("2d");',
            'const fontSize=size===24?9:8;ctx.font=fontSize+"px \\"Courier New\\",monospace";',
            'ctx.textBaseline="top";ctx.textAlign="left";const metrics=ctx.measureText("\\u2588");',
            'const charW=metrics.width;const lineH=fontSize;canvas.width=size*charW;canvas.height=size*lineH;',
            'const tempCfg={calm:{spd:1.5,glitch:0.02,corrupt:0},balanced:{spd:2.5,glitch:0.05,corrupt:0},',
            'energetic:{spd:3.5,glitch:0.12,corrupt:0.03},chaotic:{spd:5,glitch:0.25,corrupt:0.08},',
            'glitchy:{spd:6,glitch:0.4,corrupt:0.15},unstable:{spd:7,glitch:0.6,corrupt:0.25}}[dnaObj.temperament]||{spd:2,glitch:0.05,corrupt:0};',
            'let time=0;const corruptChars=["\\u2588","\\u2593","\\u2592","\\u2591","\\u2580","\\u2584"];',
            'function animate(){ctx.clearRect(0,0,canvas.width,canvas.height);time+=tempCfg.spd*0.016;',
            'const isGlitch=Math.random()<tempCfg.glitch;',
            'for(let y=0;y<size;y++){let rowOff=0;',
            'if(isGlitch&&(dnaObj.temperament==="chaotic"||dnaObj.temperament==="glitchy"||dnaObj.temperament==="unstable")){',
            'if(Math.random()<0.1)rowOff=(Math.random()-0.5)*6;}',
            'for(let x=0;x<size;x++){const cell=grid[y][x];if(!cell||cell.char===" ")continue;',
            'let char=cell.char;const type=cell.type;',
            'if(isGlitch&&Math.random()<tempCfg.corrupt)char=corruptChars[Math.floor(Math.random()*corruptChars.length)];',
            'let posX=x*charW;let posY=y*lineH;'
        );
    }

    function getScript9() private pure returns (string memory) {
        return string.concat(
            'if(type==="body"){const breathe=Math.sin(time+x*0.1)*2;posY+=breathe;}',
            'else if(type==="eye"){if(Math.sin(time*0.5)<-0.95)char="\\u2500";',
            'if(dnaObj.temperament==="energetic"||dnaObj.temperament==="chaotic"||dnaObj.temperament==="glitchy"||dnaObj.temperament==="unstable")posX+=Math.sin(time*2+y)*1.5;}',
            'else if(type==="arm"){const wave=Math.sin(time*1.5+y*0.5)*3;posY+=wave;',
            'if(dnaObj.temperament==="chaotic"||dnaObj.temperament==="glitchy"||dnaObj.temperament==="unstable")posX+=Math.cos(time*2+x)*2;}',
            'else if(type==="leg"){const march=Math.sin(time*2+x*1.5)*2;posY+=march;}',
            'else if(type==="ant"||type==="ant-tip"){const wobble=Math.sin(time+x*0.3)*2;posX+=wobble;}',
            'else if(type==="mouth"){if(Math.sin(time*0.7)>0.7&&(dnaObj.temperament==="energetic"||dnaObj.temperament==="chaotic"||dnaObj.temperament==="glitchy"||dnaObj.temperament==="unstable"))char="\\u25cb";}',
            'if(isGlitch){const glitchMult=dnaObj.temperament==="unstable"?4:dnaObj.temperament==="glitchy"?3:dnaObj.temperament==="chaotic"?2:dnaObj.temperament==="energetic"?1.5:1;',
            'posX+=(Math.random()-0.5)*glitchMult;posY+=(Math.random()-0.5)*glitchMult;}',
            'posX+=rowOff;let color=familyColor;',
            'if(isGlitch&&(dnaObj.temperament==="chaotic"||dnaObj.temperament==="glitchy"||dnaObj.temperament==="unstable")){',
            'const colors=["#ff0000","#00ff00","#0000ff",familyColor];color=colors[Math.floor(Math.random()*colors.length)];}',
            'ctx.fillStyle=color;ctx.fillText(char,posX,posY);}}',
            'requestAnimationFrame(animate);}animate();'
        );
    }

    function defaultScript() private pure returns (string memory) {
        return string.concat(
            getScript1(),
            getScript2(),
            getScript3(),
            getScript4(),
            getScript5(),
            getScript6(),
            getScript7(),
            getScript8(),
            getScript9()
        );
    }
}
