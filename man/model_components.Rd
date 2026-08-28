\name{model_components}
\alias{model_schema}
\alias{model_time_spec}
\alias{model_bundle}
\title{Build the template model schema, clock, and bundle}
\usage{
model_schema()

model_time_spec()

model_bundle(params = list(), bundle_time_spec = model_time_spec())
}
\arguments{
\item{params}{Optional named list overriding the template model's default
parameters. During a run, fluxCore exposes the resolved values through
\code{param_ctx$params}.}

\item{bundle_time_spec}{Canonical \code{fluxCore::time_spec} used by the
returned bundle. Defaults to \code{model_time_spec()}.}
}
\value{
\code{model_schema()} returns the named variable schema. \code{model_time_spec()}
returns the canonical \code{time_spec} read from
\code{inst/model_config/time_spec.json}. \code{model_bundle()} returns the wired
fluxCore model bundle.
}
\description{
These are the three exported entry points a copied domain-model package should
customize: its state-variable contract, its single canonical clock, and the
bundle that wires model callbacks together.
}
