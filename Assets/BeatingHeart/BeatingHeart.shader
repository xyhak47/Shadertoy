Shader "Shadertoy/BeatingHeart"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

	CGINCLUDE

	#include "UnityCG.cginc"

	sampler2D _MainTex;

	struct v2f
	{
		float4 pos : SV_POSITION;
		float4 srcPos : TEXCOORD0;      
	};

	v2f vert (appdata_base v)
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
 		o.srcPos = ComputeScreenPos(o.pos);     
		return o;
	}

	fixed4 frag (v2f i) : SV_Target
	{
		// 得到在屏幕中归一化后的屏幕位置，即返回分量范围在(0, 1)的屏幕横纵坐标值。
		float2 fragCoord = ((i.srcPos.xy / i.srcPos.w) * _ScreenParams.xy);

		// _ScreenParams: xy=屏幕的长宽，z=1+1/x，w=1+1/y,  


		/* 常用坐标变换技巧

		// pos.x ~ (0, _ScreenParams.x), pos.y ~ (0, _ScreenParams.y)  
		float2 pos = fragCoord; 

		// pos.x ~ (0, 1), pos.y ~ (0, 1)  
	    float2 pos = fragCoord.xy / _ScreenParams.xy; 

	    // If _ScreenParams.x > _ScreenParams.y, pos.x ~ (0, 1.xx), pos.y ~ (0, 1)  
	    float2 pos = fragCoord / min(_ScreenParams.x, _ScreenParams.y); 

	    // pos.x ~ (-1, 1), pos.y ~ (-1, 1)  
	    float2 pos = 2 * fragCoord.xy / _ScreenParams.xy. - 1.; 

	    // If _ScreenParams.x > _ScreenParams.y, pos.x ~ (-1.xx, 1.xx), pos.y ~ (-1, 1)  
	    float2 pos = (2 * fragCoord.xy-_ScreenParams.xy)/min(_ScreenParams.x,_ScreenParams.y); 

      	*/

      	// (0, 1) ==>(-1, 1)
       	float2 p = (2 * fragCoord.xy - _ScreenParams.xy) / min(_ScreenParams.y, _ScreenParams.x);  
       	p.y -= 0.25;

        // animate  
        // 使用公式：(1+(0.5*x^0.2+0.5)*0.5*sin(x*6.2531*3.0)*e^-4x)
        float tt = fmod(_Time.y, 1.5) / 1.5;  
        // fmod 计算余数，1.5为周期
        float ss = pow(tt, 0.2) * 0.5 + 0.5;  
        ss = 1.0 + ss * 0.5 * sin(tt * 6.2831 * 3.0) * exp(-tt * 4.0);  
        p *= float2(0.5,1.5) + ss * float2(0.5, -0.5);  // 对x和y进行扰动，使得心在跳动时，纵向变矮，横向变宽

        // shape  
        float a = atan2(p.x, p.y) / 3.141593;  // atan2(p.x, p.y)的值域(-pi,pi),因此a的值域(-1,1)
        float r = length(p);  // 爱心的半径为向量p的模
        float h = abs(a);  // 对称爱心
        float d = (13.0*h - 22.0*h*h + 10.0*h*h*h)/(6.0-5.0*h); // 塑形
        //float d = h;

        // color  
        // 爱心颜色
        float3 hcol = float3(1.0, 0.5*r, 0.3);  // *r:从中心向外颜色变化，颜色参数可调节
        // 背景颜色为黑色
		float3 bcol = float3(0,0,0);

		// lerp(a,b,c): a*c+b*(1-c) 
		// 如果 d-r<-0.01,在心内，smoothstep返回0，lerp为hcol
		// 如果 d-r>0.01,在心外，smoothstep返回1，lerp为bcol
		// 如果 d-r在两者中间，就用该值进行线性插值，起到边缘检测模糊效果,抗锯齿
		float3 col = lerp( bcol, hcol, smoothstep( -0.01, 0.01, d - r) );  

		return fixed4(col, 1.0);
	}

	ENDCG

	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		}
	}

	Fallback "Diffuse"
}


// ref： 
// http://blog.csdn.net/candycat1992/article/details/44040273
// http://blog.csdn.net/candycat1992/article/details/44244549
// http://www.cnblogs.com/cooka/p/3673819.html