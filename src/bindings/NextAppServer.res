// Next.js App Router Server-side bindings
// Server Components, Server Actions, and Route Handlers

// ============================================================================
// WEB API TYPE BINDINGS
// ============================================================================

// Form Data
type formData
@send external formDataGet: (formData, string) => Nullable.t<string> = "get"
@send external formDataGetAll: (formData, string) => array<string> = "getAll"
@send external formDataHas: (formData, string) => bool = "has"
@send external formDataEntries: formData => Iterator.t<(string, string)> = "entries"

// Headers
type headers
@send external headersGet: (headers, string) => Nullable.t<string> = "get"
@send external headersHas: (headers, string) => bool = "has"

// Iterator
type iterator<'a>
module Iterator = {
  type t<'a> = iterator<'a>
}

// Response
type response
module Response = {
  type t = response
}

// ============================================================================
// SERVER COMPONENT SUPPORT
// ============================================================================

module ServerComponent = {
  // Server-side redirect (different from client redirect)
  @module("next/navigation")
  external redirect: (~url: string, ~type_: [#replace | #push]=?) => unit = "redirect"

  @module("next/navigation")
  external permanentRedirect: string => unit = "permanentRedirect"

  @module("next/navigation")
  external notFound: unit => unit = "notFound"

  // Note: To mark server functions, use @@directive("'use server'") at the top of function files
  // Example:
  // @@directive("'use server'")
  //
  // let myServerAction = async (formData) => {
  //   // server action logic
  // }
}

// ============================================================================
// SERVER ACTIONS
// ============================================================================

module ServerActions = {
  // FormData handling (reuse the top-level type and bindings)
  type formData = formData

  let get = formDataGet
  let getAll = formDataGetAll
  let has = formDataHas
  let entries = formDataEntries

  // Helper type for server action functions
  type serverAction<'return> = formData => promise<'return>

  // Bind state for form actions (useFormState equivalent)
  type formState<'state> = ('state, formData) => promise<'state>
}

// ============================================================================
// ROUTE HANDLERS (API Routes)
// ============================================================================

module RouteHandler = {
  // URLSearchParams type
  type urlSearchParams

  // NextUrl type
  type nextUrl = {
    pathname: string,
    searchParams: urlSearchParams,
    basePath: string,
    href: string,
  }

  // Cookie value type
  type cookieValue = {name: string, value: string}

  // Cookie methods type
  type cookieMethods = {
    get: string => option<cookieValue>,
    set: (string, string) => unit,
    delete: string => unit,
  }

  // Geo location type
  type geo = {
    city: option<string>,
    country: option<string>,
    region: option<string>,
    latitude: option<string>,
    longitude: option<string>,
  }

  // Request object (extends standard Request)
  type nextRequest = {
    // Standard Request properties
    url: string,
    method: string,
    headers: headers,

    // Next.js specific extensions
    nextUrl: nextUrl,

    // Cookies
    cookies: cookieMethods,

    // Geolocation (Vercel)
    geo: option<geo>,

    // IP address
    ip: option<string>,
  }

  // Response helpers
  @val external nextResponse: 'a = "Response"

  // Response options type
  type responseOptions

  module Response = {
    @send external json: ('a, ~options: responseOptions=?) => 'b = "json"
    @send external redirect: (string, ~status: int=?) => 'a = "redirect"
    @new external make: (string, ~options: responseOptions=?) => 'a = "Response"
  }

  // Route handler function types
  type routeHandler<'return> = nextRequest => promise<'return>

  // HTTP method handlers
  type getHandler = nextRequest => promise<response>
  type postHandler = nextRequest => promise<response>
  type putHandler = nextRequest => promise<response>
  type deleteHandler = nextRequest => promise<response>
  type patchHandler = nextRequest => promise<response>
  type headHandler = nextRequest => promise<response>
  type optionsHandler = nextRequest => promise<response>
}

// ============================================================================
// COOKIES (Server-side)
// ============================================================================

module Cookies = {
  // Cookie value type
  type cookieValue = {name: string, value: string}

  // Cookie options type
  type cookieOptions

  // Cookie store methods
  type cookieStore = {
    get: string => option<cookieValue>,
    getAll: unit => array<cookieValue>,
    has: string => bool,
    set: (string, string, ~options: cookieOptions=?) => unit,
    delete: string => unit,
  }

  @module("next/headers")
  external cookies: unit => cookieStore = "cookies"
}

// ============================================================================
// HEADERS (Server-side)
// ============================================================================

module Headers = {
  // Headers store methods
  type headerStore = {
    get: string => Nullable.t<string>,
    has: string => bool,
    entries: unit => Iterator.t<(string, string)>,
    forEach: ((string, string) => unit) => unit,
  }

  @module("next/headers")
  external headers: unit => headerStore = "headers"
}

// ============================================================================
// DYNAMIC ROUTE SEGMENTS
// ============================================================================

module Params = {
  // Type for route parameters (e.g., [id], [slug])
  type params<'a> = 'a

  // Type for search parameters
  type searchParams = Dict.t<string>

  // Page props type for dynamic routes
  type pageProps<'params> = {
    params: 'params,
    searchParams: searchParams,
  }
}

// ============================================================================
// REVALIDATION
// ============================================================================

module Revalidation = {
  @module("next/cache")
  external revalidatePath: (~path: string, ~type_: [#page | #layout]=?) => unit = "revalidatePath"

  @module("next/cache")
  external revalidateTag: string => unit = "revalidateTag"
}

// ============================================================================
// CACHING
// ============================================================================

module Cache = {
  // Cache options type
  type cacheOptions

  @module("next/cache")
  external unstable_cache: (
    'fn,
    ~keys: array<string>=?,
    ~options: cacheOptions=?
  ) => 'fn = "unstable_cache"

  @module("next/cache")
  external unstable_noStore: unit => unit = "unstable_noStore"
}