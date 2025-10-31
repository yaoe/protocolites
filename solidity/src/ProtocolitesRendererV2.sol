// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solady/utils/Base64.sol";
import "solady/utils/LibString.sol";
import "solady/auth/Ownable.sol";

import "./interfaces/IProtocolitesRenderer.sol";

/// @title ProtocolitesRendererV2
/// @notice DOM-based renderer with per-character animations and temperament system
contract ProtocolitesRendererV2 is Ownable, IProtocolitesRenderer {
    string public renderScript;

    constructor() {
        _initializeOwner(msg.sender);
        // Initialize with the default script
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

        string memory animation = string.concat(
            '<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">',
            "<title>Protocolite #",
            LibString.toString(tokenId),
            "</title>",
            '<style>@import url("https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@100;200;300;400&display=swap");',
            "*{margin:0;padding:0;box-sizing:border-box;}",
            "html,body{width:100%;height:100%;margin:0;padding:0;min-width:600px;min-height:600px;}",
            'body{font-family:"JetBrains Mono","Courier New",monospace;background:#fff;color:#000;line-height:1;font-size:12px;font-weight:200;display:flex;align-items:center;justify-content:center;overflow:hidden;}',
            ".container{text-align:center;padding:",
            isKid ? "20" : "30",
            "px;position:relative;}",
            ".creature-container{position:relative;display:inline-block;font-family:'Courier New',monospace;line-height:1;-webkit-font-smoothing:none;-moz-osx-font-smoothing:unset;font-smooth:never;text-rendering:optimizeSpeed;}",
            ".creature-char{position:absolute;font-family:'Courier New',monospace;white-space:pre;user-select:none;pointer-events:none;will-change:transform;}",
            "</style></head><body>",
            '<div class="container"><div class="creature-container" id="creature"></div></div>',
            "<script>",
            "const tokenId=",
            LibString.toString(tokenId),
            ";",
            'const dna="',
            LibString.toHexString(data.dna),
            '";',
            "const isKid=",
            isKid ? "true" : "false",
            ";",
            'const parentDna="',
            LibString.toHexString(data.parentDna),
            '";',
            "const size=",
            LibString.toString(size),
            ";",
            renderScript,
            "</script>",
            "</body></html>"
        );

        string memory attributes = string.concat(
            '[{"trait_type":"Type","value":"',
            isKid ? "Child" : "Spreader",
            '"},',
            '{"trait_type":"Size","value":"',
            LibString.toString(size),
            "x",
            LibString.toString(size),
            '"},',
            '{"trait_type":"DNA","value":"',
            LibString.toHexString(data.dna),
            '"},',
            '{"trait_type":"Birth Block","value":',
            LibString.toString(data.birthBlock),
            "}",
            isKid
                ? string.concat(',{"trait_type":"Parent DNA","value":"', LibString.toHexString(data.parentDna), '"}')
                : "",
            "]"
        );

        string memory json = string.concat(
            '{"name":"Protocolite #',
            LibString.toString(tokenId),
            isKid ? " (Child)" : " (Spreader)",
            '",',
            '"description":"Fully on-chain generative ASCII art with DOM-based rendering and per-character animations.",',
            '"animation_url":"data:text/html;base64,',
            Base64.encode(bytes(animation)),
            '",',
            '"attributes":',
            attributes,
            "}"
        );

        return json;
    }

    function getScript1() private pure returns (string memory) {
        return string.concat(
            "function hashCode(s){let h=0;for(let i=0;i<s.length;i++){h=((h<<5)-h)+s.charCodeAt(i);h&=h;}return Math.abs(h);}",
            'const families={red:"#cc0000",green:"#008800",blue:"#0044cc",yellow:"#cc9900",purple:"#8800cc",cyan:"#0088aa"};',
            "function getFamilyFromDNA(d){const b=BigInt(d);const f=b>>17n;const h=Number(f%16777216n);const k=Object.keys(families);return k[h%k.length];}",
            "const family=getFamilyFromDNA(dna);",
            "const familyColor=families[family];",
            "let seed=hashCode(dna);",
            "function random(){seed=(seed*9301+49297)%233280;return seed/233280;}"
        );
    }

    function getScript2() private pure returns (string memory) {
        return string.concat(
            "function decodeDNA(d){",
            "const n=BigInt(d);",
            'const bt=["square","round","diamond","mushroom","invader","ghost"];',
            'const bc=["\\u2588","\\u2593","\\u2592","\\u2591"];',
            'const ec=["\\u25cf","\\u25c9","\\u25ce","\\u25cb"];',
            'const at=["\\u25cf","\\u25c9","\\u25cb","\\u25ce","\\u2726","\\u2727","\\u2605"];',
            'const ht=["none","top","flat","double","fancy"];',
            "return{",
            "bodyType:bt[Number((n>>0n)&7n)%6],",
            "bodyChar:bc[Number((n>>3n)&3n)],",
            "eyeChar:ec[Number((n>>5n)&3n)],",
            'eyeSize:Number((n>>7n)&1n)===1?"mega":"normal",',
            "antennaTip:at[Number((n>>8n)&7n)%7],",
            'armStyle:Number((n>>11n)&1n)===1?"line":"block",',
            'legStyle:Number((n>>12n)&1n)===1?"line":"block",',
            "hatType:ht[Number((n>>13n)&7n)%5],",
            "hasCigarette:Number((n>>16n)&1n)===1};}",
            "const dnaObj=decodeDNA(dna);"
        );
    }

    function getScript3() private pure returns (string memory) {
        return string.concat(
            'const grid=Array(size).fill().map(()=>Array(size).fill(null).map(()=>({char:" ",type:"empty"})));',
            "const cx=Math.floor(size/2);",
            "const cy=Math.floor(size/2);",
            "const bodyType=dnaObj.bodyType;",
            "const bodyWidth=size===24?6:3;",
            "const bodyHeight=size===24?8:4;",
            "const bodyStartY=size===24?7:6;"
        );
    }

    function getScript4() private pure returns (string memory) {
        return string.concat(
            "for(let y=0;y<bodyHeight;y++){",
            "for(let x=-bodyWidth;x<=bodyWidth;x++){",
            "const posY=bodyStartY+y;",
            "const posX=cx+x;",
            "let inBody=false;",
            "const relX=x/bodyWidth;",
            "const relY=(y-bodyHeight/2)/(bodyHeight/2);",
            'if(bodyType==="square"){inBody=true;}',
            'else if(bodyType==="round"){const dist=Math.sqrt(relX*relX+relY*relY);inBody=dist<=1.0;}',
            'else if(bodyType==="diamond"){inBody=Math.abs(relX)+Math.abs(relY)<=1.0;}',
            'else if(bodyType==="mushroom"){',
            "if(isKid){if(relY<-0.2){inBody=true;}else{inBody=Math.abs(relX)<=0.7;}}",
            "else{if(relY<0){inBody=true;}else{inBody=Math.abs(relX)<=0.6;}}}",
            'else if(bodyType==="invader"){',
            "if(relY<-0.3){inBody=Math.abs(relX)<=0.7;}",
            "else if(relY<0.3){inBody=true;}",
            "else{inBody=Math.abs(relX)<=0.85;}}",
            'else if(bodyType==="ghost"){',
            "const distGhost=Math.sqrt(relX*relX+relY*relY);",
            "if(relY<0.5){inBody=distGhost<=1.0;}",
            "else{inBody=Math.abs(relX)<=0.9&&(Math.floor(x+bodyWidth)%2===0||relY<0.8);}}",
            "if(inBody&&posX>=0&&posX<size&&posY>=0&&posY<size){grid[posY][posX]={char:dnaObj.bodyChar,type:'body'};}}}",
            'const isBodyChar=c=>c&&c.type==="body";'
        );
    }

    function getScript5() private pure returns (string memory) {
        return string.concat(
            "const eyeY=bodyStartY+1;",
            "if(isKid){",
            "const eyeCount=1+Math.floor(random()*3);",
            "if(eyeCount===1){",
            "for(let dy=0;dy<2;dy++){for(let dx=-1;dx<=1;dx++){if(isBodyChar(grid[eyeY+dy][cx+dx])){grid[eyeY+dy][cx+dx]={char:' ',type:'empty'};}}}",
            "grid[eyeY][cx-1]={char:dnaObj.bodyChar,type:'body'};grid[eyeY][cx]={char:dnaObj.eyeChar,type:'eye'};grid[eyeY][cx+1]={char:dnaObj.bodyChar,type:'body'};grid[eyeY+1][cx]={char:dnaObj.bodyChar,type:'body'};}",
            "else if(eyeCount===2){",
            "const eyeSpacing=1;",
            "for(let dy=0;dy<2;dy++){for(let dx=0;dx<2;dx++){",
            "if(isBodyChar(grid[eyeY+dy][cx-eyeSpacing-1+dx])){grid[eyeY+dy][cx-eyeSpacing-1+dx]={char:' ',type:'empty'};}",
            "if(isBodyChar(grid[eyeY+dy][cx+eyeSpacing+dx])){grid[eyeY+dy][cx+eyeSpacing+dx]={char:' ',type:'empty'};}}}",
            "grid[eyeY][cx-eyeSpacing-1]={char:dnaObj.bodyChar,type:'body'};grid[eyeY][cx-eyeSpacing]={char:dnaObj.eyeChar,type:'eye'};",
            "grid[eyeY+1][cx-eyeSpacing-1]={char:dnaObj.bodyChar,type:'body'};grid[eyeY+1][cx-eyeSpacing]={char:dnaObj.bodyChar,type:'body'};",
            "grid[eyeY][cx+eyeSpacing]={char:dnaObj.eyeChar,type:'eye'};grid[eyeY][cx+eyeSpacing+1]={char:dnaObj.bodyChar,type:'body'};",
            "grid[eyeY+1][cx+eyeSpacing]={char:dnaObj.bodyChar,type:'body'};grid[eyeY+1][cx+eyeSpacing+1]={char:dnaObj.bodyChar,type:'body'};}",
            'else{for(let dx of[-2,0,2]){if(isBodyChar(grid[eyeY][cx+dx]))grid[eyeY][cx+dx]={char:\' \',type:\'empty\'};grid[eyeY][cx+dx]={char:dnaObj.eyeChar,type:\'eye\'};}}}',
            "else{"
        );
    }

    function getScript6() private pure returns (string memory) {
        return string.concat(
            "const eyeCount=1+Math.floor(random()*3);",
            "if(eyeCount===1){",
            "for(let dy=0;dy<3;dy++){for(let dx=-2;dx<=2;dx++){if(isBodyChar(grid[eyeY+dy][cx+dx])){grid[eyeY+dy][cx+dx]={char:' ',type:'empty'};}}}",
            "for(let dx=-2;dx<=2;dx++){grid[eyeY][cx+dx]={char:dnaObj.bodyChar,type:'body'};grid[eyeY+2][cx+dx]={char:dnaObj.bodyChar,type:'body'};}",
            "grid[eyeY+1][cx-2]={char:dnaObj.bodyChar,type:'body'};grid[eyeY+1][cx-1]={char:dnaObj.eyeChar,type:'eye'};",
            "grid[eyeY+1][cx]={char:dnaObj.eyeChar,type:'eye'};grid[eyeY+1][cx+1]={char:dnaObj.eyeChar,type:'eye'};grid[eyeY+1][cx+2]={char:dnaObj.bodyChar,type:'body'};}",
            "else if(eyeCount===2){",
            "const blockSpacing=2;",
            "for(let dy=0;dy<3;dy++){for(let dx=0;dx<3;dx++){",
            "if(isBodyChar(grid[eyeY+dy][cx-blockSpacing-2+dx])){grid[eyeY+dy][cx-blockSpacing-2+dx]={char:' ',type:'empty'};}",
            "if(isBodyChar(grid[eyeY+dy][cx+blockSpacing+dx])){grid[eyeY+dy][cx+blockSpacing+dx]={char:' ',type:'empty'};}}}",
            "for(let dy=0;dy<3;dy++){for(let dx=0;dx<3;dx++){",
            "const isCenter=dy===1&&dx===1;",
            "grid[eyeY+dy][cx-blockSpacing-2+dx]={char:isCenter?dnaObj.eyeChar:dnaObj.bodyChar,type:isCenter?'eye':'body'};",
            "grid[eyeY+dy][cx+blockSpacing+dx]={char:isCenter?dnaObj.eyeChar:dnaObj.bodyChar,type:isCenter?'eye':'body'};}}}",
            "else{for(let i=-3;i<=3;i+=3){for(let dy=0;dy<2;dy++){",
            "if(isBodyChar(grid[eyeY+dy][cx+i]))grid[eyeY+dy][cx+i]={char:' ',type:'empty'};",
            "if(isBodyChar(grid[eyeY+dy][cx+i-1]))grid[eyeY+dy][cx+i-1]={char:' ',type:'empty'};",
            "grid[eyeY+dy][cx+i]={char:dnaObj.eyeChar,type:'eye'};grid[eyeY+dy][cx+i-1]={char:dnaObj.eyeChar,type:'eye'};}}}}"
        );
    }

    function getScript7() private pure returns (string memory) {
        return string.concat(
            "if(random()>0.3){",
            "const mouthY=eyeY+(isKid?2:3);",
            "if(mouthY<size&&isBodyChar(grid[mouthY][cx])){",
            'grid[mouthY][cx]={char:"\\u2500",type:\'mouth\'};',
            'if(random()>0.5&&isBodyChar(grid[mouthY][cx-1])){grid[mouthY][cx-1]={char:"\\u2500",type:\'mouth\'};}',
            'if(random()>0.5&&isBodyChar(grid[mouthY][cx+1])){grid[mouthY][cx+1]={char:"\\u2500",type:\'mouth\'};}}}',
            "if(dnaObj.hasCigarette){",
            "const cigY=eyeY+(isKid?2:3);",
            'const cigChars=["\\u2248","\\u223c","~"];',
            "const cigChar=cigChars[Math.floor(random()*cigChars.length)];",
            "const cigX=cx+(random()>0.5?3:-3);",
            "if(cigX>=0&&cigX<size&&cigY>=0&&cigY<size){grid[cigY][cigX]={char:cigChar,type:'cigarette'};if(cigX+1<size)grid[cigY][cigX+1]={char:'\\u2219',type:'cigarette'};}}"
        );
    }

    function getScript8() private pure returns (string memory) {
        return string.concat(
            "const armCount=1+Math.floor(random()*4);",
            "const armLength=isKid?(1+Math.floor(random()*2)):(2+Math.floor(random()*4));",
            'const armChar=dnaObj.armStyle==="block"?"\\u2588":"\\u2500";',
            "for(let a=0;a<armCount;a++){",
            "const currentArmY=bodyStartY+2+a*(isKid?1:2);",
            "if(currentArmY>=bodyStartY+bodyHeight)break;",
            "let leftBodyEdge=cx,rightBodyEdge=cx;",
            "for(let x=cx;x>=0;x--){if(isBodyChar(grid[currentArmY][x])){leftBodyEdge=x;}else{break;}}",
            "for(let x=cx;x<size;x++){if(isBodyChar(grid[currentArmY][x])){rightBodyEdge=x;}else{break;}}",
            "for(let i=1;i<=armLength;i++){",
            "if(leftBodyEdge-i>=0){grid[currentArmY][leftBodyEdge-i]={char:armChar,type:'arm'};}",
            "if(rightBodyEdge+i<size){grid[currentArmY][rightBodyEdge+i]={char:armChar,type:'arm'};}}}"
        );
    }

    function getScript9() private pure returns (string memory) {
        return string.concat(
            "const legCount=1+Math.floor(random()*4);",
            "const legY=bodyStartY+bodyHeight;",
            "const legLength=isKid?(1+Math.floor(random()*2)):(2+Math.floor(random()*3));",
            'const legChar=dnaObj.legStyle==="block"?"\\u2588":"\\u2502";',
            "const bodyBottomPositions=[];",
            "for(let x=0;x<size;x++){if(grid[legY-1]&&isBodyChar(grid[legY-1][x])){bodyBottomPositions.push(x);}}",
            "const legPositions=[];",
            "if(bodyBottomPositions.length>0){",
            "if(legCount===1){legPositions.push(bodyBottomPositions[Math.floor(bodyBottomPositions.length/2)]);}",
            "else if(legCount===2){",
            "legPositions.push(bodyBottomPositions[Math.floor(bodyBottomPositions.length*0.25)]);",
            "legPositions.push(bodyBottomPositions[Math.floor(bodyBottomPositions.length*0.75)]);}",
            "else if(legCount===3){",
            "legPositions.push(bodyBottomPositions[0]);",
            "legPositions.push(bodyBottomPositions[Math.floor(bodyBottomPositions.length/2)]);",
            "legPositions.push(bodyBottomPositions[bodyBottomPositions.length-1]);}",
            "else{",
            "legPositions.push(bodyBottomPositions[0]);",
            "legPositions.push(bodyBottomPositions[Math.floor(bodyBottomPositions.length*0.33)]);",
            "legPositions.push(bodyBottomPositions[Math.floor(bodyBottomPositions.length*0.66)]);",
            "legPositions.push(bodyBottomPositions[bodyBottomPositions.length-1]);}}",
            "for(let legX of legPositions){if(legX>=0&&legX<size){for(let i=0;i<legLength;i++){if(legY+i<size){grid[legY+i][legX]={char:legChar,type:'leg'};}}}}"
        );
    }

    function getScript10() private pure returns (string memory) {
        return string.concat(
            "const antennaCount=1+Math.floor(random()*4);",
            "const antennaLength=isKid?1:(1+Math.floor(random()*2));",
            "const bodyTopPositions=[];",
            "for(let x=0;x<size;x++){if(grid[bodyStartY]&&isBodyChar(grid[bodyStartY][x])){bodyTopPositions.push(x);}}",
            "const antennaPositions=[];",
            "if(bodyTopPositions.length>0){",
            "if(antennaCount===1){antennaPositions.push(bodyTopPositions[Math.floor(bodyTopPositions.length/2)]);}",
            "else if(antennaCount===2){",
            "antennaPositions.push(bodyTopPositions[Math.floor(bodyTopPositions.length*0.25)]);",
            "antennaPositions.push(bodyTopPositions[Math.floor(bodyTopPositions.length*0.75)]);}",
            "else if(antennaCount===3){",
            "antennaPositions.push(bodyTopPositions[0]);",
            "antennaPositions.push(bodyTopPositions[Math.floor(bodyTopPositions.length/2)]);",
            "antennaPositions.push(bodyTopPositions[bodyTopPositions.length-1]);}",
            "else{",
            "antennaPositions.push(bodyTopPositions[0]);",
            "antennaPositions.push(bodyTopPositions[Math.floor(bodyTopPositions.length*0.33)]);",
            "antennaPositions.push(bodyTopPositions[Math.floor(bodyTopPositions.length*0.66)]);",
            "antennaPositions.push(bodyTopPositions[bodyTopPositions.length-1]);}}",
            "for(let antennaX of antennaPositions){for(let i=1;i<=antennaLength;i++){",
            "const antennaY=bodyStartY-i;",
            "if(antennaY>=0){grid[antennaY][antennaX]={char:i===antennaLength?dnaObj.antennaTip:'\\u2502',type:i===antennaLength?'antenna-tip':'antenna'};}}}"
        );
    }

    function getScript11() private pure returns (string memory) {
        return string.concat(
            'if(dnaObj.hatType&&dnaObj.hatType!=="none"){',
            "const hatY=bodyStartY-antennaLength-1;",
            "if(hatY>=0){",
            'if(dnaObj.hatType==="top"){',
            'for(let dx=-2;dx<=2;dx++){if(cx+dx>=0&&cx+dx<size){grid[hatY][cx+dx]={char:"\\u2580",type:\'hat\'};}}',
            'if(hatY+1<size){grid[hatY+1][cx]={char:"\\u2588",type:\'hat\'};}}',
            'else if(dnaObj.hatType==="flat"){for(let dx=-2;dx<=2;dx++){if(cx+dx>=0&&cx+dx<size){grid[hatY][cx+dx]={char:"\\u2550",type:\'hat\'};}}}',
            'else if(dnaObj.hatType==="double"){',
            'for(let dx=-2;dx<=2;dx++){if(cx+dx>=0&&cx+dx<size&&hatY-1>=0){grid[hatY-1][cx+dx]={char:"\\u2580",type:\'hat\'};grid[hatY][cx+dx]={char:"\\u2584",type:\'hat\'};}}}',
            'else if(dnaObj.hatType==="fancy"){',
            "if(cx-2>=0&&cx+2<size){",
            'grid[hatY][cx-2]={char:"\\u2554",type:\'hat\'};grid[hatY][cx-1]={char:"\\u2550",type:\'hat\'};grid[hatY][cx]={char:"\\u2550",type:\'hat\'};',
            'grid[hatY][cx+1]={char:"\\u2550",type:\'hat\'};grid[hatY][cx+2]={char:"\\u2557",type:\'hat\'};}}}}'
        );
    }

    function getScript12() private pure returns (string memory) {
        return string.concat(
            "const container=document.getElementById('creature');",
            "const fontSize=size===24?20:16;",
            "const charWidth=fontSize*0.6;",
            "const lineHeight=fontSize;",
            "container.style.width=size*charWidth+'px';",
            "container.style.height=size*lineHeight+'px';",
            "container.style.fontSize=fontSize+'px';",
            "const charElements=[];",
            "for(let y=0;y<size;y++){for(let x=0;x<size;x++){",
            "const cell=grid[y][x];",
            "if(!cell||cell.char===' ')continue;",
            "const span=document.createElement('span');",
            "span.className='creature-char';",
            "span.textContent=cell.char;",
            "span.style.left=x*charWidth+'px';",
            "span.style.top=y*lineHeight+'px';",
            "span.style.color=familyColor;",
            "container.appendChild(span);",
            "charElements.push({element:span,originalChar:cell.char,type:cell.type,x:x,y:y,baseX:x*charWidth,baseY:y*lineHeight});}}"
        );
    }

    function getScript13() private pure returns (string memory) {
        return string.concat(
            "let time=0;",
            "const tempNames=['calm','balanced','energetic','chaotic','glitchy','unstable'];",
            "const tempWeights=[35,30,20,10,4,1];",
            "const tempSpeeds=[1.5,2.5,3.5,5.0,6.0,7.0];",
            "const tempGlitch=[0.02,0.05,0.12,0.25,0.40,0.60];",
            "const tempCorrupt=[0.0,0.0,0.03,0.08,0.15,0.25];",
            "const totalWeight=tempWeights.reduce((s,w)=>s+w,0);",
            "let r=random()*totalWeight;",
            "let tempIndex=0;",
            "for(let i=0;i<tempWeights.length;i++){r-=tempWeights[i];if(r<=0){tempIndex=i;break;}}",
            "const temperament=tempNames[tempIndex];",
            "const speed=tempSpeeds[tempIndex];",
            "const glitchChance=tempGlitch[tempIndex];",
            "const charCorrupt=tempCorrupt[tempIndex];",
            'const corruptChars=["\\u2588","\\u2593","\\u2592","\\u2591","\\u2580","\\u2584","\\u25a0","\\u25a1","\\u25aa","\\u25ab"];',
            "const energetic=temperament==='energetic';",
            "const chaotic=temperament==='chaotic';",
            "const glitchy=temperament==='glitchy';",
            "const unstable=temperament==='unstable';"
        );
    }

    function getScript14() private pure returns (string memory) {
        return string.concat(
            "function animate(){",
            "time+=speed*0.016;",
            "const isGlitching=Math.random()<glitchChance;",
            "const rowOffsets=new Array(size).fill(0);",
            "if(isGlitching&&(chaotic||glitchy||unstable)){for(let y=0;y<size;y++){if(Math.random()<0.1){rowOffsets[y]=(Math.random()-0.5)*6;}}}",
            "for(const cd of charElements){",
            "const{element,originalChar,type,x,y,baseX,baseY}=cd;",
            "let char=originalChar;",
            "let offsetX=0;",
            "let offsetY=0;",
            "let rotation=0;",
            "let scale=1;",
            "if(isGlitching&&Math.random()<charCorrupt){char=corruptChars[Math.floor(Math.random()*corruptChars.length)];}",
            "if(type==='body'){offsetY+=Math.sin(time+x*0.1)*2;}",
            "else if(type==='eye'){if(Math.sin(time*0.5)<-0.95){char='\\u2500';}if(energetic||chaotic||glitchy||unstable){offsetX+=Math.sin(time*2+y)*1.5;}}",
            "else if(type==='arm'){offsetY+=Math.sin(time*1.5+y*0.5)*3;if(chaotic||glitchy||unstable){offsetX+=Math.cos(time*2+x)*2;}}",
            "else if(type==='leg'){offsetY+=Math.sin(time*2+x*1.5)*2;}",
            "else if(type==='antenna'||type==='antenna-tip'){offsetX+=Math.sin(time+x*0.3)*2;if(type==='antenna-tip'){rotation=Math.sin(time*0.8)*0.3;}}",
            "else if(type==='mouth'){if(Math.sin(time*0.7)>0.7&&(energetic||chaotic||glitchy||unstable)){char='\\u25cb';}}"
        );
    }

    function getScript15() private pure returns (string memory) {
        return string.concat(
            "if(isGlitching){const glitchMult=unstable?4:glitchy?3:chaotic?2:energetic?1.5:1;offsetX+=(Math.random()-0.5)*glitchMult;offsetY+=(Math.random()-0.5)*glitchMult;}",
            "offsetX+=rowOffsets[y];",
            "if(isGlitching&&unstable&&Math.random()<0.1){scale=0.8+Math.random()*0.4;rotation+=(Math.random()-0.5)*0.3;}",
            "let color=familyColor;",
            "if(isGlitching&&(chaotic||glitchy||unstable)){const colors=['#ff0000','#00ff00','#0000ff',familyColor];color=colors[Math.floor(Math.random()*colors.length)];}",
            "element.textContent=char;",
            "element.style.color=color;",
            "const transforms=[];",
            "if(offsetX!==0||offsetY!==0){transforms.push('translate('+offsetX.toFixed(2)+'px,'+offsetY.toFixed(2)+'px)');}",
            "if(rotation!==0){transforms.push('rotate('+rotation+'rad)');}",
            "if(scale!==1){transforms.push('scale('+scale+')');}",
            "element.style.transform=transforms.length>0?transforms.join(' '):'none';}",
            "requestAnimationFrame(animate);}",
            "animate();"
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
            getScript9(),
            getScript10(),
            getScript11(),
            getScript12(),
            getScript13(),
            getScript14(),
            getScript15()
        );
    }
}
