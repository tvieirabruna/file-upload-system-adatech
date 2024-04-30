/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  output: "standalone",

  async rewrites() {
    return [
      {
        source: '/(.*)',
        destination: '/api/cors-handler',
      },
    ];
  },
}

module.exports = nextConfig
