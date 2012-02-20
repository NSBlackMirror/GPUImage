// Anisotropic Kuwahara Filtering on the GPU
// by Jan Eric Kyprianidis <www.kyprianidis.com>
//
// From Kyprianidis, J. E., Kang, H., and Doellner, J. "Anisotropic Kuwahara Filtering on the GPU," GPU Pro p.247 (2010).

varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

precision highp float;

const vec2 src_size = vec2 (768.0, 1024.0);

const int radius = 6;

void main (void) 
{
    vec2 uv = textureCoordinate;
    float n = float((radius + 1) * (radius + 1));
    
    vec3 m[4];
    vec3 s[4];
    for (int k = 0; k < 4; ++k) {
        m[k] = vec3(0.0);
        s[k] = vec3(0.0);
    }
    
    for (int j = -radius; j <= 0; ++j)  {
        for (int i = -radius; i <= 0; ++i)  {
            vec3 c = texture2D(inputImageTexture, uv + vec2(i,j) / src_size).rgb;
            m[0] += c;
            s[0] += c * c;
        }
    }
    
    for (int j = -radius; j <= 0; ++j)  {
        for (int i = 0; i <= radius; ++i)  {
            vec3 c = texture2D(inputImageTexture, uv + vec2(i,j) / src_size).rgb;
            m[1] += c;
            s[1] += c * c;
        }
    }
    
    for (int j = 0; j <= radius; ++j)  {
        for (int i = 0; i <= radius; ++i)  {
            vec3 c = texture2D(inputImageTexture, uv + vec2(i,j) / src_size).rgb;
            m[2] += c;
            s[2] += c * c;
        }
    }
    
    for (int j = 0; j <= radius; ++j)  {
        for (int i = -radius; i <= 0; ++i)  {
            vec3 c = texture2D(inputImageTexture, uv + vec2(i,j) / src_size).rgb;
            m[3] += c;
            s[3] += c * c;
        }
    }
    
    
    float min_sigma2 = 1e+2;
    for (int k = 0; k < 4; ++k) {
        m[k] /= n;
        s[k] = abs(s[k] / n - m[k] * m[k]);
        
        float sigma2 = s[k].r + s[k].g + s[k].b;
        if (sigma2 < min_sigma2) {
            min_sigma2 = sigma2;
            gl_FragColor = vec4(m[k], 1.0);
        }
    }
}


