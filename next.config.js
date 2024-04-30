/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  output: "standalone",

  async headers() {
    return [
      {
        // This will apply to all routes
        source: '/(.*)',  
        headers: [
          {
            key: 'Access-Control-Allow-Origin',
            value: '*'  // Allow requests from any origin
          },
          {
            key: 'Access-Control-Allow-Methods',
            value: 'GET, POST, PUT, DELETE, OPTIONS'  // Allowed HTTP methods
          },
          {
            key: 'Access-Control-Allow-Headers',
            value: '*'  // Allow all headers
          },
          {
            key: 'Access-Control-Max-Age',
            value: '3600'  // Preflight cache duration in seconds
          }
        ]
      }
    ]
  }
}

module.exports = nextConfig
