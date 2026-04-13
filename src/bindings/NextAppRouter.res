// Next.js App Router bindings for ReScript
// Updated for Next.js 16.x
// Comprehensive bindings for client-side navigation, server components, and more

// ============================================================================
// CLIENT-SIDE NAVIGATION & HOOKS
// ============================================================================

module Navigation = {
  // URLSearchParams binding
  type urlSearchParams

  // Navigation options for push/replace
  type navigationOptions = {
    scroll?: bool,
    transitionTypes?: array<string>,
  }

  // Prefetch options
  type prefetchOptions = {
    onInvalidate?: unit => unit,
  }

  // Router object returned by useRouter
  type router = {
    push: string => unit,
    replace: string => unit,
    refresh: unit => unit,
    back: unit => unit,
    forward: unit => unit,
    prefetch: string => unit,
  }

  // Navigation hooks
  @module("next/navigation")
  external useRouter: unit => router = "useRouter"

  @module("next/navigation")
  external usePathname: unit => string = "usePathname"

  @module("next/navigation")
  external useSearchParams: unit => urlSearchParams = "useSearchParams"

  @module("next/navigation")
  external useParams: unit => Dict.t<string> = "useParams"

  // Push/replace with options
  @send external pushWithOptions: (router, string, navigationOptions) => unit = "push"
  @send external replaceWithOptions: (router, string, navigationOptions) => unit = "replace"
  @send external prefetchWithOptions: (router, string, prefetchOptions) => unit = "prefetch"

  // Navigation functions (client-side)
  @module("next/navigation")
  external redirect: string => unit = "redirect"

  @module("next/navigation")
  external notFound: unit => unit = "notFound"

  @module("next/navigation")
  external permanentRedirect: string => unit = "permanentRedirect"
}

// ============================================================================
// LINK COMPONENT (Updated for Next.js 16)
// ============================================================================

module Link = {
  @module("next/link") @react.component
  external make: (
    ~href: string,
    ~prefetch: bool=?,
    ~replace: bool=?,
    ~scroll: bool=?,
    ~className: string=?,
    ~transitionTypes: array<string>=?,
    ~children: React.element,
  ) => React.element = "default"
}

// ============================================================================
// IMAGE COMPONENT (Updated for Next.js 16)
// ============================================================================

module Image = {
  @module("next/image") @react.component
  external make: (
    ~className: string=?,
    ~src: string,
    ~alt: string,
    ~width: int=?,
    ~height: int=?,
    ~fill: bool=?,
    ~preload: bool=?,
    ~priority: bool=?,
    ~children: React.element=?,
  ) => React.element = "default"
}

// ============================================================================
// METADATA TYPES & HELPERS
// ============================================================================

module Metadata = {
  type openGraphImage = {
    url: string,
    width: option<int>,
    height: option<int>,
    alt: option<string>,
  }

  type openGraph = {
    title: option<string>,
    description: option<string>,
    url: option<string>,
    siteName: option<string>,
    images: option<array<openGraphImage>>,
    locale: option<string>,
    type_: option<string>,
  }

  type twitter = {
    card: option<string>,
    title: option<string>,
    description: option<string>,
    creator: option<string>,
    images: option<array<string>>,
  }

  type googleBot = {
    index: option<bool>,
    follow: option<bool>,
    maxVideoPreview: option<int>,
    maxImagePreview: option<string>,
    maxSnippet: option<int>,
  }

  type robots = {
    index: option<bool>,
    follow: option<bool>,
    googleBot: option<googleBot>,
  }

  type author = {
    name: option<string>,
    url: option<string>,
  }

  type icons = {
    icon: option<array<string>>,
    shortcut: option<array<string>>,
    apple: option<array<string>>,
  }

  type metadata = {
    title: option<string>,
    description: option<string>,
    keywords: option<array<string>>,
    authors: option<array<author>>,
    creator: option<string>,
    publisher: option<string>,
    robots: option<robots>,
    openGraph: option<openGraph>,
    twitter: option<twitter>,
    manifest: option<string>,
    icons: option<icons>,
  }

  // Viewport type (separate export in Next.js 16)
  type viewport = {
    width: option<string>,
    initialScale: option<float>,
    maximumScale: option<float>,
    userScalable: option<bool>,
    themeColor: option<string>,
    colorScheme: option<string>,
  }

  // Helper function to create metadata
  let make = (
    ~title=?,
    ~description=?,
    ~keywords=?,
    ~openGraph=?,
    ~twitter=?,
    ~robots=?,
    (),
  ): metadata => {
    title,
    description,
    keywords,
    openGraph,
    twitter,
    robots,
    manifest: None,
    icons: None,
    creator: None,
    publisher: None,
    authors: None,
  }

  // generateMetadata function type (params/searchParams are now promises in Next.js 16)
  type generateMetadataParams<'params, 'searchParams> = {
    params: promise<'params>,
    searchParams: promise<'searchParams>,
  }

  type generateMetadataFn<'params, 'searchParams> =
    generateMetadataParams<'params, 'searchParams> => promise<metadata>
}

// ============================================================================
// ERROR HANDLING
// ============================================================================

module ErrorHandling = {
  // Error page props
  type errorProps = {
    error: Exn.t,
    reset: unit => unit,
  }

  // Not found component
  @module("next/navigation")
  external notFound: unit => unit = "notFound"
}

// ============================================================================
// LOADING & STREAMING
// ============================================================================

module Loading = {
  // Suspense boundary helpers
  @module("react")
  external suspense: (~fallback: React.element, ~children: React.element) => React.element =
    "Suspense"
}

// ============================================================================
// CLIENT COMPONENT DIRECTIVE
// ============================================================================

// To mark ReScript components as client components, use the directive at the top of your .res file:
// @@directive("'use client'")
//
// Example usage:
// @@directive("'use client'")
//
// @react.component
// let make = (~children) => {
//   <div className="client-component"> {children} </div>
// }
