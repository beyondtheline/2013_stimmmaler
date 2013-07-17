// Modified Metaball2D into this!!! -gilbi

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------



// transforms
float4x4 tW: WORLD;       
float4x4 tV: VIEW;        
float4x4 tP: PROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;

float defaultdistance = 1;
float4 color : COLOR = 0;

float tresh <string uiname="treshold";> =4.;
float offset   <string uiname="offset";> =5.;

int numBlobs <string uiname="numBlobs (binSize*bins)";> = 8;
int binSize = 4;
int bins = 2;

bool enableMaskTexture=false;
bool enableColorTexture=false;
float colorMultiplier = 0.5;
float colorMultiplierSpan = 0.3;

//texture
texture posTex <string uiname="Position Texture";>;
sampler posSamp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (posTex);          //apply a texture to the sampler
    MipFilter = POINT;         //sampler states
    MinFilter = POINT;
    MagFilter = POINT;
};

texture maskTex <string uiname="Mask Texture";>;
sampler maskSamp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (maskTex);          //apply a texture to the sampler
    MipFilter = POINT;         //sampler states
    MinFilter = POINT;
    MagFilter = POINT;
};

texture colorTex <string uiname="Color Texture";>;
sampler colorSamp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (colorTex);          //apply a texture to the sampler
    MipFilter = POINT;         //sampler states
    MinFilter = POINT;
    MagFilter = POINT;
};


    
 

struct vs2ps
{
    float4 Pos  : POSITION;
    float2 TexCd : TEXCOORD0;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS( float4 PosO  : POSITION, float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //transform position
    Out.Pos = mul(PosO, tWVP);
    
    //texturecoordinates
    Out.TexCd = TexCd;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 drip(vs2ps In): COLOR
{
	int closest = 0;
    float d = 0.;
	float dd = 9999999;
    float sum = 0.;
	float v = 0;
	float vv = 9999999;
	float ymin=0;
	float ymax=0;
	float yymin=0;
	float yymax=0;
	float4 b;
	float4 cc=color;
	float4 ccc=0;
	//float4 a;
	float4 dsum=0;
	
	/*for (int j=0; j<bins; j++) {
		int i = j*binSize;
		b = tex2D(posSamp, float2((float)i/(float)numBlobs, 0.));
		d = distance(In.TexCd.x, b.x);
		if (d<dd) {
			dd = d;
			closest = i;
		}
	}*/
	
   // for (int i=closest; i<closest+binSize; i++) {
    //int end = closest;
	//for (int i=closest; i<end; i++) {
	//float4 mcolor=0;
	//if (enableMaskTexture) {
	//	mcolor = tex2D(maskSamp, In.TexCd);
	//}
	
	//if (! enableMaskTexture || mcolor.a>=1) {
	//for (int j=0; j<binSize; j++) {
	int bin;
	int offset;
	for (int i=0; i<numBlobs; i++) {
		//int i = closest+j;
		bin = floor(i/binSize);
		offset = i % binSize;
		
		b = tex2D(posSamp, float2((float)i/(float)numBlobs, 0.));
		d=distance(In.TexCd, b.xy) / defaultdistance;
		sum+=b.z/(d*d);
		
		if (enableColorTexture) {
			float4 mycc =  tex2D(colorSamp, float2((float)i/(float)numBlobs, 0.));
			//c += (cc/(d+d));
			dsum += d;
			cc += mycc*d;
		}// else if 
		
		v = 2*d*abs(In.TexCd.x - b.x)/b.b;
		vv = v<vv ? v : vv;
		
		if (b.y<ymin || offset==0) ymin = b.y;
		if (b.y>ymax || offset==0) ymax = b.y;
		
		if (offset == binSize-1) {
			if (enableMaskTexture) {
		    	cc = tex2D(maskSamp, float2(b.x, ymin));
		    	if (cc.a<1) cc = 0;
		    }
		    //if (vir<.35 && In.TexCd.y>ymin && In.TexCd.y<ymax) {
		    if (! enableMaskTexture || (enableMaskTexture && cc.a>0)) {
			    if (enableColorTexture) cc /= dsum;
			    if ( In.TexCd.y>ymin && In.TexCd.y<ymax) {
			    	cc.a = .09/vv/tresh-offset*.6;
			    } else {
			    	cc.a = (sum/tresh )-offset;
			    }
			}
			
			//ccc = cc.a>ccc.a?cc:ccc;
			if (cc.a>ccc.a) {
				ccc = cc;
				yymin = ymin;
				yymax = ymax;
			}
			
			
		    sum = 0;
			vv = 9999999;
			cc=color;
			dsum=0;
		}
		
    }
    
	//float cm = 1-colorMultiplier*(In.TexCd.y-yymin)/(yymax-yymin);
	float cm = 1-colorMultiplier*(In.TexCd.y-yymin)/(colorMultiplierSpan);
    ccc.r *= cm;
    ccc.g *= cm;
    ccc.b *= cm;
    
    return ccc;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique dripping
{
    pass P0
    {
        VertexShader = compile vs_3_0 VS();
        PixelShader  = compile ps_3_0 drip();
    }
}
