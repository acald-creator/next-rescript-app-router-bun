# ReScript + Next.js Chat Template

An [OpenAI-compatible](https://platform.openai.com/docs/api-reference/chat) chat app written in [ReScript](https://rescript-lang.org) on the [Next.js](https://nextjs.org) 16 App Router, using [Bun](https://bun.sh) and [Tailwind CSS](https://tailwindcss.com) v4.

The UI streams tokens from `POST /api/chat`. That route calls `${OPENAI_BASE_URL}/chat/completions`, so it works with OpenAI, OpenRouter, Groq, Ollama, Azure-compatible proxies, vLLM, and other Chat Completions servers.

Without `OPENAI_API_KEY` or `OPENAI_BASE_URL`, the API streams a local demo response so you can try the UI immediately.

## Getting Started

Install dependencies:

```bash
bun install
```

Copy the env file and add a key when you want a real model:

```bash
cp .env.example .env.local
```

Compile ReScript and start the development server:

```bash
bun run res:build
bun dev
```

For ReScript watch mode (auto-recompile on save), run in a separate terminal:

```bash
bun run res:dev
```

Open [http://localhost:3000](http://localhost:3000).

## Environment

| Variable | Default | Notes |
|---|---|---|
| `OPENAI_API_KEY` | unset | Bearer token. Optional for local servers that skip auth. |
| `OPENAI_BASE_URL` | `https://api.openai.com/v1` | Must include `/v1` when the provider uses it. |
| `OPENAI_MODEL` | `gpt-4o-mini` | Sent as `model` in the Chat Completions body. |
| `OPENAI_SYSTEM_PROMPT` | unset | Prepended as a `system` message on the server. |

If both `OPENAI_API_KEY` and `OPENAI_BASE_URL` are unset, the route runs in demo mode.

### Provider examples

OpenAI:

```bash
OPENAI_API_KEY=sk-...
OPENAI_BASE_URL=https://api.openai.com/v1
OPENAI_MODEL=gpt-4o-mini
```

OpenRouter:

```bash
OPENAI_API_KEY=sk-or-...
OPENAI_BASE_URL=https://openrouter.ai/api/v1
OPENAI_MODEL=openai/gpt-4o-mini
```

Ollama:

```bash
OPENAI_BASE_URL=http://localhost:11434/v1
OPENAI_MODEL=llama3.2
OPENAI_API_KEY=ollama
```

## Project Structure

```
src/
├── app/
│   ├── layout.res          # Root layout (fonts, metadata, CSS)
│   ├── page.res            # Home page
│   ├── Chat.res            # Client chat UI
│   ├── globals.css         # Tailwind CSS + theme variables
│   └── api/chat/route.res  # GET config + POST streaming completions
├── chat/
│   ├── Message.res         # Message types and JSON decoding
│   ├── OpenAI.res          # OpenAI-compatible client + demo stream
│   └── Sse.res             # SSE parser for Chat Completions chunks
└── bindings/
    ├── NextAppRouter.res   # Client-side Next.js bindings
    ├── NextAppServer.res   # Server-side Next.js bindings
    └── WebApi.res          # fetch, streams, abort
```

## Scripts

| Command | Description |
|---|---|
| `bun dev` | Start development server |
| `bun run build` | Compile ReScript + build for production |
| `bun run res:build` | Compile ReScript files |
| `bun run res:dev` | ReScript watch mode |
| `bun run res:clean` | Clean ReScript build artifacts |
| `bun run lint` | Run Biome linter and formatter checks |
| `bun run format` | Auto-format code with Biome |

## Learn More

- [ReScript Documentation](https://rescript-lang.org/docs/manual/latest/introduction)
- [Next.js Documentation](https://nextjs.org/docs)
- [OpenAI Chat Completions](https://platform.openai.com/docs/api-reference/chat)
