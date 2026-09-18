#!/usr/bin/env bash
set -euo pipefail

# Resolve a container image reference and emit it in GitHub Actions output.
#
# Required environment variables:
#   REGISTRY          Registry host, such as ghcr.io or registry.example.com.
#   IMAGE_NAME        Image name without a tag.
#   SHA               Commit SHA used as the immutable tag.
#
# Optional environment variables:
#   REGISTRY_NAMESPACE  Optional registry namespace or organization.
#   GITHUB_OUTPUT       When set (GitHub Actions), appends outputs to this file.
#
# Emitted values (both appended to GITHUB_OUTPUT and printed to stdout):
#   ref         Full reference: <registry>/<namespace>/<image>:<tag>
#   repository  Reference without the tag: <registry>/<namespace>/<image>
#   tag         The image tag (the commit SHA).

registry="${REGISTRY:-}"
registry="${registry%/}"
registry="${registry#/}"

namespace="${REGISTRY_NAMESPACE:-}"
namespace="${namespace%/}"
namespace="${namespace#/}"

image_name="${IMAGE_NAME:-}"
image_name="${image_name#/}"
image_name="${image_name%/}"

tag="${SHA:-latest}"

if [ -z "$registry" ]; then
  echo "error: REGISTRY environment variable is required." >&2
  exit 1
fi

if [ -z "$image_name" ]; then
  echo "error: IMAGE_NAME environment variable is required." >&2
  exit 1
fi

if [ -n "$namespace" ]; then
  repository="$registry/$namespace/$image_name"
else
  repository="$registry/$image_name"
fi

ref="$repository:$tag"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  printf 'ref=%s\n' "$ref" >>"$GITHUB_OUTPUT"
  printf 'repository=%s\n' "$repository" >>"$GITHUB_OUTPUT"
  printf 'tag=%s\n' "$tag" >>"$GITHUB_OUTPUT"
fi

printf 'ref=%s\n' "$ref"
printf 'repository=%s\n' "$repository"
printf 'tag=%s\n' "$tag"
