## 1. Script compartilhado de resolução de imagem

- [x] 1.1 Criar `scripts/resolve-image-ref.sh` com `#!/usr/bin/env bash` e `set -euo pipefail`
- [x] 1.2 Implementar resolução da referência `<registry>/<namespace>/<image>:<sha>` a partir de env vars, com tratamento de barras e validação de `REGISTRY` e `IMAGE_NAME` obrigatórios
- [x] 1.3 Emitir `repository` (sem tag) e `tag` separados para consumo pelo Helm, além da referência completa
- [x] 1.4 Garantir falha rápida com mensagem clara quando `REGISTRY`, `IMAGE_NAME` ou `DOCKERFILE_PATH` faltarem

## 2. Refatoração do publish-image.yml para usar o script

- [x] 2.1 Substituir a resolução inline de `image-ref` do `publish-image.yml` pela chamada a `scripts/resolve-image-ref.sh`
- [x] 2.2 Manter o comportamento externo inalterado (tag imutável por SHA, formato da referência idêntico)
- [x] 2.3 Validar a refatoração com um run existente de publish (sem mudança de output)

## 3. Template de deploy Kubernetes

- [x] 3.1 Criar `.github/workflows/deploy-kubernetes.yml` (`workflow_call`) com inputs `chart_path`, `release_name`, `namespace` e `environment`
- [x] 3.2 Declarar secrets `kubeconfig`, `infra_token`, `registry_username` e `registry_password`
- [x] 3.3 Adicionar checkout do repo de infra (`INFRA_REPO` + `INFRA_TOKEN`) e do ci-templates
- [x] 3.4 Configurar `azure/setup-kubectl` e `azure/setup-helm` no runner
- [x] 3.5 Gravar o kubeconfig (base64) em `~/.kube/config` com permissão `600`
- [x] 3.6 Resolver a referência da imagem via `scripts/resolve-image-ref.sh`, emitindo `repository` e `tag`
- [x] 3.7 Criar/atualizar o `imagePullSecret` (`kubernetes.io/dockerconfigjson`) de forma idempotente (dry-run + apply) usando `IMAGE_PULL_SECRET_NAME`
- [x] 3.8 Executar `helm upgrade --install` com `image.repository` e `image.tag` via `--set`, `--namespace`, `--wait` e `--timeout`
- [x] 3.9 Verificar o rollout com `kubectl rollout status` e falhar cedo em caso de erro

## 4. Documentação e exemplo

- [x] 4.1 Criar `docs/kubernetes-deploy.md` com o que faz, inputs, variáveis, secrets e exemplo de uso
- [x] 4.2 Criar `examples/github-actions/deploy-kubernetes.yml` mostrando o consumo junto ao `publish-image.yml` (job `deploy` com `needs: publish`)
- [x] 4.3 Atualizar o `README.md` com a nova entrada do template de deploy

## 5. Validação

- [x] 5.1 Rodar `shellcheck` (se disponível) em `scripts/resolve-image-ref.sh`
- [x] 5.2 Validar sintaxe dos YAMLs de workflow (parser YAML)
- [x] 5.3 Testar `scripts/resolve-image-ref.sh` com `REGISTRY`, `REGISTRY_NAMESPACE` e `IMAGE_NAME` variados (com e sem namespace, com e sem barras)
