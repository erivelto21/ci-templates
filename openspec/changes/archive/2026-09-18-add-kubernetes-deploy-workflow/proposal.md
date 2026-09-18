## Why

O repositório já publica imagens de build em um registry (via `publish-image.yml`), mas não existe um caminho reutilizável para levar essa imagem ao cluster Kubernetes. Cada aplicação precisaria reimplementar o deploy, duplicando lógica de autenticação, resolução de imagem e aplicação de manifest. Um template reutilizável de deploy fecha o ciclo build → publish → deploy de forma consistente e segura.

## What Changes

- Adiciona o template reutilizável `.github/workflows/deploy-kubernetes.yml` (`workflow_call`) que:
  - Faz checkout do repositório de infraestrutura (onde vive o Helm chart) usando um token com acesso de leitura.
  - Configura `kubectl` e `helm` no runner.
  - Grava o kubeconfig (secret base64) em `~/.kube/config`.
  - Resolve a referência da imagem publicada (`<registry>/<namespace>/<image>:<sha>`), recalculando a partir das mesmas variáveis do publish.
  - Cria/atualiza o `imagePullSecret` no namespace de forma idempotente (registry privado).
  - Executa `helm upgrade --install` com `image.repository` e `image.tag` injetados via `--set`.
  - Verifica o rollout do deployment e falha cedo se a imagem não subir.
- Extrai a resolução da referência da imagem para `scripts/resolve-image-ref.sh`, compartilhada entre `publish-image.yml` e `deploy-kubernetes.yml` (fonte única de verdade, sem depender de outputs entre workflows).
- Adiciona documentação em `docs/kubernetes-deploy.md` (inputs, variáveis, secrets, exemplo de uso) e um exemplo consumível em `examples/github-actions/deploy-kubernetes.yml`.

## Capabilities

### New Capabilities
- `kubernetes-deploy`: Deploy de uma imagem publicada em um cluster Kubernetes via Helm, com autenticação por kubeconfig, checkout do chart em repositório de infra e gerenciamento de `imagePullSecret` para registry privado.

### Modified Capabilities
<!-- Nenhuma mudança de requisito em spec-level. A extração do resolve-image-ref é detalhe de implementação; o comportamento do publish-image permanece o mesmo. -->

## Impact

- **Novos arquivos**: `.github/workflows/deploy-kubernetes.yml`, `scripts/resolve-image-ref.sh`, `docs/kubernetes-deploy.md`, `examples/github-actions/deploy-kubernetes.yml`.
- **Arquivo modificado**: `.github/workflows/publish-image.yml` (passa a usar o script compartilhado de resolução de imagem; comportamento externo inalterado).
- **Dependências**: ações de terceiros (`azure/setup-kubectl`, `azure/setup-helm`, `actions/checkout`).
- **Secrets/variáveis esperados no repo consumidor**: `KUBECONFIG` (base64), `INFRA_TOKEN`, `REGISTRY_USERNAME`, `REGISTRY_PASSWORD`, `INFRA_REPO`, `REGISTRY`, `REGISTRY_NAMESPACE`, `IMAGE_NAME`, `IMAGE_PULL_SECRET_NAME`.
