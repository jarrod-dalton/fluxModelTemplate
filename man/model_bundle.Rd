\name{model_bundle}
\alias{model_bundle}
\title{Template model bundle scaffold}
\usage{model_bundle(params = list())}
\arguments{
\item{params}{Optional model parameter list to store in the bundle.}
}
\value{A model bundle list consumable by \code{fluxCore::Engine}.}
\description{
Provides a commented starter bundle wiring for \code{propose_events},
\code{transition}, \code{stop}, and optional \code{observe}/\code{init_entity}
hooks in a new model package.
}
