// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solady/utils/Base64.sol";
import "solady/utils/LibString.sol";
import "solady/auth/Ownable.sol";

import "./Protocolites.sol";


contract ProtocolitesRenderASCII is Ownable {

    string public renderScript;

    constructor() {
        _initializeOwner(msg.sender);
        // Initialize with the default script
        renderScript = defaultScript();
    }

    function setRenderScript(string memory _script) external onlyOwner {
        renderScript = _script;
    }

    function tokenURI(uint256 tokenId, Protocolites.TokenData memory data) external view returns (string memory) {
        return string.concat("data:application/json;base64,", Base64.encode(bytes(metadata(tokenId, data))));
    }

    function metadata(uint256 tokenId, Protocolites.TokenData memory data) public view returns (string memory) {
        bool isKid = data.isKid;
        uint256 size = isKid ? 16 : 24;

        string memory animation = string.concat(
            '<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">',
            '<title>Protocolite #', LibString.toString(tokenId), '</title>',
            '<style>@import url("https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@100;200;300;400&display=swap");',
            '*{margin:0;padding:0;box-sizing:border-box;}',
            'html,body{width:100%;height:100%;margin:0;padding:0;}',
            'body{font-family:"JetBrains Mono","Courier New",monospace;background:#fff;color:#000;line-height:1;font-size:12px;font-weight:200;display:flex;align-items:center;justify-content:center;overflow:hidden;}',
            '.container{text-align:center;padding:20px;}',
            '.ascii-display{font-family:"Courier New",monospace;font-size:', isKid ? '10' : '14', 'px;line-height:', isKid ? '10' : '14', 'px;letter-spacing:0;white-space:pre;margin:20px auto;color:#000;}',
            '.info{font-size:9px;color:#666;margin-top:15px;letter-spacing:0.1em;text-transform:uppercase;}',
            '</style></head><body>',
            '<div class="container">',
            '<div class="ascii-display" id="ascii"></div>',
            '</div>',
            '<script>',
            'const arborTokenId=', LibString.toString(tokenId), ';',
            'const dna="', LibString.toHexString(data.dna), '";',
            'const isKid=', isKid ? 'true' : 'false', ';',
            'const parentDna="', LibString.toHexString(data.parentDna), '";',
            'const size=', LibString.toString(size), ';',
            renderScript,
            '</script>',
            '</body></html>'
        );

        string memory attributes = string.concat(
            '[{"trait_type":"Type","value":"', isKid ? 'Child' : 'Spreader', '"},',
            '{"trait_type":"Size","value":"', LibString.toString(size), 'x', LibString.toString(size), '"},',
            '{"trait_type":"DNA","value":"', LibString.toHexString(data.dna), '"},',
            '{"trait_type":"Birth Block","value":', LibString.toString(data.birthBlock), '}',
            isKid ? string.concat(',{"trait_type":"Parent DNA","value":"', LibString.toHexString(data.parentDna), '"}') : '',
            ']'
        );

        string memory json = string.concat(
            '{"name":"Protocolite #', LibString.toString(tokenId),
            isKid ? ' (Child)' : ' (Spreader)',
            '",',
            '"description":"Fully on-chain generative ASCII art creatures with DNA inheritance. Spreaders can breed children that inherit traits with 80-100% probability.",',
            '"animation_url":"data:text/html;base64,',
            Base64.encode(bytes(animation)),
            '",',
            '"attributes":', attributes,
            '}'
        );

        return json;
    }

    function getScript1() private pure returns (string memory) {
        return string.concat(
            'function hashCode(s){let h=0;for(let i=0;i<s.length;i++){h=((h<<5)-h)+s.charCodeAt(i);h&=h;}return Math.abs(h);}',
            'const families={red:{class:"ascii-red",color:"#cc0000"},green:{class:"ascii-green",color:"#008800"},blue:{class:"ascii-blue",color:"#0044cc"},yellow:{class:"ascii-yellow",color:"#cc9900"},purple:{class:"ascii-purple",color:"#8800cc"},cyan:{class:"ascii-cyan",color:"#0088aa"}};',
            'function getFamilyFromDNA(dna){',
            'const bigIntDna=BigInt(dna);',
            'const familyBits=bigIntDna>>17n;',
            'const h=Number(familyBits%16777216n);',
            'const fams=Object.keys(families);',
            'return fams[h%fams.length];}',
            'const family=getFamilyFromDNA(dna);',
            'const familyColor=families[family].color;',
            'function random(){seed=(seed*9301+49297)%233280;return seed/233280;}',
            'let seed=hashCode(dna);'
        );
    }

    function getScript2() private pure returns (string memory) {
        return string.concat(
            'function decodeDNABits(dnaHex){',
            'const n=BigInt(dnaHex);',
            'const bodyTypes=["square","round","diamond","mushroom","invader","ghost"];',
            'const bodyChars=["\\u2588","\\u2593","\\u2592","\\u2591"];',
            'const eyeChars=["\\u25cf","\\u25c9","\\u25ce","\\u25cb"];',
            'const antennaTips=["\\u25cf","\\u25c9","\\u25cb","\\u25ce","\\u2726","\\u2727","\\u2605"];',
            'const hatTypes=["none","top","flat","double","fancy"];',
            'return{',
            'bodyType:bodyTypes[Number((n>>0n)&7n)%6],',
            'bodyChar:bodyChars[Number((n>>3n)&3n)],',
            'eyeChar:eyeChars[Number((n>>5n)&3n)],',
            'eyeSize:Number((n>>7n)&1n)===1?"mega":"normal",',
            'antennaTip:antennaTips[Number((n>>8n)&7n)%7],',
            'armStyle:Number((n>>11n)&1n)===1?"line":"block",',
            'legStyle:Number((n>>12n)&1n)===1?"line":"block",',
            'hatType:hatTypes[Number((n>>13n)&7n)%5],',
            'hasCigarette:Number((n>>16n)&1n)===1};}',
            'let parentDNA=null;',
            'if(isKid&&parentDna!=="0x0"){parentDNA=decodeDNABits(parentDna);}'
        );
    }

    function getScript3() private pure returns (string memory) {
        return string.concat(
            'const decoded=decodeDNABits(dna);',
            'const dnaObj={',
            'bodyType:decoded.bodyType,',
            'bodyChar:decoded.bodyChar,',
            'eyeChar:decoded.eyeChar,',
            'eyeSize:decoded.eyeSize,',
            'antennaTip:decoded.antennaTip,',
            'armStyle:decoded.armStyle,',
            'legStyle:decoded.legStyle,',
            'hatType:decoded.hatType,',
            'hasCigarette:decoded.hasCigarette};'
        );
    }

    function getScript4() private pure returns (string memory) {
        return string.concat(
            'const grid=Array(size).fill().map(()=>Array(size).fill(" "));',
            'const cx=Math.floor(size/2);',
            'const cy=Math.floor(size/2);'
        );
    }

    function getScript5() private pure returns (string memory) {
        return string.concat(
            'const bodyType=dnaObj.bodyType;',
            'const bodyWidth=size===24?6:3;',
            'const bodyHeight=size===24?8:4;',
            'const bodyStartY=size===24?7:6;',
            'for(let y=0;y<bodyHeight;y++){',
            'for(let x=-bodyWidth;x<=bodyWidth;x++){',
            'const posY=bodyStartY+y;',
            'const posX=cx+x;',
            'let inBody=false;',
            'const relX=x/bodyWidth;',
            'const relY=(y-bodyHeight/2)/(bodyHeight/2);',
            'if(bodyType==="square"){inBody=true;}',
            'else if(bodyType==="round"){const dist=Math.sqrt(relX*relX+relY*relY);inBody=dist<=1.0;}',
            'else if(bodyType==="diamond"){inBody=Math.abs(relX)+Math.abs(relY)<=1.0;}'
        );
    }

    function getScript6() private pure returns (string memory) {
        return string.concat(
            'else if(bodyType==="mushroom"){',
            'if(isKid){if(relY<-0.2){inBody=true;}else{inBody=Math.abs(relX)<=0.7;}}',
            'else{if(relY<0){inBody=true;}else{inBody=Math.abs(relX)<=0.6;}}}',
            'else if(bodyType==="invader"){',
            'if(relY<-0.3){inBody=Math.abs(relX)<=0.7;}',
            'else if(relY<0.3){inBody=true;}',
            'else{inBody=Math.abs(relX)<=0.85;}}',
            'else if(bodyType==="ghost"){',
            'const distGhost=Math.sqrt(relX*relX+relY*relY);',
            'if(relY<0.5){inBody=distGhost<=1.0;}',
            'else{inBody=Math.abs(relX)<=0.9&&(Math.floor(x+bodyWidth)%2===0||relY<0.8);}}',
            'if(inBody&&posX>=0&&posX<size&&posY>=0&&posY<size){grid[posY][posX]=dnaObj.bodyChar;}}}',
            'const isBodyChar=c=>["\\u2588","\\u2593","\\u2592","\\u2591"].includes(c);',
            'const eyeY=bodyStartY+1;',
            'const hasMegaEyes=dnaObj.eyeSize==="mega";'
        );
    }

    function getScript7() private pure returns (string memory) {
        return string.concat(
            'if(isKid){',
            'const eyeCount=1+Math.floor(random()*3);',
            'if(eyeCount===1){',
            'for(let dy=0;dy<2;dy++){for(let dx=-1;dx<=1;dx++){if(isBodyChar(grid[eyeY+dy][cx+dx])){grid[eyeY+dy][cx+dx]=" ";}}}',
            'grid[eyeY][cx-1]=dnaObj.bodyChar;grid[eyeY][cx]=dnaObj.eyeChar;grid[eyeY][cx+1]=dnaObj.bodyChar;grid[eyeY+1][cx]=dnaObj.bodyChar;}',
            'else if(eyeCount===2){',
            'const eyeSpacing=1;',
            'for(let dy=0;dy<2;dy++){for(let dx=0;dx<2;dx++){',
            'if(isBodyChar(grid[eyeY+dy][cx-eyeSpacing-1+dx])){grid[eyeY+dy][cx-eyeSpacing-1+dx]=" ";}',
            'if(isBodyChar(grid[eyeY+dy][cx+eyeSpacing+dx])){grid[eyeY+dy][cx+eyeSpacing+dx]=" ";}}}',
            'grid[eyeY][cx-eyeSpacing-1]=dnaObj.bodyChar;grid[eyeY][cx-eyeSpacing]=dnaObj.eyeChar;',
            'grid[eyeY+1][cx-eyeSpacing-1]=dnaObj.bodyChar;grid[eyeY+1][cx-eyeSpacing]=dnaObj.bodyChar;',
            'grid[eyeY][cx+eyeSpacing]=dnaObj.eyeChar;grid[eyeY][cx+eyeSpacing+1]=dnaObj.bodyChar;',
            'grid[eyeY+1][cx+eyeSpacing]=dnaObj.bodyChar;grid[eyeY+1][cx+eyeSpacing+1]=dnaObj.bodyChar;}',
            'else{for(let dx of[-2,0,2]){if(isBodyChar(grid[eyeY][cx+dx]))grid[eyeY][cx+dx]=" ";grid[eyeY][cx+dx]=dnaObj.eyeChar;}}}'
        );
    }

    function getScript8() private pure returns (string memory) {
        return string.concat(
            'else{',
            'const eyeCount=1+Math.floor(random()*3);',
            'if(eyeCount===1){',
            'for(let dy=0;dy<3;dy++){for(let dx=-2;dx<=2;dx++){if(isBodyChar(grid[eyeY+dy][cx+dx])){grid[eyeY+dy][cx+dx]=" ";}}}',
            'for(let dx=-2;dx<=2;dx++){grid[eyeY][cx+dx]=dnaObj.bodyChar;grid[eyeY+2][cx+dx]=dnaObj.bodyChar;}',
            'grid[eyeY+1][cx-2]=dnaObj.bodyChar;grid[eyeY+1][cx-1]=dnaObj.eyeChar;',
            'grid[eyeY+1][cx]=dnaObj.eyeChar;grid[eyeY+1][cx+1]=dnaObj.eyeChar;grid[eyeY+1][cx+2]=dnaObj.bodyChar;}',
            'else if(eyeCount===2){',
            'const blockSpacing=2;',
            'for(let dy=0;dy<3;dy++){for(let dx=0;dx<3;dx++){',
            'if(isBodyChar(grid[eyeY+dy][cx-blockSpacing-2+dx])){grid[eyeY+dy][cx-blockSpacing-2+dx]=" ";}',
            'if(isBodyChar(grid[eyeY+dy][cx+blockSpacing+dx])){grid[eyeY+dy][cx+blockSpacing+dx]=" ";}}}',
            'for(let dy=0;dy<3;dy++){for(let dx=0;dx<3;dx++){',
            'const isCenter=dy===1&&dx===1;',
            'grid[eyeY+dy][cx-blockSpacing-2+dx]=isCenter?dnaObj.eyeChar:dnaObj.bodyChar;',
            'grid[eyeY+dy][cx+blockSpacing+dx]=isCenter?dnaObj.eyeChar:dnaObj.bodyChar;}}}'
        );
    }

    function getScript9() private pure returns (string memory) {
        return string.concat(
            'else{for(let i=-3;i<=3;i+=3){for(let dy=0;dy<2;dy++){',
            'if(isBodyChar(grid[eyeY+dy][cx+i]))grid[eyeY+dy][cx+i]=" ";',
            'if(isBodyChar(grid[eyeY+dy][cx+i-1]))grid[eyeY+dy][cx+i-1]=" ";',
            'grid[eyeY+dy][cx+i]=dnaObj.eyeChar;grid[eyeY+dy][cx+i-1]=dnaObj.eyeChar;}}}}',
            'if(random()>0.3){',
            'const mouthY=eyeY+(isKid?2:3);',
            'if(mouthY<size&&isBodyChar(grid[mouthY][cx])){',
            'grid[mouthY][cx]="\\u2500";',
            'if(random()>0.5&&isBodyChar(grid[mouthY][cx-1])){grid[mouthY][cx-1]="\\u2500";}',
            'if(random()>0.5&&isBodyChar(grid[mouthY][cx+1])){grid[mouthY][cx+1]="\\u2500";}}}',
            'if(dnaObj.hasCigarette){',
            'const cigY=eyeY+(isKid?2:3);',
            'const cigChars=["\\u2248","\\u223c","~"];',
            'const cigChar=cigChars[Math.floor(random()*cigChars.length)];',
            'const cigX=cx+(random()>0.5?3:-3);',
            'if(cigX>=0&&cigX<size&&cigY>=0&&cigY<size){grid[cigY][cigX]=cigChar;if(cigX+1<size)grid[cigY][cigX+1]="\\u2219";}}'
        );
    }

    function getScript10() private pure returns (string memory) {
        return string.concat(
            'const armCount=1+Math.floor(random()*4);',
            'const armLength=isKid?(1+Math.floor(random()*2)):(2+Math.floor(random()*4));',
            'const armChar=dnaObj.armStyle==="block"?"\\u2588":"\\u2500";',
            'for(let a=0;a<armCount;a++){',
            'const currentArmY=bodyStartY+2+a*(isKid?1:2);',
            'if(currentArmY>=bodyStartY+bodyHeight)break;',
            'let leftBodyEdge=cx,rightBodyEdge=cx;',
            'for(let x=cx;x>=0;x--){if(isBodyChar(grid[currentArmY][x])){leftBodyEdge=x;}else{break;}}',
            'for(let x=cx;x<size;x++){if(isBodyChar(grid[currentArmY][x])){rightBodyEdge=x;}else{break;}}',
            'for(let i=1;i<=armLength;i++){',
            'if(leftBodyEdge-i>=0){grid[currentArmY][leftBodyEdge-i]=armChar;}',
            'if(rightBodyEdge+i<size){grid[currentArmY][rightBodyEdge+i]=armChar;}}}'
        );
    }

    function getScript11() private pure returns (string memory) {
        return string.concat(
            'const legCount=1+Math.floor(random()*4);',
            'const legY=bodyStartY+bodyHeight;',
            'const legLength=isKid?(1+Math.floor(random()*2)):(2+Math.floor(random()*3));',
            'const legChar=dnaObj.legStyle==="block"?"\\u2588":"\\u2502";',
            'const bodyBottomPositions=[];',
            'for(let x=0;x<size;x++){if(grid[legY-1]&&isBodyChar(grid[legY-1][x])){bodyBottomPositions.push(x);}}',
            'const legPositions=[];',
            'if(bodyBottomPositions.length>0){',
            'if(legCount===1){legPositions.push(bodyBottomPositions[Math.floor(bodyBottomPositions.length/2)]);}',
            'else if(legCount===2){',
            'legPositions.push(bodyBottomPositions[Math.floor(bodyBottomPositions.length*0.25)]);',
            'legPositions.push(bodyBottomPositions[Math.floor(bodyBottomPositions.length*0.75)]);}',
            'else if(legCount===3){',
            'legPositions.push(bodyBottomPositions[0]);',
            'legPositions.push(bodyBottomPositions[Math.floor(bodyBottomPositions.length/2)]);',
            'legPositions.push(bodyBottomPositions[bodyBottomPositions.length-1]);}'
        );
    }

    function getScript12() private pure returns (string memory) {
        return string.concat(
            'else{',
            'legPositions.push(bodyBottomPositions[0]);',
            'legPositions.push(bodyBottomPositions[Math.floor(bodyBottomPositions.length*0.33)]);',
            'legPositions.push(bodyBottomPositions[Math.floor(bodyBottomPositions.length*0.66)]);',
            'legPositions.push(bodyBottomPositions[bodyBottomPositions.length-1]);}}',
            'for(let legX of legPositions){if(legX>=0&&legX<size){for(let i=0;i<legLength;i++){if(legY+i<size){grid[legY+i][legX]=legChar;}}}}',
            'const antennaCount=1+Math.floor(random()*4);',
            'const antennaLength=isKid?1:(1+Math.floor(random()*2));',
            'const bodyTopPositions=[];',
            'for(let x=0;x<size;x++){if(grid[bodyStartY]&&isBodyChar(grid[bodyStartY][x])){bodyTopPositions.push(x);}}',
            'const antennaPositions=[];',
            'if(bodyTopPositions.length>0){',
            'if(antennaCount===1){antennaPositions.push(bodyTopPositions[Math.floor(bodyTopPositions.length/2)]);}',
            'else if(antennaCount===2){',
            'antennaPositions.push(bodyTopPositions[Math.floor(bodyTopPositions.length*0.25)]);',
            'antennaPositions.push(bodyTopPositions[Math.floor(bodyTopPositions.length*0.75)]);}'
        );
    }

    function getScript13() private pure returns (string memory) {
        return string.concat(
            'else if(antennaCount===3){',
            'antennaPositions.push(bodyTopPositions[0]);',
            'antennaPositions.push(bodyTopPositions[Math.floor(bodyTopPositions.length/2)]);',
            'antennaPositions.push(bodyTopPositions[bodyTopPositions.length-1]);}',
            'else{',
            'antennaPositions.push(bodyTopPositions[0]);',
            'antennaPositions.push(bodyTopPositions[Math.floor(bodyTopPositions.length*0.33)]);',
            'antennaPositions.push(bodyTopPositions[Math.floor(bodyTopPositions.length*0.66)]);',
            'antennaPositions.push(bodyTopPositions[bodyTopPositions.length-1]);}}',
            'for(let antennaX of antennaPositions){for(let i=1;i<=antennaLength;i++){',
            'const antennaY=bodyStartY-i;',
            'if(antennaY>=0){grid[antennaY][antennaX]=i===antennaLength?dnaObj.antennaTip:"\\u2502";}}}'
        );
    }

    function getScript14() private pure returns (string memory) {
        return string.concat(
            'if(dnaObj.hatType&&dnaObj.hatType!=="none"){',
            'const hatY=bodyStartY-antennaLength-1;',
            'if(hatY>=0){',
            'if(dnaObj.hatType==="top"){',
            'for(let dx=-2;dx<=2;dx++){if(cx+dx>=0&&cx+dx<size){grid[hatY][cx+dx]="\\u2580";}}',
            'if(hatY+1<size){grid[hatY+1][cx]="\\u2588";}}',
            'else if(dnaObj.hatType==="flat"){for(let dx=-2;dx<=2;dx++){if(cx+dx>=0&&cx+dx<size){grid[hatY][cx+dx]="\\u2550";}}}',
            'else if(dnaObj.hatType==="double"){',
            'for(let dx=-2;dx<=2;dx++){if(cx+dx>=0&&cx+dx<size&&hatY-1>=0){grid[hatY-1][cx+dx]="\\u2580";grid[hatY][cx+dx]="\\u2584";}}}',
            'else if(dnaObj.hatType==="fancy"){',
            'if(cx-2>=0&&cx+2<size){',
            'grid[hatY][cx-2]="\\u2554";grid[hatY][cx-1]="\\u2550";grid[hatY][cx]="\\u2550";',
            'grid[hatY][cx+1]="\\u2550";grid[hatY][cx+2]="\\u2557";}}}}',
            'const ascii=grid.map(row=>row.join("")).join("\\n");',
            'const style=document.createElement("style");',
            'style.textContent=".ascii-display{color:"+familyColor+"!important;}";',
            'document.head.appendChild(style);',
            'document.getElementById("ascii").textContent=ascii;'
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
            getScript14()
        );
    }
}
