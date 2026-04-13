import type { NextConfig } from "next";
import fs from "fs";

// Read ReScript configuration to get dependencies
const rescript = JSON.parse(fs.readFileSync("./rescript.json", "utf8"));
const transpileModules = ["rescript"].concat(rescript["bs-dependencies"]);

const nextConfig: NextConfig = {
  // Support both JS/JSX (for pages), TS/TSX (for app router), and ReScript compiled files
  pageExtensions: ["tsx", "ts", "jsx", "js", "res.mjs"],

  env: {
    ENV: process.env.NODE_ENV,
  },

  // Transpile ReScript dependencies
  transpilePackages: transpileModules,

  // Turbopack configuration (default bundler in Next.js 16)
  turbopack: {
    resolveExtensions: [".mjs", ".js", ".jsx", ".ts", ".tsx", ".json"],
  },

  // Webpack fallback for `next build --webpack` or environments not using Turbopack
  webpack: (config, options) => {
    const { isServer } = options;

    if (!isServer) {
      // Shim Node.js modules for client-side
      config.resolve.fallback = {
        fs: false,
        path: false,
      };
    }

    // Handle ReScript .mjs files
    config.module.rules.push({
      test: /\.m?js$/,
      use: options.defaultLoaders.babel,
      exclude: /node_modules/,
      type: "javascript/auto",
      resolve: {
        fullySpecified: false,
      },
    });

    return config;
  },
};

export default nextConfig;
