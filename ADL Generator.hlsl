static const float adl = 0.001; // set ADL (0.5 means 50 %)
static const float adlMax = 0.5; // set maximum possible ADL (defines the size of the square)


float4 p0 : register(c0);
#define width  (p0[0])
#define height (p0[1])

// calculates the value for each pixel
// pixel that are not completely inside the bar get a value corresponding to their intersection
float CalcValue(float uv, float2 bar, float sizePixel, float widthBar)
{
	float weight = 0;
	
	if(uv < bar.x + sizePixel.x && uv + sizePixel.x > bar.y) // width of bar is smaller than ony pixel
		weight = widthBar / sizePixel;
	else if(uv < bar.x + sizePixel) // pixel is partly covered by bar and extends first border
		weight = (uv.x - bar.x) / sizePixel;
	else if(uv + sizePixel.x > bar.y) // pixel is partly covered by bar and extends second border
		weight = (bar.y - uv) / sizePixel;
	else // pixel is completely inside bar
		weight = 1.0;
		
	return pow(weight, 1 / 2.2);
}

float4 main(float2 uv : TEXCOORD0) : COLOR
{
	float3 result = float3(0, 0, 0);
	float lengthInnerHalf = sqrt(1.0 - adlMax) / 2.0; // half of the inner square (which is always black)
	float lengthOuterHalf = sqrt(adl + 1.0 - adlMax) / 2.0; // AOuter = a * b - AInner with a = b
	float widthBar = lengthInnerHalf - lengthOuterHalf;	// width of the bar (outer square - inner square)
	float2 sizePixel = float2(1.0 / width, 1.0 / height); // widht of a pixel
	float2 barLeft = float2(0.5 - lengthOuterHalf - sizePixel.x, 0.5 - lengthInnerHalf); // left bar of the square
	float2 barRight = float2(0.5 + lengthInnerHalf - sizePixel.x, 0.5 + lengthOuterHalf); // right bar of the square
	float2 barTop = float2(0.5 - lengthOuterHalf - sizePixel.y, 0.5 - lengthInnerHalf); // top bar of the square
	float2 barBottom = float2(0.5 + lengthInnerHalf - sizePixel.y, 0.5 + lengthOuterHalf); // bnottom bar of the square
	float value = 0;
	
	uv -= sizePixel / 2; // set coordinates to left top of a pixel

	if(uv.x > barLeft.x && uv.x < barLeft.y && uv.y > barTop.x && uv.y < barBottom.y)
		value = CalcValue(uv.x, barLeft, sizePixel.x, widthBar);
	else if(uv.x > barRight.x && uv.x < barRight.y && uv.y > barTop.x && uv.y < barBottom.y)
		value = CalcValue(uv.x, barRight, sizePixel.x, widthBar);
	else if(uv.y > barTop.x && uv.y < barTop.y && uv.x > barLeft.x && uv.x < barRight.y)
		value = CalcValue(uv.y, barTop, sizePixel.y, widthBar);
	else if(uv.y > barBottom.x && uv.y < barBottom.y && uv.x > barLeft.x && uv.x < barRight.y)
		value = CalcValue(uv.y, barBottom, sizePixel.y, widthBar);
	
	return float4(value, value, value, 1.0);
}
